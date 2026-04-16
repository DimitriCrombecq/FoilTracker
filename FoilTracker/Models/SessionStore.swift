import Foundation
import SwiftUI

@Observable
class SessionStore {
    private(set) var sessions: [Session] = []
    private let saveKey = "saved_sessions"

    init() {
        load()
    }

    func save(_ session: Session) {
        sessions.insert(session, at: 0)
        persist()
    }

    func delete(at offsets: IndexSet) {
        sessions.remove(atOffsets: offsets)
        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: saveKey),
              let decoded = try? JSONDecoder().decode([Session].self, from: data) else { return }
        sessions = decoded
    }
}
