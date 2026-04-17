import Foundation

struct DolchWords {
    static let words: [String] = [
        "by", "at", "a", "it", "cold", "in", "I", "be", "big", "call",
        "did", "good", "do", "go", "before", "all", "are", "any", "an", "live",
        "had", "have", "him", "drink", "her", "its", "is", "into", "if", "down",
        "ask", "may", "as", "am", "give", "many", "cut", "keep", "knew", "came",
        "does", "goes", "going", "and", "fall", "has", "he", "his", "far", "best",
        "but", "jump", "just", "buy", "like", "black", "kind", "blue", "find", "here",
        "fast", "first", "ate", "eat", "done", "help", "hot", "both", "hold", "get",
        "brown", "grow", "bring", "green", "carry", "four", "every", "found", "eight", "could",
        "from", "make", "for", "made", "five", "around", "let", "always", "don't", "better",
        "long", "again", "little", "look", "laugh", "away", "can", "after", "about", "how"
    ]

    static func random(excluding current: String? = nil) -> String {
        guard words.count > 1, let current = current else {
            return words.randomElement()!
        }
        var next: String
        repeat {
            next = words.randomElement()!
        } while next == current
        return next
    }
}
