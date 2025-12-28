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
                // Placeholder for join invite flow (Feature 5)
                JoinInvitePlaceholderView {
                    withAnimation {
                        currentStep = .welcome
                    }
                }
            }
        }
    }
}

/// Temporary placeholder for the join invite flow
private struct JoinInvitePlaceholderView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🔗")
                .font(.system(size: 80))

            Text("Join via Invite")
                .font(.title2)
                .fontWeight(.semibold)

            Text("This feature will be available\nwhen you receive an invite link")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button("Go Back") {
                onBack()
            }
            .buttonStyle(.bordered)
            .padding(.bottom, 32)
        }
    }
}

#Preview {
    OnboardingView()
        .environment(AppState())
}
