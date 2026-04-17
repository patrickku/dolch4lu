import SwiftUI

struct ContentView: View {
    @StateObject private var settings = UserSettings()
    @StateObject private var speech = SpeechManager()

    var body: some View {
        Group {
            if settings.isFirstLaunch {
                NameEntryView(settings: settings)
            } else {
                FlashCardView(speech: speech, userName: settings.userName)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: settings.isFirstLaunch)
    }
}
