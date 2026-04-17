import Foundation
import CoreLocation
import MapKit
import SwiftUI

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    private(set) var currentSession: Session?
    private(set) var isTracking = false
    private(set) var currentSpeed: Double = 0 // m/s
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 3
        manager.activityType = .otherNavigation
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startSession() {
        currentSession = Session()
        isTracking = true
        manager.startUpdatingLocation()
    }

    func stopSession() async -> Session? {
        manager.stopUpdatingLocation()
        isTracking = false
        currentSession?.endDate = Date()

        // Reverse geocode the midpoint of the session
        if let points = currentSession?.locationPoints, !points.isEmpty {
            let midpoint = points[points.count / 2]
            let location = CLLocation(latitude: midpoint.latitude, longitude: midpoint.longitude)
            if let request = MKReverseGeocodingRequest(location: location),
               let mapItem = try? await request.mapItems.first {
                currentSession?.locationName = mapItem.addressRepresentations?.cityWithContext
            }
        }

        let session = currentSession
        currentSession = nil
        currentSpeed = 0
        return session
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        for location in locations {
            guard location.horizontalAccuracy >= 0, location.horizontalAccuracy < 20 else { continue }
            let point = LocationPoint(location: location)
            currentSession?.locationPoints.append(point)
            currentSpeed = max(location.speed, 0)
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
