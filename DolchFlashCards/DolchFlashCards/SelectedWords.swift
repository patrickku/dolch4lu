import Foundation

class SelectedWords: ObservableObject {
    @Published var words: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(words), forKey: "dolch_selectedWords")
        }
    }

    // The set that was last confirmed by pressing "Go!" — used for routing and "Go Back!" label.
    @Published private(set) var confirmedWords: Set<String>

    var isEmpty: Bool { words.isEmpty }
    var isConfigured: Bool { !confirmedWords.isEmpty }

    func toggle(_ word: String) {
        if words.contains(word) {
            words.remove(word)
        } else {
            words.insert(word)
        }
    }

    func selectAll() {
        words = Set(DolchWords.words)
    }

    func clearAll() {
        words = []
    }

    /// Call when the teacher presses "Go!" — locks in the current selection.
    func confirm() {
        confirmedWords = words
        UserDefaults.standard.set(Array(confirmedWords), forKey: "dolch_confirmedWords")
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "dolch_selectedWords") ?? []
        let confirmed = UserDefaults.standard.stringArray(forKey: "dolch_confirmedWords") ?? []
        self.words = Set(saved)
        self.confirmedWords = Set(confirmed)
    }
}
