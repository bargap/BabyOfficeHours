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
}
