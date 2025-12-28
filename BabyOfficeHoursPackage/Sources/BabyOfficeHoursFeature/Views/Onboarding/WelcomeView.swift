import SwiftUI

/// Initial welcome screen during onboarding
struct WelcomeView: View {
    let onCreateBaby: () -> Void
    let onJoinInvite: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App branding
            VStack(spacing: 16) {
                Text("👶")
                    .font(.system(size: 100))

                Text("Baby Office Hours")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Let family know when baby\nis ready for FaceTime")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            // Action buttons
            VStack(spacing: 12) {
                Button {
                    onCreateBaby()
                } label: {
                    Label("I'm a Parent", systemImage: "person.badge.plus")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
                .buttonBorderShape(.roundedRectangle(radius: 14))

                Button {
                    onJoinInvite()
                } label: {
                    Label("I Have an Invite", systemImage: "envelope.open")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.roundedRectangle(radius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    WelcomeView(
        onCreateBaby: {},
        onJoinInvite: {}
    )
}
