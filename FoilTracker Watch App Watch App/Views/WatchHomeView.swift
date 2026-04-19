import SwiftUI

struct WatchHomeView: View {
    @State private var locationManager = WatchLocationManager()
    @State private var sessionStore = WatchSessionStore()
    @State private var isTrackingActive = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "wind")
                    .font(.system(size: 40))
                    .foregroundStyle(.blue)

                Text("FoilTracker")
                    .font(.headline)

                Button {
                    locationManager.requestPermissions()
                    locationManager.startSession()
                    isTrackingActive = true
                } label: {
                    Label("Start", systemImage: "play.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)

                NavigationLink {
                    WatchSessionListView()
                } label: {
                    Label("Sessions", systemImage: "list.bullet")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .navigationDestination(isPresented: $isTrackingActive) {
                WatchActiveSessionView(
                    locationManager: locationManager,
                    isTrackingActive: $isTrackingActive
                )
            }
        }
        .environment(sessionStore)
    }
}
