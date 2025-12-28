import Foundation

/// App-wide state container managing the current user and their connected babies
@Observable
@MainActor
public final class AppState {
    /// The current user (created on first launch)
    public var currentUser: User

    /// All babies the user is connected to (as parent or subscriber)
    public var babies: [Baby]

    /// Whether the user has completed onboarding
    public var hasCompletedOnboarding: Bool

    public init(
        currentUser: User = User(),
        babies: [Baby] = [],
        hasCompletedOnboarding: Bool = false
    ) {
        self.currentUser = currentUser
        self.babies = babies
        self.hasCompletedOnboarding = hasCompletedOnboarding
    }

    // MARK: - Baby Management

    /// Creates a new baby profile with the current user as parent
    public func createBaby(name: String) -> Baby {
        let baby = Baby(name: name, createdBy: currentUser.id)
        babies.append(baby)
        currentUser.babies.append(baby.id)
        hasCompletedOnboarding = true
        return baby
    }

    /// Returns babies where the current user is a parent
    public var parentBabies: [Baby] {
        babies.filter { $0.parents.contains(currentUser.id) }
    }

    /// Returns babies where the current user is a subscriber (not parent)
    public var subscribedBabies: [Baby] {
        babies.filter { $0.subscribers.contains(currentUser.id) }
    }

    /// Checks if the current user is a parent of the given baby
    public func isParent(of baby: Baby) -> Bool {
        baby.parents.contains(currentUser.id)
    }
}
