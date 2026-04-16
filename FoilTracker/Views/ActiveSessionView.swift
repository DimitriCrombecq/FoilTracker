import SwiftUI
import MapKit

struct ActiveSessionView: View {
    @Bindable var locationManager: LocationManager
    @Binding var navigationPath: NavigationPath
    @State private var completedSession: Session?

    var body: some View {
        VStack(spacing: 24) {
            // Live speed display
            VStack(spacing: 8) {
                Text("Current Speed")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(String(format: "%.1f", locationManager.currentSpeed * 1.94384))
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)

                Text("knots")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                Text(String(format: "%.1f km/h", locationManager.currentSpeed * 3.6))
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)

            // Point count
            if let session = locationManager.currentSession {
                Text("\(session.locationPoints.count) points recorded")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Live mini map
            if let session = locationManager.currentSession, session.locationPoints.count > 1 {
                Map {
                    ForEach(0..<(session.locationPoints.count - 1), id: \.self) { i in
                        MapPolyline(coordinates: [
                            session.locationPoints[i].coordinate,
                            session.locationPoints[i + 1].coordinate
                        ])
                        .stroke(SpeedColoredMapView.colorForSpeed(session.locationPoints[i].speedInKnots), lineWidth: 3)
                    }
                }
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            Spacer()

            // Stop button
            Button {
                Task {
                    if let session = await locationManager.stopSession() {
                        completedSession = session
                    }
                }
            } label: {
                Label("Stop Session", systemImage: "stop.fill")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 32)
        }
        .navigationTitle("Tracking")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $completedSession) { session in
            SessionSummaryView(
                session: session,
                navigationPath: $navigationPath,
                isReview: false
            )
        }
    }
}
