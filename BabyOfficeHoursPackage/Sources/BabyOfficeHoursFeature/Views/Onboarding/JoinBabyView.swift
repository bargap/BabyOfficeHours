import SwiftUI

/// View for accepting an invite to join a baby's circle
struct JoinBabyView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let baby: Baby
    let role: InviteRole

    @State private var userName: String = ""
    @State private var isJoining = false
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                headerSection
                formSection
                Spacer()
                joinButton
            }
            .padding()
            .navigationTitle("Join Office Hours")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            // Baby avatar
            ZStack {
                Circle()
                    .fill(.blue.opacity(0.1))
                    .frame(width: 100, height: 100)

                Text("👶")
                    .font(.system(size: 48))
            }

            VStack(spacing: 8) {
                Text("Join \(baby.name)'s Office Hours?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)

                Text(roleDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Role badge
            HStack {
                Image(systemName: role == .parent ? "person.badge.key" : "eye")
                Text(role == .parent ? "Co-Parent Access" : "View Only")
            }
            .font(.caption)
            .foregroundStyle(role == .parent ? .orange : .blue)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(role == .parent ? .orange.opacity(0.1) : .blue.opacity(0.1))
            )
        }
        .padding(.top)
    }

    private var formSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField("Enter your name", text: $userName)
                .textFieldStyle(.roundedBorder)
                .textContentType(.name)
                .autocorrectionDisabled()
                .focused($isNameFieldFocused)

            Text("This is how you'll appear to \(baby.name)'s parents")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.quaternary.opacity(0.5))
        )
    }

    private var joinButton: some View {
        Button {
            joinBaby()
        } label: {
            HStack {
                if isJoining {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text("Join \(baby.name)'s Circle")
                }
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .disabled(userName.trimmingCharacters(in: .whitespaces).isEmpty || isJoining)
    }

    // MARK: - Computed Properties

    private var roleDescription: String {
        switch role {
        case .parent:
            return "You'll be able to toggle \(baby.name)'s availability and manage subscribers."
        case .subscriber:
            return "You'll see when \(baby.name) is available for FaceTime calls."
        }
    }

    // MARK: - Actions

    private func joinBaby() {
        isJoining = true

        // Small delay for UX feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            appState.joinBaby(baby, as: role, userName: userName.trimmingCharacters(in: .whitespaces))
            dismiss()
        }
    }
}

// MARK: - Previews

#Preview("Join as Subscriber") {
    let appState = AppState()
    let baby = Baby(name: "Emma", createdBy: UUID())
    return JoinBabyView(baby: baby, role: .subscriber)
        .environment(appState)
}

#Preview("Join as Co-Parent") {
    let appState = AppState()
    let baby = Baby(name: "Emma", createdBy: UUID())
    return JoinBabyView(baby: baby, role: .parent)
        .environment(appState)
}
