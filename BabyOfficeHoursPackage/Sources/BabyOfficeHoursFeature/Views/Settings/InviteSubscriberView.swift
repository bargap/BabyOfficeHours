import SwiftUI

/// View for creating and sharing a subscriber (family member) invite
struct InviteSubscriberView: View {
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
            .navigationTitle("Invite Family")
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
                Text("A family member has been added to \(baby.name)'s subscribers. They'll see when \(baby.name) is available!")
            }
        }
    }

    // MARK: - Sections

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.2.badge.plus")
                .font(.system(size: 48))
                .foregroundStyle(.tint)

            Text("Invite Family Member")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Share this invite with grandparents, aunts, uncles, or anyone who wants to know when \(baby.name) is available for FaceTime.")
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

                // Role badge
                HStack {
                    Image(systemName: "eye")
                    Text("View-only access")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    Capsule()
                        .fill(.blue.opacity(0.1))
                )

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
            currentInvite = appState.createSubscriberInvite(for: baby)
        }
    }

    private func inviteMessage(for invite: Invite) -> String {
        """
        Want to know when \(baby.name) is available for FaceTime? Join Baby Office Hours!

        Tap this link to subscribe: \(invite.shareableCode)

        You'll get notified whenever \(baby.name) is ready for video calls.
        """
    }

    private func copyToClipboard() {
        guard let invite = currentInvite else { return }
        UIPasteboard.general.string = invite.shareableCode
    }

    private func simulateAcceptance() {
        _ = appState.simulateSubscriberInviteAccepted(for: baby)
        if let invite = currentInvite {
            appState.cancelInvite(invite)
        }
        showingSimulateSuccess = true
    }
}

// MARK: - Previews

#Preview("Invite Subscriber") {
    let appState = AppState()
    let baby = appState.createBaby(name: "Emma")
    return InviteSubscriberView(baby: baby)
        .environment(appState)
}
