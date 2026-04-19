import SwiftUI

struct WatchSessionListView: View {
    @Environment(WatchSessionStore.self) private var sessionStore

    var body: some View {
        Group {
            if sessionStore.sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions",
                    systemImage: "wind",
                    description: Text("Start a session to begin tracking.")
                )
            } else {
                List {
                    ForEach(sessionStore.sessions) { session in
                        NavigationLink {
                            WatchSessionSummaryView(
                                session: session,
                                isTrackingActive: .constant(false),
                                isReview: true
                            )
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                Text(String(format: "%.1f kts max", session.maxSpeedKnots))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete { offsets in
                        sessionStore.delete(at: offsets)
                    }
                }
            }
        }
        .navigationTitle("Sessions")
    }
}
