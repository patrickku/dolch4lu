import SwiftUI

// MARK: - Color palette

extension Color {
    static let cardColors: [Color] = [
        Color(red: 0.93, green: 0.26, blue: 0.31), // red
        Color(red: 0.16, green: 0.58, blue: 0.88), // blue
        Color(red: 0.13, green: 0.70, blue: 0.45), // green
        Color(red: 0.95, green: 0.60, blue: 0.08), // orange
        Color(red: 0.58, green: 0.22, blue: 0.87), // purple
        Color(red: 0.08, green: 0.66, blue: 0.70), // teal
        Color(red: 0.93, green: 0.33, blue: 0.64), // pink
        Color(red: 0.40, green: 0.74, blue: 0.16), // lime
    ]
}

// MARK: - Transition styles

private enum CardTransition: CaseIterable {
    case flip, zoomBounce, slideUp, spinScale
}

// MARK: - FlashCardView

struct FlashCardView: View {
    @ObservedObject var speech: SpeechManager
    @ObservedObject var settings: UserSettings
    let wordList: [String]
    let onConfigTap: () -> Void

    @State private var currentWord: String
    @State private var bgColor: Color
    @State private var colorIndex: Int

    // Animation state
    @State private var wordScale: CGFloat = 1.0
    @State private var wordOpacity: Double = 1.0
    @State private var wordRotationY: Double = 0
    @State private var wordRotationZ: Double = 0
    @State private var wordOffsetY: CGFloat = 0
    @State private var isTransitioning = false

    // Password sheet
    @State private var showPasswordSheet = false

    init(speech: SpeechManager, settings: UserSettings, wordList: [String], onConfigTap: @escaping () -> Void) {
        self.speech = speech
        self.settings = settings
        self.wordList = wordList
        self.onConfigTap = onConfigTap
        let first = wordList.randomElement() ?? DolchWords.words[0]
        let startIdx = Int.random(in: 0..<Color.cardColors.count)
        _currentWord = State(initialValue: first)
        _colorIndex = State(initialValue: startIdx)
        _bgColor = State(initialValue: Color.cardColors[startIdx])
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background
                bgColor
                    .ignoresSafeArea()

                // Full-screen tap target (excludes the gear button area)
                Color.clear
                    .contentShape(Rectangle())
                    .onTapGesture {
                        guard !isTransitioning else { return }
                        advanceWord()
                    }

                // Word
                VStack {
                    Spacer()
                    Text(currentWord)
                        .font(.system(
                            size: wordFontSize(for: currentWord, in: geo.size),
                            weight: .black,
                            design: .rounded
                        ))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.3)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                        .shadow(color: .black.opacity(0.25), radius: 6, x: 0, y: 4)
                        .scaleEffect(wordScale)
                        .opacity(wordOpacity)
                        .rotation3DEffect(.degrees(wordRotationY), axis: (x: 0, y: 1, z: 0))
                        .rotationEffect(.degrees(wordRotationZ))
                        .offset(y: wordOffsetY)
                    Spacer()
                }

                // Gear button — top left (password-protected)
                VStack {
                    HStack {
                        Button(action: { showPasswordSheet = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white.opacity(0.45))
                                .padding(20)
                        }
                        .contentShape(Rectangle())
                        Spacer()
                    }
                    Spacer()
                }

