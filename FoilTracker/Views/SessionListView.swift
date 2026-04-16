import SwiftUI

struct SessionListView: View {
    @Environment(SessionStore.self) private var sessionStore
    @Binding var navigationPath: NavigationPath
    @State private var sessionToDelete: Session?

    var body: some View {
        Group {
            if sessionStore.sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "wind",
                    description: Text("Start a new session to track your ride!")
                )
            } else {
                List {
                    ForEach(sessionStore.sessions) { session in
                        Button {
                            navigationPath.append(AppRoute.sessionDetail(session))
                        } label: {
                            SessionRowView(session: session)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                sessionToDelete = session
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Previous Sessions")
        .alert("Delete Session?", isPresented: Binding(
            get: { sessionToDelete != nil },
            set: { if !$0 { sessionToDelete = nil } }
        )) {
            Button("Cancel", role: .cancel) {
                sessionToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let session = sessionToDelete,
                   let index = sessionStore.sessions.firstIndex(where: { $0.id == session.id }) {
                    sessionStore.delete(at: IndexSet(integer: index))
                }
                sessionToDelete = nil
            }
        } message: {
            Text("Are you sure you want to delete this session? This cannot be undone.")
        }
    }
}

struct SessionRowView: View {
    let session: Session

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(session.startDate.formatted(date: .abbreviated, time: .shortened))
                .font(.headline)

            if let locationName = session.locationName {
                Label(locationName, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 16) {
                Label(String(format: "%.1f kts max", session.maxSpeedKnots), systemImage: "gauge.with.dots.needle.67percent")
                Label(String(format: "%.2f km", session.totalDistanceKm), systemImage: "point.topleft.down.to.point.bottomright.curvepath")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}
