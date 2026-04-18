import SwiftUI

// MARK: - Word Selection

struct WordSelectionView: View {
    @ObservedObject var selectedWords: SelectedWords
    let onDone: () -> Void

    // The grid uses 1pt spacing and a gray container bg to produce hairline dividers.
    private let columns = [GridItem(.adaptive(minimum: 78, maximum: 120), spacing: 1)]
    private let dividerColor = Color(red: 0.78, green: 0.78, blue: 0.82)

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
                // The 1pt spacing + dividerColor background creates hairline dividers.
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 1) {
                        ForEach(DolchWords.words, id: \.self) { word in
                            WordCell(
                                word: word,
                                isSelected: selectedWords.words.contains(word),
                                onTap: { selectedWords.toggle(word) }
                            )
                        }
                    }
                    .background(dividerColor)
                    // Top hairline above the grid
                    .overlay(
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(dividerColor),
                        alignment: .top
                    )
                    .padding(.bottom, 110)
                }
            }

            // Go! / Go Back! button — sticky at bottom
            Button(action: onDone) {
                HStack(spacing: 10) {
                    Image(systemName: "play.fill")
                    Text(buttonLabel)
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
                .animation(.easeInOut(duration: 0.15), value: buttonLabel)
            }
            .disabled(selectedWords.isEmpty)
            .animation(.easeInOut(duration: 0.18), value: selectedWords.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
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
