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

/// Card displaying a baby's status
struct BabyCardView: View {
    let baby: Baby
    let isParent: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Baby avatar placeholder
            Circle()
                .fill(.quaternary)
                .frame(width: 56, height: 56)
                .overlay {
                    Text("👶")
                        .font(.title)
                }

            // Baby info
            VStack(alignment: .leading, spacing: 4) {
                Text(baby.name)
                    .font(.headline)

                Text(baby.isAvailable ? "The baby is in!" : "Office hours are over")
                    .font(.subheadline)
                    .foregroundStyle(baby.isAvailable ? .green : .secondary)
            }

            Spacer()

            // Status indicator (toggle for parents, badge for subscribers)
            if isParent {
                // Toggle will be added in Feature 2
                Circle()
                    .fill(baby.isAvailable ? .green : .gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            } else {
                Circle()
                    .fill(baby.isAvailable ? .green : .gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview("With Babies") {
    let appState = AppState()
    _ = appState.createBaby(name: "Emma")
    return BabyListView()
        .environment(appState)
}

#Preview("Empty State") {
    BabyListView()
        .environment(AppState())
}
