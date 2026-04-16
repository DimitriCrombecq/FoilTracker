import Foundation
import CoreLocation

struct LocationPoint: Codable, Identifiable {
    let id: UUID
    let latitude: Double
    let longitude: Double
    let speed: Double // meters per second
    let timestamp: Date

    init(location: CLLocation) {
        self.id = UUID()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.speed = max(location.speed, 0)
        self.timestamp = location.timestamp
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var speedInKnots: Double {
        speed * 1.94384
    }

    var speedInKmh: Double {
        speed * 3.6
    }
}

struct Session: Codable, Identifiable, Hashable {
    let id: UUID
    let startDate: Date
    var endDate: Date?
    var locationPoints: [LocationPoint]
    var locationName: String?

    init() {
        self.id = UUID()
        self.startDate = Date()
        self.locationPoints = []
    }

    var totalDistance: Double {
        guard locationPoints.count > 1 else { return 0 }
        var distance: Double = 0
        for i in 1..<locationPoints.count {
            let prev = CLLocation(latitude: locationPoints[i - 1].latitude, longitude: locationPoints[i - 1].longitude)
            let curr = CLLocation(latitude: locationPoints[i].latitude, longitude: locationPoints[i].longitude)
            distance += curr.distance(from: prev)
        }
        return distance
    }

    var totalDistanceKm: Double {
        totalDistance / 1000.0
    }

    var maxSpeedKnots: Double {
        (locationPoints.map(\.speed).max() ?? 0) * 1.94384
    }

    var maxSpeedKmh: Double {
        (locationPoints.map(\.speed).max() ?? 0) * 3.6
    }

    var duration: TimeInterval {
        guard let end = endDate else { return Date().timeIntervalSince(startDate) }
        return end.timeIntervalSince(startDate)
    }

    static func == (lhs: Session, rhs: Session) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
