import SwiftUI

/// Settings screen for managing a baby's profile and co-parents
struct BabySettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    let baby: Baby

    @State private var editedName: String = ""
    @State private var showingInviteSheet = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            List {
                nameSection
                coParentsSection
                if appState.isCreator(of: baby) {
                    dangerZoneSection
                }
            }
            .navigationTitle("Baby Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingInviteSheet) {
                InviteCoParentView(baby: baby)
            }
            .confirmationDialog(
                "Delete Baby Profile",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteBaby()
                }
            } message: {
                Text("Are you sure you want to delete \(baby.name)'s profile? This cannot be undone.")
            }
            .onAppear {
                editedName = baby.name
            }
        }
    }

    // MARK: - Sections

    private var nameSection: some View {
        Section("Name") {
            TextField("Baby's name", text: $editedName)
                .onChange(of: editedName) { _, newValue in
                    if !newValue.isEmpty {
                        baby.name = newValue
                    }
                }
        }
    }

    private var coParentsSection: some View {
        Section {
            // List of current co-parents
            ForEach(coParentIds, id: \.self) { parentId in
                CoParentRow(
                    parentId: parentId,
                    isCreator: parentId == baby.createdBy,
                    canRemove: canRemoveCoParent(parentId),
                    onRemove: { removeCoParent(parentId) }
                )
            }

            // Invite button
            Button {
                showingInviteSheet = true
            } label: {
                Label("Invite Co-Parent", systemImage: "person.badge.plus")
            }
        } header: {
            Text("Parents")
        } footer: {
            Text("Co-parents have full permissions: toggle availability, manage subscribers, and delete the baby profile.")
        }
    }

    private var dangerZoneSection: some View {
        Section {
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete Baby Profile", systemImage: "trash")
            }
        } header: {
            Text("Danger Zone")
        }
    }

    // MARK: - Computed Properties

    private var coParentIds: [UUID] {
        baby.parents
    }

    private func canRemoveCoParent(_ parentId: UUID) -> Bool {
        // Can't remove the creator, and can only remove if current user is a parent
        parentId != baby.createdBy && appState.isParent(of: baby)
    }

    // MARK: - Actions

    private func removeCoParent(_ parentId: UUID) {
        appState.removeCoParent(parentId, from: baby)
    }

    private func deleteBaby() {
        if let index = appState.babies.firstIndex(where: { $0.id == baby.id }) {
            appState.babies.remove(at: index)
        }
        if let index = appState.currentUser.babies.firstIndex(of: baby.id) {
            appState.currentUser.babies.remove(at: index)
        }
        dismiss()
    }
}

/// Row displaying a co-parent with optional remove action
struct CoParentRow: View {
    let parentId: UUID
    let isCreator: Bool
    let canRemove: Bool
    let onRemove: () -> Void

    var body: some View {
        HStack {
            Circle()
                .fill(.quaternary)
                .frame(width: 36, height: 36)
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.secondary)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text(displayName)
                    .font(.body)

                if isCreator {
                    Text("Creator")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            if canRemove {
                Button(role: .destructive) {
                    onRemove()
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var displayName: String {
        // In production, this would look up the user's name
        // For now, show a placeholder based on role
        if isCreator {
            return "You"
        } else {
            return "Co-Parent"
        }
    }
}

// MARK: - Previews

#Preview("Baby Settings") {
    let appState = AppState()
    let baby = appState.createBaby(name: "Emma")
    return BabySettingsView(baby: baby)
        .environment(appState)
}

#Preview("With Co-Parent") {
    let appState = AppState()
    let baby = appState.createBaby(name: "Emma")
    _ = appState.simulateInviteAccepted(for: baby)
    return BabySettingsView(baby: baby)
        .environment(appState)
}
