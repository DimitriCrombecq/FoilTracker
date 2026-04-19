import SwiftUI

struct WatchSessionSummaryView: View {
    let session: Session
    @Binding var isTrackingActive: Bool
    @Environment(WatchSessionStore.self) private var sessionStore
    var isReview: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text(isReview ? "Session Details" : "Session Complete")
                    .font(.headline)

                VStack(spacing: 8) {
                    WatchStatRow(
                        icon: "gauge.with.dots.needle.67percent",
                        label: "Max Speed",
                        value: String(format: "%.1f kts", session.maxSpeedKnots)
                    )
                    WatchStatRow(
                        icon: "gauge.with.dots.needle.67percent",
                        label: "Max Speed",
                        value: String(format: "%.1f km/h", session.maxSpeedKmh)
                    )
                    WatchStatRow(
                        icon: "point.topleft.down.to.point.bottomright.curvepath",
                        label: "Distance",
                        value: String(format: "%.2f km", session.totalDistanceKm)
                    )
                    WatchStatRow(
                        icon: "timer",
                        label: "Duration",
                        value: formattedDuration
                    )
                    WatchStatRow(
                        icon: "mappin",
                        label: "Points",
                        value: "\(session.locationPoints.count)"
                    )
                }

                if !isReview {
                    Button {
                        sessionStore.save(session)
                        isTrackingActive = false
                    } label: {
                        Label("Save", systemImage: "square.and.arrow.down")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)

                    Button(role: .destructive) {
                        isTrackingActive = false
                    } label: {
                        Label("Discard", systemImage: "trash")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden(!isReview)
    }

    private var formattedDuration: String {
        let total = Int(session.duration)
        let hours = total / 3600
        let minutes = (total % 3600) / 60
        let seconds = total % 60
        if hours > 0 {
            return String(format: "%dh %02dm", hours, minutes)
        }
        return String(format: "%dm %02ds", minutes, seconds)
    }
}

struct WatchStatRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.semibold)
        }
    }
}
