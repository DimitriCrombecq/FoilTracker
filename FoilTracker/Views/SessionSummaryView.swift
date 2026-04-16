import SwiftUI
import MapKit

struct SessionSummaryView: View {
    let session: Session
    @Binding var navigationPath: NavigationPath
    @Environment(SessionStore.self) private var sessionStore
    var isReview: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Map with speed-colored route
                SpeedColoredMapView(locationPoints: session.locationPoints)
                    .frame(height: 300)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                // Speed legend
                SpeedLegendView()
                    .padding(.horizontal)

                // Summary stats
                VStack(spacing: 16) {
                    Text("Session Summary")
                        .font(.title2)
                        .fontWeight(.bold)

                    HStack(spacing: 32) {
                        StatCard(
                            title: "Distance",
                            value: String(format: "%.2f km", session.totalDistanceKm),
                            icon: "point.topleft.down.to.point.bottomright.curvepath"
                        )
                        StatCard(
                            title: "Duration",
                            value: formattedDuration,
                            icon: "timer"
                        )
                    }

                    HStack(spacing: 32) {
                        StatCard(
                            title: "Max Speed",
                            value: String(format: "%.1f kts", session.maxSpeedKnots),
                            icon: "gauge.with.dots.needle.67percent"
                        )
                        StatCard(
                            title: "Max Speed",
                            value: String(format: "%.1f km/h", session.maxSpeedKmh),
                            icon: "gauge.with.dots.needle.67percent"
                        )
                    }
                }
                .padding(.horizontal)

                if !isReview {
                    // Save / Discard buttons
                    VStack(spacing: 12) {
                        Button {
                            sessionStore.save(session)
                            navigationPath = NavigationPath()
                        } label: {
                            Label("Save Session", systemImage: "square.and.arrow.down")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }

                        Button {
                            navigationPath = NavigationPath()
                        } label: {
                            Label("Discard Session", systemImage: "trash")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.gray.opacity(0.2))
                                .foregroundStyle(.red)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                    }
                    .padding(.horizontal, 32)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationTitle(isReview ? "Session Details" : "Session Complete")
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

struct StatCard: View {
    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct SpeedLegendView: View {
    var body: some View {
        HStack(spacing: 8) {
            LegendItem(color: .green, label: "<5 kts")
            LegendItem(color: .yellow, label: "5-10")
            LegendItem(color: .orange, label: "10-15")
            LegendItem(color: Color(red: 1.0, green: 0.4, blue: 0.0), label: "15-20")
            LegendItem(color: .red, label: "20-25")
            LegendItem(color: .purple, label: "25+")
        }
        .font(.caption2)
    }
}

struct LegendItem: View {
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 2) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(height: 4)
            Text(label)
                .foregroundStyle(.secondary)
        }
    }
}
