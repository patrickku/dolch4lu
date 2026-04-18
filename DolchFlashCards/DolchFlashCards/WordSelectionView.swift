import SwiftUI

// MARK: - Word Selection

struct WordSelectionView: View {
    @ObservedObject var selectedWords: SelectedWords
    let onDone: () -> Void
    let onCancel: (() -> Void)?

    private let columns = [GridItem(.adaptive(minimum: 88, maximum: 128), spacing: 10)]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.97, green: 0.96, blue: 1.0).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                ZStack {
                    Text("Choose Words")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 0.40, green: 0.16, blue: 0.82))

                    HStack {
                        if let cancel = onCancel {
                            Button(action: cancel) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(Color(.systemGray3))
                            }
                            .padding(.leading, 16)
                        }
                        Spacer()
                    }
                }
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
                .padding(.bottom, 12)

                // Word grid
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(DolchWords.words, id: \.self) { word in
                            WordChip(
                                word: word,
                                isSelected: selectedWords.words.contains(word),
                                onTap: { selectedWords.toggle(word) }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 110)
                }
            }

            // Go! button — sticky at bottom
            Button(action: onDone) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text("Go!")
                }
                .font(.system(size: 26, weight: .black, design: .rounded))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    selectedWords.isEmpty
                        ? Color(.systemGray3)
                        : Color(red: 0.13, green: 0.70, blue: 0.45)
                )
                .cornerRadius(18)
                .shadow(color: .black.opacity(0.18), radius: 8, x: 0, y: 4)
            }
            .disabled(selectedWords.isEmpty)
            .animation(.easeInOut(duration: 0.18), value: selectedWords.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
    }
}

// MARK: - Word Chip

struct WordChip: View {
    let word: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(word)
                .font(.system(size: 17, weight: isSelected ? .bold : .regular, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(red: 0.18, green: 0.18, blue: 0.22))
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected
                        ? Color(red: 0.40, green: 0.16, blue: 0.82)
                        : Color.white
                )
                .cornerRadius(11)
                .overlay(
                    RoundedRectangle(cornerRadius: 11)
                        .stroke(
                            isSelected ? Color.clear : Color(red: 0.84, green: 0.84, blue: 0.88),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: isSelected
                        ? Color(red: 0.40, green: 0.16, blue: 0.82).opacity(0.35)
                        : Color.black.opacity(0.06),
                    radius: isSelected ? 5 : 2,
                    x: 0, y: 2
                )
        }
        .animation(.spring(response: 0.22, dampingFraction: 0.72), value: isSelected)
    }
}
