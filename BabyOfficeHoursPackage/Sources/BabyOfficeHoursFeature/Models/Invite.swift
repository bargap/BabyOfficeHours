import Foundation

/// Role that an invite grants to the recipient
public enum InviteRole: String, Sendable, Codable {
    case parent
    case subscriber
}

/// Represents an invitation to join a baby's circle
@Observable
@MainActor
public final class Invite: Identifiable {
    public let id: UUID
    public let babyId: UUID
    public let role: InviteRole
    public let createdBy: UUID
    public let createdAt: Date
    public var expiresAt: Date?
    public var isRedeemed: Bool
    public var redeemedBy: UUID?
    public var redeemedAt: Date?

    public init(
        id: UUID = UUID(),
        babyId: UUID,
        role: InviteRole,
        createdBy: UUID,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        isRedeemed: Bool = false,
        redeemedBy: UUID? = nil,
        redeemedAt: Date? = nil
    ) {
        self.id = id
        self.babyId = babyId
        self.role = role
        self.createdBy = createdBy
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.isRedeemed = isRedeemed
        self.redeemedBy = redeemedBy
        self.redeemedAt = redeemedAt
    }

    // MARK: - Computed Properties

    /// Whether the invite has expired
    public var isExpired: Bool {
        guard let expiresAt else { return false }
        return Date() > expiresAt
    }

    /// Whether the invite can still be used
    public var isValid: Bool {
        !isRedeemed && !isExpired
    }

    /// Generates a shareable invite code (mock - would be a deep link in production)
    public var shareableCode: String {
        "babyofficehours://invite/\(id.uuidString.prefix(8).lowercased())"
    }

    // MARK: - Actions

    /// Marks the invite as redeemed by a user
    public func redeem(by userId: UUID) {
        guard isValid else { return }
        isRedeemed = true
        redeemedBy = userId
        redeemedAt = Date()
    }
}

// MARK: - Sendable Conformance

extension Invite: @unchecked Sendable {}

// MARK: - Firestore Conversion

extension Invite {
    /// Converts the invite to a Firestore-compatible dictionary
    public func toFirestore() -> [String: Any] {
        var data: [String: Any] = [
            "babyId": babyId.uuidString,
            "role": role.rawValue,
            "createdBy": createdBy.uuidString,
            "createdAt": createdAt,
            "isRedeemed": isRedeemed
        ]
        if let expiresAt {
            data["expiresAt"] = expiresAt
        }
        if let redeemedBy {
            data["redeemedBy"] = redeemedBy.uuidString
        }
        if let redeemedAt {
            data["redeemedAt"] = redeemedAt
        }
        return data
    }

    /// Creates an Invite from Firestore data
    public static func fromFirestore(_ data: [String: Any], id: String) -> Invite? {
        guard let uuid = UUID(uuidString: id),
              let babyIdString = data["babyId"] as? String,
              let babyId = UUID(uuidString: babyIdString),
              let roleString = data["role"] as? String,
              let role = InviteRole(rawValue: roleString),
              let createdByString = data["createdBy"] as? String,
              let createdBy = UUID(uuidString: createdByString) else {
            return nil
        }

        let createdAt = (data["createdAt"] as? Date) ?? Date()
        let expiresAt = data["expiresAt"] as? Date
        let isRedeemed = data["isRedeemed"] as? Bool ?? false

        var redeemedBy: UUID?
        if let redeemedByString = data["redeemedBy"] as? String {
            redeemedBy = UUID(uuidString: redeemedByString)
        }

        let redeemedAt = data["redeemedAt"] as? Date

        return Invite(
            id: uuid,
            babyId: babyId,
            role: role,
            createdBy: createdBy,
            createdAt: createdAt,
            expiresAt: expiresAt,
            isRedeemed: isRedeemed,
            redeemedBy: redeemedBy,
            redeemedAt: redeemedAt
        )
    }
}
