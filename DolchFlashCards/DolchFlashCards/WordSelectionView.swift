import SwiftUI

// MARK: - Word Selection

struct WordSelectionView: View {
    @ObservedObject var selectedWords: SelectedWords
    @ObservedObject var settings: UserSettings
    let onDone: () -> Void

    // No spacing — cells butt up against each other; selection color alone distinguishes state.
    private let columns = [GridItem(.adaptive(minimum: 78, maximum: 120), spacing: 0)]

    @State private var nameInput = ""
    @State private var showNameError = false

    private var buttonLabel: String {
        selectedWords.words == selectedWords.confirmedWords ? "Go Back!" : "Go!"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.97, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                Text("Choose Words")
                    .font(.system(size: 24, weight: .black, design: .rounded))
                    .foregroundColor(Color(red: 0.40, green: 0.16, blue: 0.82))
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                // Select All / Clear / Count row
                HStack(spacing: 12) {
                    Button(action: { selectedWords.selectAll() }) {
                        Text("Select All")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.40, green: 0.16, blue: 0.82))
                            .cornerRadius(20)
                    }

                    Button(action: { selectedWords.clearAll() }) {
                        Text("Clear")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.40, green: 0.16, blue: 0.82))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(Color(red: 0.40, green: 0.16, blue: 0.82).opacity(0.12))
                            .cornerRadius(20)
                    }

                    Spacer()

                    Text("\(selectedWords.words.count) selected")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 10)

                // Word grid — no outer horizontal padding so it runs edge-to-edge.
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(DolchWords.words.sorted(), id: \.self) { word in
                            WordCell(
                                word: word,
                                isSelected: selectedWords.words.contains(word),
                                onTap: { selectedWords.toggle(word) }
                            )
                        }
                    }
                    .environment(\.layoutDirection, .rightToLeft)
                    .padding(.bottom, 210)
                }
            }

            // Bottom sticky area: student name field + Go button
            VStack(spacing: 0) {
                Divider()
                    .padding(.bottom, 12)

                // Student name row
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 10) {
                        Text("Student")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(.label))
                            .fixedSize()

                        TextField("Enter student name", text: $nameInput)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                            .colorScheme(.light)
                            .onChange(of: nameInput) { _ in
                                if showNameError && !nameInput.trimmingCharacters(in: .whitespaces).isEmpty {
                                    showNameError = false
                                }
                            }
                    }
                    .padding(.horizontal, 24)

                    if showNameError {
                        Text("Student name cannot be blank.")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.red)
                            .padding(.horizontal, 24)
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: showNameError)
                .padding(.bottom, 12)

                // Go! / Go Back! / disabled button
                Button(action: handleGoTap) {
                    Group {
                        if selectedWords.isEmpty {
                            Text("Select one or more words")
                                .font(.system(size: 20, weight: .black, design: .rounded))
                        } else {
                            HStack(spacing: 10) {
                                Image(systemName: "play.fill")
                                Text(buttonLabel)
                            }
                            .font(.system(size: 26, weight: .black, design: .rounded))
                        }
                    }
                    .foregroundColor(selectedWords.isEmpty ? Color(.systemGray) : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        selectedWords.isEmpty
                            ? Color(.systemGray5)
                            : Color(red: 0.13, green: 0.70, blue: 0.45)
                    )
                    .cornerRadius(18)
                    .shadow(
                        color: selectedWords.isEmpty ? .clear : .black.opacity(0.18),
                        radius: 8, x: 0, y: 4
                    )
                    .animation(.easeInOut(duration: 0.15), value: selectedWords.isEmpty)
                }
                .disabled(selectedWords.isEmpty)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .background(Color(red: 0.97, green: 0.96, blue: 1.0))
        }
        .onAppear {
            nameInput = settings.userName
        }
    }

    private func handleGoTap() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            withAnimation { showNameError = true }
            return
        }
        settings.userName = trimmed
        onDone()
    }
}

// MARK: - Word Cell

struct WordCell: View {
    let word: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Text(word)
            .font(.system(size: 16, weight: isSelected ? .bold : .regular, design: .rounded))
            .foregroundColor(isSelected ? .white : Color(red: 0.18, green: 0.18, blue: 0.22))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(isSelected ? Color(red: 0.40, green: 0.16, blue: 0.82) : Color.white)
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)
            .animation(.easeInOut(duration: 0.13), value: isSelected)
    }
}
