import SwiftUI

/// Main screen showing all babies the user is connected to
struct BabyListView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            Group {
                if appState.babies.isEmpty {
                    emptyState
                } else {
                    babyList
                }
            }
            .navigationTitle("Office Hours")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView(
            "No Babies Yet",
            systemImage: "person.crop.circle.badge.plus",
            description: Text("Create a baby profile or join via an invite link")
        )
    }

    private var babyList: some View {
        List(appState.babies) { baby in
            BabyCardView(baby: baby, isParent: appState.isParent(of: baby))
        }
        .listStyle(.plain)
    }
}

/// Card displaying a baby's status with toggle for parents
struct BabyCardView: View {
    let baby: Baby
    let isParent: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Baby avatar with status glow
            ZStack {
                if baby.isAvailable {
                    Circle()
                        .fill(.green.opacity(0.2))
                        .frame(width: 64, height: 64)
                }

                Circle()
                    .fill(.quaternary)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Text("👶")
                            .font(.title)
                    }
            }

            // Baby info
            VStack(alignment: .leading, spacing: 4) {
                Text(baby.name)
                    .font(.headline)

                Text(statusMessage)
                    .font(.subheadline)
                    .foregroundStyle(baby.isAvailable ? .green : .secondary)
            }

            Spacer()

            // Toggle for parents, status indicator for subscribers
            if isParent {
                AvailabilityToggle(baby: baby)
            } else {
                StatusIndicator(isAvailable: baby.isAvailable)
            }
        }
        .padding(.vertical, 8)
        .animation(.easeInOut(duration: 0.2), value: baby.isAvailable)
    }

    private var statusMessage: String {
        if baby.isAvailable {
            return "The baby will see you now!"
        } else {
            return "Office hours are over"
        }
    }
}

/// Interactive toggle button for parents to broadcast availability
struct AvailabilityToggle: View {
    let baby: Baby

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                baby.toggleAvailability()
            }
        } label: {
            ZStack {
                Capsule()
                    .fill(baby.isAvailable ? .green : .gray.opacity(0.3))
                    .frame(width: 60, height: 34)

                Circle()
                    .fill(.white)
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: baby.isAvailable ? 12 : -12)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(baby.isAvailable ? "Turn off office hours" : "Turn on office hours")
        .accessibilityHint("Double tap to toggle availability")
    }
}

/// Read-only status indicator for subscribers
struct StatusIndicator: View {
    let isAvailable: Bool

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(isAvailable ? .green : .gray.opacity(0.4))
                .frame(width: 10, height: 10)

            Text(isAvailable ? "Available" : "Unavailable")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(.quaternary)
        )
    }
}

#Preview("With Babies - Available") {
    let appState = AppState()
    let baby = appState.createBaby(name: "Emma")
    baby.isAvailable = true
    return BabyListView()
        .environment(appState)
}

#Preview("With Babies - Unavailable") {
    let appState = AppState()
    _ = appState.createBaby(name: "Emma")
    return BabyListView()
        .environment(appState)
}

#Preview("Empty State") {
    BabyListView()
        .environment(AppState())
}
