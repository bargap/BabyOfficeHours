import Foundation

/// Represents a baby profile that can broadcast availability for video calls
@Observable
@MainActor
public final class Baby: Identifiable {
    public let id: UUID
    public var name: String
    public let createdBy: UUID
    public var parents: [UUID]
    public var subscribers: [UUID]
    public var isAvailable: Bool
    public var lastStatusChange: Date

    public init(
        id: UUID = UUID(),
        name: String,
        createdBy: UUID,
        parents: [UUID]? = nil,
        subscribers: [UUID] = [],
        isAvailable: Bool = false,
        lastStatusChange: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.createdBy = createdBy
        self.parents = parents ?? [createdBy]
        self.subscribers = subscribers
        self.isAvailable = isAvailable
        self.lastStatusChange = lastStatusChange
    }

    // MARK: - Availability Toggle

    /// Toggles the baby's availability status
    public func toggleAvailability() {
        isAvailable.toggle()
        lastStatusChange = Date()
    }

    /// Sets the baby's availability to a specific state
    public func setAvailability(_ available: Bool) {
        guard isAvailable != available else { return }
        isAvailable = available
        lastStatusChange = Date()
    }

    // MARK: - Co-Parent Management

    /// Adds a co-parent to this baby
    /// - Parameter userId: The user ID to add as a parent
    /// - Returns: True if the user was added, false if already a parent
    @discardableResult
    public func addParent(_ userId: UUID) -> Bool {
        guard !parents.contains(userId) else { return false }
        parents.append(userId)
        return true
    }

    /// Removes a co-parent from this baby
    /// - Parameter userId: The user ID to remove
    /// - Returns: True if the user was removed, false if not a parent or is the creator
    @discardableResult
    public func removeParent(_ userId: UUID) -> Bool {
        // Cannot remove the creator
        guard userId != createdBy else { return false }
        guard let index = parents.firstIndex(of: userId) else { return false }
        parents.remove(at: index)
        return true
    }

    /// Checks if a user is a parent of this baby
    public func isParent(_ userId: UUID) -> Bool {
        parents.contains(userId)
    }

    /// Checks if a user is the creator of this baby
    public func isCreator(_ userId: UUID) -> Bool {
        createdBy == userId
    }

    /// Returns the number of co-parents (excluding creator)
    public var coParentCount: Int {
        parents.count - 1
    }

    // MARK: - Subscriber Management

    /// Adds a subscriber to this baby
    /// - Parameter userId: The user ID to add as a subscriber
    /// - Returns: True if the user was added, false if already a subscriber or is a parent
    @discardableResult
    public func addSubscriber(_ userId: UUID) -> Bool {
        // Parents can't be subscribers
        guard !parents.contains(userId) else { return false }
        guard !subscribers.contains(userId) else { return false }
        subscribers.append(userId)
        return true
    }

    /// Removes a subscriber from this baby
    /// - Parameter userId: The user ID to remove
    /// - Returns: True if the user was removed, false if not a subscriber
    @discardableResult
    public func removeSubscriber(_ userId: UUID) -> Bool {
        guard let index = subscribers.firstIndex(of: userId) else { return false }
        subscribers.remove(at: index)
        return true
    }

    /// Checks if a user is a subscriber of this baby
    public func isSubscriber(_ userId: UUID) -> Bool {
        subscribers.contains(userId)
    }

    /// Returns the number of subscribers
    public var subscriberCount: Int {
        subscribers.count
    }

    // MARK: - Firestore Conversion

    /// Converts the baby to a Firestore-compatible dictionary
    public func toFirestore() -> [String: Any] {
        let data: [String: Any] = [
            "name": name,
            "createdBy": createdBy.uuidString,
            "parents": parents.map { $0.uuidString },
            "subscribers": subscribers.map { $0.uuidString },
            "isAvailable": isAvailable,
            "lastStatusChange": lastStatusChange
        ]
        return data
    }

    /// Creates a Baby from Firestore data
    public static func fromFirestore(_ data: [String: Any], id: String) -> Baby? {
        guard let uuid = UUID(uuidString: id),
              let name = data["name"] as? String,
              let createdByString = data["createdBy"] as? String,
              let createdBy = UUID(uuidString: createdByString) else {
            return nil
        }

        let parentStrings = data["parents"] as? [String] ?? []
        let parents = parentStrings.compactMap { UUID(uuidString: $0) }

        let subscriberStrings = data["subscribers"] as? [String] ?? []
        let subscribers = subscriberStrings.compactMap { UUID(uuidString: $0) }

        let isAvailable = data["isAvailable"] as? Bool ?? false

        let lastStatusChange: Date
        if let timestamp = data["lastStatusChange"] as? Date {
            lastStatusChange = timestamp
        } else {
            lastStatusChange = Date()
        }

        return Baby(
            id: uuid,
            name: name,
            createdBy: createdBy,
            parents: parents,
            subscribers: subscribers,
            isAvailable: isAvailable,
            lastStatusChange: lastStatusChange
        )
    }
}
