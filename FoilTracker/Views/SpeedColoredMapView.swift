import SwiftUI
import MapKit

struct SpeedColoredMapView: View {
    let locationPoints: [LocationPoint]

    var body: some View {
        Map {
            ForEach(0..<max(locationPoints.count - 1, 0), id: \.self) { i in
                MapPolyline(coordinates: [
                    locationPoints[i].coordinate,
                    locationPoints[i + 1].coordinate
                ])
                .stroke(Self.colorForSpeed(locationPoints[i].speedInKnots), lineWidth: 4)
            }
        }
    }

    static func colorForSpeed(_ knots: Double) -> Color {
        switch knots {
        case ..<5:
            return .green
        case 5..<10:
            return .yellow
        case 10..<15:
            return .orange
        case 15..<20:
            return Color(red: 1.0, green: 0.4, blue: 0.0)
        case 20..<25:
            return .red
        default:
            return .purple
        }
    }
}
