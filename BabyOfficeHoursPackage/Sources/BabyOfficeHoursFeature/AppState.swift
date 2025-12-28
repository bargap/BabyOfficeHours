import Foundation

/// App-wide state container managing the current user and their connected babies
@Observable
@MainActor
public final class AppState {
    /// The current user (created on first launch)
    public var currentUser: User

    /// All babies the user is connected to (as parent or subscriber)
    public var babies: [Baby]

    /// All pending invites created by the current user
    public var pendingInvites: [Invite]

    /// Registry of known users (for displaying names of co-parents/subscribers)
    public var knownUsers: [UUID: User]

    /// Whether the user has completed onboarding
    public var hasCompletedOnboarding: Bool

    /// Pending invite to join (from deep link)
    public var pendingJoinInvite: Invite?

    public init(
        currentUser: User = User(),
        babies: [Baby] = [],
        pendingInvites: [Invite] = [],
        knownUsers: [UUID: User] = [:],
        hasCompletedOnboarding: Bool = false,
        pendingJoinInvite: Invite? = nil
    ) {
        self.currentUser = currentUser
        self.babies = babies
        self.pendingInvites = pendingInvites
        self.knownUsers = knownUsers
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.pendingJoinInvite = pendingJoinInvite
    }

    /// Gets a known user by ID
    public func user(for id: UUID) -> User? {
        if id == currentUser.id { return currentUser }
        return knownUsers[id]
    }

    /// Gets the display name for a user ID
    public func displayName(for userId: UUID) -> String {
        if userId == currentUser.id { return "You" }
        return knownUsers[userId]?.displayName ?? "Unknown"
    }

    /// Registers a user in the known users registry
    public func registerUser(_ user: User) {
        knownUsers[user.id] = user
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

    /// Checks if the current user is the creator of the given baby
    public func isCreator(of baby: Baby) -> Bool {
        baby.createdBy == currentUser.id
    }

    // MARK: - Invite Management

    /// Creates a co-parent invite for a baby
    /// - Parameters:
    ///   - baby: The baby to invite a co-parent for
    ///   - expiresIn: Optional time interval for expiration (default: 7 days)
    /// - Returns: The created invite, or nil if user is not a parent
    public func createCoParentInvite(for baby: Baby, expiresIn: TimeInterval? = 7 * 24 * 60 * 60) -> Invite? {
        guard isParent(of: baby) else { return nil }

        let expiresAt = expiresIn.map { Date().addingTimeInterval($0) }
        let invite = Invite(
            babyId: baby.id,
            role: .parent,
            createdBy: currentUser.id,
            expiresAt: expiresAt
        )
        pendingInvites.append(invite)
        return invite
    }

    /// Returns all pending invites for a specific baby
    public func pendingInvites(for baby: Baby) -> [Invite] {
        pendingInvites.filter { $0.babyId == baby.id && $0.isValid }
    }

    /// Redeems an invite, adding the current user to the baby
    /// - Parameter invite: The invite to redeem
    /// - Returns: The baby if successful, nil if invite is invalid or baby not found
    @discardableResult
    public func redeemInvite(_ invite: Invite) -> Baby? {
        guard invite.isValid else { return nil }
        guard let baby = babies.first(where: { $0.id == invite.babyId }) else { return nil }

        invite.redeem(by: currentUser.id)

        switch invite.role {
        case .parent:
            baby.addParent(currentUser.id)
        case .subscriber:
            if !baby.subscribers.contains(currentUser.id) {
                baby.subscribers.append(currentUser.id)
            }
        }

        if !currentUser.babies.contains(baby.id) {
            currentUser.babies.append(baby.id)
        }

        return baby
    }

    /// Cancels a pending invite
    /// - Parameter invite: The invite to cancel
    /// - Returns: True if the invite was found and removed
    @discardableResult
    public func cancelInvite(_ invite: Invite) -> Bool {
        guard let index = pendingInvites.firstIndex(where: { $0.id == invite.id }) else {
            return false
        }
        pendingInvites.remove(at: index)
        return true
    }

    // MARK: - Co-Parent Management

    /// Removes a co-parent from a baby
    /// - Parameters:
    ///   - userId: The user ID to remove
    ///   - baby: The baby to remove the co-parent from
    /// - Returns: True if the co-parent was removed
    @discardableResult
    public func removeCoParent(_ userId: UUID, from baby: Baby) -> Bool {
        guard isParent(of: baby) else { return false }
        return baby.removeParent(userId)
    }

    // MARK: - Subscriber Management

    /// Creates a subscriber invite for a baby
    /// - Parameters:
    ///   - baby: The baby to invite a subscriber for
    ///   - expiresIn: Optional time interval for expiration (default: 7 days)
    /// - Returns: The created invite, or nil if user is not a parent
    public func createSubscriberInvite(for baby: Baby, expiresIn: TimeInterval? = 7 * 24 * 60 * 60) -> Invite? {
        guard isParent(of: baby) else { return nil }

        let expiresAt = expiresIn.map { Date().addingTimeInterval($0) }
        let invite = Invite(
            babyId: baby.id,
            role: .subscriber,
            createdBy: currentUser.id,
            expiresAt: expiresAt
        )
        pendingInvites.append(invite)
        return invite
    }

    /// Removes a subscriber from a baby
    /// - Parameters:
    ///   - userId: The user ID to remove
    ///   - baby: The baby to remove the subscriber from
    /// - Returns: True if the subscriber was removed
    @discardableResult
    public func removeSubscriber(_ userId: UUID, from baby: Baby) -> Bool {
        guard isParent(of: baby) else { return false }
        return baby.removeSubscriber(userId)
    }

    // MARK: - Mock Data for Testing

    private static let mockNames = ["Alex", "Jordan", "Taylor", "Morgan", "Casey", "Riley", "Quinn", "Avery"]

    /// Simulates accepting a co-parent invite (for UI testing without Firebase)
    /// Creates a mock co-parent user and adds them to the baby
    public func simulateCoParentInviteAccepted(for baby: Baby) -> User {
        let mockName = Self.mockNames.randomElement() ?? "Partner"
        let mockCoParent = User(id: UUID(), name: mockName)
        baby.addParent(mockCoParent.id)
        registerUser(mockCoParent)
        return mockCoParent
    }

    /// Simulates accepting a subscriber invite (for UI testing without Firebase)
    /// Creates a mock subscriber user and adds them to the baby
    public func simulateSubscriberInviteAccepted(for baby: Baby) -> User {
        let mockName = Self.mockNames.randomElement() ?? "Family Member"
        let mockSubscriber = User(id: UUID(), name: mockName)
        baby.addSubscriber(mockSubscriber.id)
        registerUser(mockSubscriber)
        return mockSubscriber
    }

    // MARK: - Join Flow

    /// Joins a baby as a subscriber or co-parent via invite
    /// - Parameters:
    ///   - baby: The baby to join
    ///   - role: The role to join as
    ///   - userName: The name the user wants to be displayed as
    public func joinBaby(_ baby: Baby, as role: InviteRole, userName: String) {
        currentUser.name = userName

        switch role {
        case .parent:
            baby.addParent(currentUser.id)
        case .subscriber:
            baby.addSubscriber(currentUser.id)
        }

        if !babies.contains(where: { $0.id == baby.id }) {
            babies.append(baby)
        }

        if !currentUser.babies.contains(baby.id) {
            currentUser.babies.append(baby.id)
        }

        hasCompletedOnboarding = true
        pendingJoinInvite = nil
    }
}
