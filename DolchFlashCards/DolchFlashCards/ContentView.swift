import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @StateObject private var speech = SpeechManager()
    @StateObject private var selectedWords = SelectedWords()
    @State private var showWordSelection = false

    var body: some View {
        Group {
            if settings.isFirstLaunch {
                NameEntryView(settings: settings)
            } else if !selectedWords.isConfigured || showWordSelection {
                // Only leave this screen by pressing Go! (which calls confirm())
                WordSelectionView(
                    selectedWords: selectedWords,
                    settings: settings,
                    onDone: {
                        selectedWords.confirm()
                        showWordSelection = false
                    }
                )
            } else {
                FlashCardView(
                    speech: speech,
                    settings: settings,
                    wordList: Array(selectedWords.confirmedWords),
                    onConfigTap: { showWordSelection = true }
                )
            }
        }
    }
}
