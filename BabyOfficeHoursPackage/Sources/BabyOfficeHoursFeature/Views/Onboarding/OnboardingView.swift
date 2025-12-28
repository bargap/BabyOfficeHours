import SwiftUI

/// Container view that manages the onboarding flow
struct OnboardingView: View {
    @Environment(AppState.self) private var appState

    enum Step {
        case welcome
        case createBaby
        case joinInvite
    }

    @State private var currentStep: Step = .welcome

    var body: some View {
        Group {
            switch currentStep {
            case .welcome:
                WelcomeView(
                    onCreateBaby: {
                        withAnimation {
                            currentStep = .createBaby
                        }
                    },
                    onJoinInvite: {
                        withAnimation {
                            currentStep = .joinInvite
                        }
                    }
                )

            case .createBaby:
                CreateBabyView()

            case .joinInvite:
                EnterInviteCodeView(
                    onBack: {
                        withAnimation {
                            currentStep = .welcome
                        }
                    }
                )
            }
        }
    }
}

/// View for entering an invite code to join a baby's circle
struct EnterInviteCodeView: View {
    @Environment(AppState.self) private var appState
    let onBack: () -> Void

    @State private var inviteCode: String = ""
    @State private var isValidating = false
    @State private var errorMessage: String?
    @State private var joinData: JoinData?
    @FocusState private var isCodeFieldFocused: Bool

    struct JoinData: Identifiable {
        let id = UUID()
        let baby: Baby
        let role: InviteRole
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            headerSection
            codeInputSection

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }

            Spacer()

            buttonSection
        }
        .padding()
        .sheet(item: $joinData) { data in
            JoinBabyView(baby: data.baby, role: data.role)
                .environment(appState)
        }
        .onAppear {
            isCodeFieldFocused = true
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "envelope.open")
                .font(.system(size: 60))
                .foregroundStyle(.tint)

            Text("Enter Invite Code")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Paste the invite link or code you received")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var codeInputSection: some View {
        VStack(spacing: 8) {
            TextField("babyofficehours://invite/...", text: $inviteCode)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isCodeFieldFocused)
                .onChange(of: inviteCode) { _, _ in
                    errorMessage = nil
                }

            Text("Example: babyofficehours://invite/abc123")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private var buttonSection: some View {
        VStack(spacing: 12) {
            Button {
                validateCode()
            } label: {
                HStack {
                    if isValidating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Continue")
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(inviteCode.isEmpty || isValidating)

            Button("Go Back") {
                onBack()
            }
            .buttonStyle(.bordered)

            // Demo button for testing
            Button {
                simulateDemoInvite()
            } label: {
                Label("Try Demo Invite", systemImage: "sparkles")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .padding(.top, 8)
        }
        .padding(.bottom, 32)
    }

    // MARK: - Actions

    private func validateCode() {
        isValidating = true
        errorMessage = nil

        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            isValidating = false

            // In production, this would validate against Firebase
            // For now, we'll show an error for invalid codes
            if inviteCode.contains("invite/") {
                // Extract the code part and pretend it's valid
                simulateDemoInvite()
            } else {
                errorMessage = "Invalid invite code. Please check and try again."
            }
        }
    }

    private func simulateDemoInvite() {
        // Create a demo baby and show the join flow
        let demoBaby = Baby(name: "Demo Baby", createdBy: UUID())
        appState.babies.append(demoBaby)
        joinData = JoinData(baby: demoBaby, role: .subscriber)
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}

#Preview("Enter Invite Code") {
    EnterInviteCodeView(onBack: {})
        .environment(AppState())
}
