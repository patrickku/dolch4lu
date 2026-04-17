import Foundation
import Combine

class UserSettings: ObservableObject {
    @Published var userName: String {
        didSet {
            UserDefaults.standard.set(userName, forKey: "dolch_userName")
        }
    }

    var isFirstLaunch: Bool {
        userName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init() {
        self.userName = UserDefaults.standard.string(forKey: "dolch_userName") ?? ""
    }
}
