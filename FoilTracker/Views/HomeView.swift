import SwiftUI

enum AppRoute: Hashable {
    case newSession
    case sessionList
    case sessionDetail(Session)
}

struct HomeView: View {
    @State private var navigationPath = NavigationPath()
    @State private var locationManager = LocationManager()
    @State private var sessionStore = SessionStore()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "wind")
                    .font(.system(size: 80))
                    .foregroundStyle(.blue)

                Text("FoilTracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        locationManager.requestPermission()
                        locationManager.startSession()
                        navigationPath.append(AppRoute.newSession)
                    } label: {
                        Label("Start New Session", systemImage: "play.fill")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.blue)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }

                    Button {
                        navigationPath.append(AppRoute.sessionList)
                    } label: {
                        Label("Previous Sessions", systemImage: "list.bullet")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.gray.opacity(0.2))
                            .foregroundStyle(.primary)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
            }
            .navigationDestination(for: AppRoute.self) { route in
                switch route {
                case .newSession:
                    ActiveSessionView(locationManager: locationManager, navigationPath: $navigationPath)
                case .sessionList:
                    SessionListView(navigationPath: $navigationPath)
                case .sessionDetail(let session):
                    SessionSummaryView(session: session, navigationPath: $navigationPath, isReview: true)
                }
            }
        }
        .environment(sessionStore)
    }
}
