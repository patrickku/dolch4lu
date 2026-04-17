import SwiftUI

struct NameEntryView: View {
    @ObservedObject var settings: UserSettings
    @State private var nameInput = ""
    @FocusState private var fieldFocused: Bool

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.45, green: 0.20, blue: 0.85),
                         Color(red: 0.15, green: 0.55, blue: 0.90)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 36) {
                Spacer()

                Text("👋")
                    .font(.system(size: 80))

                Text("Welcome!")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                Text("What's your name?")
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                TextField("Type your name…", text: $nameInput)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 20)
                    .background(Color.white)
                    .cornerRadius(18)
                    .padding(.horizontal, 40)
                    .focused($fieldFocused)
                    .submitLabel(.done)
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.words)
                    .onSubmit { saveName() }

                Button(action: saveName) {
                    Text("Let's Go! 🚀")
                        .font(.system(size: 30, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.20, blue: 0.85))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 16)
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                }
                .disabled(nameInput.trimmingCharacters(in: .whitespaces).isEmpty)
                .opacity(nameInput.trimmingCharacters(in: .whitespaces).isEmpty ? 0.45 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: nameInput.isEmpty)

                Spacer()
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                fieldFocused = true
            }
        }
    }

    private func saveName() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        settings.userName = trimmed
    }
}
