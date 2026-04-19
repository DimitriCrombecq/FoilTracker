import SwiftUI

struct WatchActiveSessionView: View {
    @Bindable var locationManager: WatchLocationManager
    @Binding var isTrackingActive: Bool
    @State private var completedSession: Session?

    var body: some View {
        VStack(spacing: 8) {
            // Live speed - large and prominent
            Text(String(format: "%.1f", locationManager.currentSpeed * 1.94384))
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .foregroundStyle(.blue)
                .minimumScaleFactor(0.7)

            Text("knots")
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(String(format: "%.1f km/h", locationManager.currentSpeed * 3.6))
                .font(.caption2)
                .foregroundStyle(.secondary)

            Spacer()

            // Recording indicator
            if let session = locationManager.currentSession {
                HStack(spacing: 4) {
                    Circle()
                        .fill(.red)
                        .frame(width: 8, height: 8)
                    Text("\(session.locationPoints.count) pts")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            // Stop button
            Button(role: .destructive) {
                if let session = locationManager.stopSession() {
                    completedSession = session
                }
            } label: {
                Label("Stop", systemImage: "stop.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding(.horizontal)
        .navigationTitle("Tracking")
        .navigationBarBackButtonHidden(true)
        .navigationDestination(item: $completedSession) { session in
            WatchSessionSummaryView(
                session: session,
                isTrackingActive: $isTrackingActive,
                isReview: false
            )
        }
    }
}
