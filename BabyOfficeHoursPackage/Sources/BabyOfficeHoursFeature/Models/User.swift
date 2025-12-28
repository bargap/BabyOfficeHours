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
}
