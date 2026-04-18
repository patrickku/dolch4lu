import Foundation

class SelectedWords: ObservableObject {
    @Published var words: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(words), forKey: "dolch_selectedWords")
        }
    }

    var isEmpty: Bool { words.isEmpty }

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

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "dolch_selectedWords") ?? []
        self.words = Set(saved)
    }
}
