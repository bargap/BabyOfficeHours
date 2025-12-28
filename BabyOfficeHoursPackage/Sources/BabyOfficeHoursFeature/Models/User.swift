import Foundation

/// Represents a user of the app (parent or family member)
@Observable
@MainActor
public final class User: Identifiable {
    public let id: UUID
    public var name: String?
    public var deviceToken: String?
    public var babies: [UUID]

    public init(
        id: UUID = UUID(),
        name: String? = nil,
        deviceToken: String? = nil,
        babies: [UUID] = []
    ) {
        self.id = id
        self.name = name
        self.deviceToken = deviceToken
        self.babies = babies
    }

    /// Display name for the user, falls back to "Unknown" if not set
    public var displayName: String {
        name ?? "Unknown"
    }

    // MARK: - Firestore Conversion

    /// Converts the user to a Firestore-compatible dictionary
    public func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "babies": babies.map { $0.uuidString }
        ]
        if let name {
            data["name"] = name
        }
        if let deviceToken {
            data["deviceToken"] = deviceToken
        }
        return data
    }

    /// Creates a User from Firestore data
    public static func fromFirestore(_ data: [String: Any], id: String) -> User? {
        guard let uuid = UUID(uuidString: id) else { return nil }

        let name = data["name"] as? String
        let deviceToken = data["deviceToken"] as? String

        let babyStrings = data["babies"] as? [String] ?? []
        let babies = babyStrings.compactMap { UUID(uuidString: $0) }

        return User(
            id: uuid,
            name: name,
            deviceToken: deviceToken,
            babies: babies
        )
    }
}