                // Hear-word button — bottom trailing
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: { speech.speakWord(currentWord) }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.18))
                                    .frame(width: 78, height: 78)
                                Image(systemName: "speaker.wave.3.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(.white)
                                    .opacity(speech.isSpeaking ? 0.55 : 1.0)
                                    .animation(.easeInOut(duration: 0.3), value: speech.isSpeaking)
                            }
                        }
                        .padding(.trailing, 28)
                        .padding(.bottom, 36)
                        .accessibilityLabel("Hear the word")
                    }
                }
            }
        }
        .sheet(isPresented: $showPasswordSheet) {
            PasswordSheet(isPresented: $showPasswordSheet, onSuccess: onConfigTap)
        }
    }

    // MARK: - Font sizing

    private func wordFontSize(for word: String, in size: CGSize) -> CGFloat {
        let base = min(size.width, size.height)
        switch word.count {
        case 1...2:  return min(base * 0.60, 220)
        case 3...4:  return min(base * 0.52, 190)
        case 5...6:  return min(base * 0.44, 160)
        case 7...8:  return min(base * 0.36, 130)
        default:     return min(base * 0.30, 110)
        }
    }

    // MARK: - Transition

    private func advanceWord() {
        isTransitioning = true
        speech.stop()

        let style = CardTransition.allCases.randomElement()!
        let newWord = DolchWords.random(from: wordList, excluding: currentWord)
        var newColorIndex: Int
        repeat {
            newColorIndex = Int.random(in: 0..<Color.cardColors.count)
        } while newColorIndex == colorIndex
        let newColor = Color.cardColors[newColorIndex]

        switch style {
        case .flip:       playFlip(newWord: newWord, newColor: newColor, newIndex: newColorIndex)
        case .zoomBounce: playZoomBounce(newWord: newWord, newColor: newColor, newIndex: newColorIndex)
        case .slideUp:    playSlideUp(newWord: newWord, newColor: newColor, newIndex: newColorIndex)
        case .spinScale:  playSpinScale(newWord: newWord, newColor: newColor, newIndex: newColorIndex)
        }
    }

    private func playFlip(newWord: String, newColor: Color, newIndex: Int) {
        withAnimation(.easeIn(duration: 0.22)) {
            wordRotationY = 90
            wordOpacity = 0.1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
            currentWord = newWord; bgColor = newColor; colorIndex = newIndex
            wordRotationY = -90
            withAnimation(.spring(response: 0.38, dampingFraction: 0.7)) {
                wordRotationY = 0; wordOpacity = 1.0
            }
            finishTransition()
        }
    }

    private func playZoomBounce(newWord: String, newColor: Color, newIndex: Int) {
        withAnimation(.easeIn(duration: 0.18)) {
            wordScale = 0.05; wordOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.19) {
            currentWord = newWord; bgColor = newColor; colorIndex = newIndex
            wordScale = 0.05
            withAnimation(.spring(response: 0.42, dampingFraction: 0.55)) {
                wordScale = 1.0; wordOpacity = 1.0
            }
            finishTransition()
        }
    }

    private func playSlideUp(newWord: String, newColor: Color, newIndex: Int) {
        withAnimation(.easeIn(duration: 0.20)) {
            wordOffsetY = -500; wordOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.21) {
            currentWord = newWord; bgColor = newColor; colorIndex = newIndex
            wordOffsetY = 500; wordOpacity = 0
            withAnimation(.spring(response: 0.40, dampingFraction: 0.68)) {
                wordOffsetY = 0; wordOpacity = 1.0
            }
            finishTransition()
        }
    }

    private func playSpinScale(newWord: String, newColor: Color, newIndex: Int) {
        withAnimation(.easeIn(duration: 0.22)) {
            wordScale = 0.1; wordRotationZ = 180; wordOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.23) {
            currentWord = newWord; bgColor = newColor; colorIndex = newIndex
            wordRotationZ = -180; wordScale = 0.1
            withAnimation(.spring(response: 0.45, dampingFraction: 0.60)) {
                wordScale = 1.0; wordRotationZ = 0; wordOpacity = 1.0
            }
            finishTransition()
        }
    }

    private func finishTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            isTransitioning = false
        }
    }
}

// MARK: - Password Sheet

private struct PasswordSheet: View {
    @Binding var isPresented: Bool
    let onSuccess: () -> Void

    @State private var input = ""
    @State private var showError = false
    @FocusState private var focused: Bool

    private let correctPassword = "Lucia"

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "lock.fill")
                .font(.system(size: 44))
                .foregroundColor(Color(red: 0.40, green: 0.16, blue: 0.82))

            Text("Teacher Access")
                .font(.system(size: 28, weight: .black, design: .rounded))
                .foregroundColor(Color(.secondaryLabel))

            VStack(spacing: 10) {
                SecureField("Password", text: $input)
                    .font(.system(size: 22, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .background(Color(.systemGray6))
                    .cornerRadius(14)
                    .focused($focused)
                    .onSubmit { verify() }

                if showError {
                    Text("Incorrect password. Try again.")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                        .transition(.opacity)
                }
            }
            .padding(.horizontal, 32)
            .animation(.easeInOut(duration: 0.2), value: showError)

            HStack(spacing: 14) {
                Button("Cancel") {
                    isPresented = false
                }
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(Color(.systemGray))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(Color(.systemGray5))
                .cornerRadius(14)

                Button("Enter") { verify() }
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(input.isEmpty ? Color(.systemGray3) : Color(red: 0.40, green: 0.16, blue: 0.82))
                    .cornerRadius(14)
                    .disabled(input.isEmpty)
                    .animation(.easeInOut(duration: 0.15), value: input.isEmpty)
            }
            .padding(.horizontal, 32)

            Spacer()
        }
        .onAppear {
            focused = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { focused = true }
        }
    }

    private func verify() {
        if input == correctPassword {
            isPresented = false
            onSuccess()
        } else {
            withAnimation { showError = true }
            input = ""
            focused = true
        }
    }
}
