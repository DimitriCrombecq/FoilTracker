import Foundation
import CoreLocation
import HealthKit
import WatchKit
import SwiftUI

@Observable
class WatchLocationManager: NSObject, CLLocationManagerDelegate, HKWorkoutSessionDelegate {
    private let locationManager = CLLocationManager()
    private let healthStore = HKHealthStore()
    private var workoutSession: HKWorkoutSession?
    private var workoutBuilder: HKLiveWorkoutBuilder?

    private(set) var currentSession: Session?
    private(set) var isTracking = false
    private(set) var currentSpeed: Double = 0 // meters per second
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.activityType = .otherNavigation
        locationManager.allowsBackgroundLocationUpdates = true
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Authorization

    func requestPermissions() {
        locationManager.requestWhenInUseAuthorization()

        let typesToShare: Set<HKSampleType> = [HKObjectType.workoutType()]
        let typesToRead: Set<HKObjectType> = [HKObjectType.workoutType()]
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { _, error in
            if let error {
                print("HealthKit authorization error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Session Lifecycle

    func startSession() {
        currentSession = Session()
        isTracking = true

        startWorkoutSession()
        locationManager.startUpdatingLocation()
    }

    func stopSession() -> Session? {
        locationManager.stopUpdatingLocation()
        isTracking = false
        currentSession?.endDate = Date()

        stopWorkoutSession()

        let session = currentSession
        currentSession = nil
        currentSpeed = 0
        return session
    }

    // MARK: - HKWorkoutSession (keeps app alive + enables Water Lock)

    private func startWorkoutSession() {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .surfingSports
        configuration.locationType = .outdoor

        do {
            workoutSession = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
            workoutSession?.delegate = self

            workoutBuilder = workoutSession?.associatedWorkoutBuilder()
            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(
                healthStore: healthStore,
                workoutConfiguration: configuration
            )

            let startDate = Date()
            workoutSession?.startActivity(with: startDate)

            Task {
                try? await workoutBuilder?.beginCollection(at: startDate)
            }

            // Activate Water Lock
            DispatchQueue.main.async {
                WKInterfaceDevice.current().enableWaterLock()
            }
        } catch {
            print("Workout session failed: \(error.localizedDescription)")
        }
    }

    private func stopWorkoutSession() {
        workoutSession?.end()

        Task {
            try? await workoutBuilder?.endCollection(at: Date())
            try? await workoutBuilder?.finishWorkout()
        }

        workoutSession = nil
        workoutBuilder = nil
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard isTracking else { return }
        for location in locations {
            guard location.horizontalAccuracy >= 0, location.horizontalAccuracy < 65 else { continue }
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

    // MARK: - HKWorkoutSessionDelegate

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        print("Workout state: \(fromState.rawValue) -> \(toState.rawValue)")
    }

    func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        print("Workout error: \(error.localizedDescription)")
    }
}
