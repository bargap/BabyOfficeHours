import SwiftUI

/// View for creating a new baby profile during onboarding
struct CreateBabyView: View {
    @Environment(AppState.self) private var appState
    @State private var babyName: String = ""
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Header
            VStack(spacing: 12) {
                Text("👶")
                    .font(.system(size: 80))

                Text("Create your baby's profile")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This is how family will see them")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Name input
            VStack(spacing: 8) {
                TextField("Baby's name", text: $babyName)
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .textInputAutocapitalization(.words)
                    .focused($isNameFieldFocused)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.quaternary)
                    )
                    .padding(.horizontal, 40)
            }

            Spacer()

            // Create button
            Button {
                createBaby()
            } label: {
                Text("Create Profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))
            .disabled(babyName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .onAppear {
            isNameFieldFocused = true
        }
    }

    private func createBaby() {
        let trimmedName = babyName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        _ = appState.createBaby(name: trimmedName)
    }
}

#Preview {
    CreateBabyView()
        .environment(AppState())
}
