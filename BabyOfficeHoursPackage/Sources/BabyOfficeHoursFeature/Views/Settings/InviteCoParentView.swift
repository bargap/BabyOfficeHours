import SwiftUI

/// View for creating and sharing a co-parent invite
struct InviteCoParentView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let baby: Baby

    @State private var currentInvite: Invite?
    @State private var showingShareSheet = false
    @State private var showingSimulateSuccess = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                headerSection
                inviteSection
                Spacer()
                actionButtons
            }
            .padding()
            .navigationTitle("Invite Co-Parent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                createInviteIfNeeded()
            }
            .sheet(isPresented: $showingShareSheet) {
                if let invite = currentInvite {
                    ShareSheet(items: [inviteMessage(for: invite)])
                }
            }
            .alert("Invite Accepted!", isPresented: $showingSimulateSuccess) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("A co-parent has been added to \(baby.name)'s profile. They can now toggle availability from their device.")
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Invite a Co-Parent")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Share this invite with your partner so they can also toggle \(baby.name)'s availability.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top)
    }

    private var inviteSection: some View {
        VStack(spacing: 16) {
            if let invite = currentInvite {
                // Invite code display
                VStack(spacing: 8) {
                    Text("Invite Link")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(invite.shareableCode)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(.quaternary)
                        )
                }

                // Expiration info
                if let expiresAt = invite.expiresAt {
                    HStack {
                        Image(systemName: "clock")
                        Text("Expires \(expiresAt, style: .relative)")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            } else {
                ProgressView()
                    .padding()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.background)
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            // Share button
            Button {
                showingShareSheet = true
            } label: {
                Label("Share Invite", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(currentInvite == nil)

            // Copy button
            Button {
                copyToClipboard()
            } label: {
                Label("Copy Link", systemImage: "doc.on.doc")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .disabled(currentInvite == nil)

            // Simulate acceptance (for testing)
            Button {
                simulateAcceptance()
            } label: {
                Label("Simulate Acceptance", systemImage: "checkmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .tint(.green)
            .disabled(currentInvite == nil)
        }
    }

    // MARK: - Actions

    private func createInviteIfNeeded() {
        if currentInvite == nil {
            currentInvite = appState.createCoParentInvite(for: baby)
        }
    }

    private func inviteMessage(for invite: Invite) -> String {
        """
        Join me as a co-parent for \(baby.name) on Baby Office Hours!

        Tap this link to accept: \(invite.shareableCode)

        You'll be able to toggle \(baby.name)'s availability for video calls.
        """
    }

    private func copyToClipboard() {
        guard let invite = currentInvite else { return }
        UIPasteboard.general.string = invite.shareableCode
    }

    private func simulateAcceptance() {
        _ = appState.simulateInviteAccepted(for: baby)
        if let invite = currentInvite {
            appState.cancelInvite(invite)
        }
        showingSimulateSuccess = true
    }
}

/// UIKit share sheet wrapper
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Previews

#Preview("Invite Co-Parent") {
    let appState = AppState()
    let baby = appState.createBaby(name: "Emma")
    return InviteCoParentView(baby: baby)
        .environment(appState)
}
