import Foundation
@preconcurrency import FirebaseAuth
@preconcurrency import FirebaseFirestore

/// Service for syncing app data with Firebase
@MainActor
public final class FirebaseService {
    public static let shared = FirebaseService()

    nonisolated(unsafe) private let db = Firestore.firestore()
    private var listeners: [ListenerRegistration] = []

    private init() {}

    // MARK: - Authentication

    /// Signs in anonymously and returns the user ID
    public func signInAnonymously() async throws -> String {
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    /// Returns the current user ID if signed in
    public nonisolated var currentUserId: String? {
        Auth.auth().currentUser?.uid
    }

    /// Returns true if user is signed in
    public nonisolated var isSignedIn: Bool {
        Auth.auth().currentUser != nil
    }

    // MARK: - Baby Operations

    /// Creates a baby document in Firestore
    public func createBaby(_ baby: Baby) async throws {
        let babyId = baby.id.uuidString
        let name = baby.name
        let createdBy = baby.createdBy.uuidString
        let parents = baby.parents.map { $0.uuidString }
        let subscribers = baby.subscribers.map { $0.uuidString }
        let isAvailable = baby.isAvailable
        let lastStatusChange = baby.lastStatusChange

        try await setDocument(
            collection: "babies",
            documentId: babyId,
            name: name,
            createdBy: createdBy,
            parents: parents,
            subscribers: subscribers,
            isAvailable: isAvailable,
            lastStatusChange: lastStatusChange
        )
    }

    private nonisolated func setDocument(
        collection: String,
        documentId: String,
        name: String,
        createdBy: String,
        parents: [String],
        subscribers: [String],
        isAvailable: Bool,
        lastStatusChange: Date
    ) async throws {
        // Only storing baby first name - no PII like full names, emails, or phone numbers
        let data: [String: Any] = [
            "name": name,
            "createdBy": createdBy,
            "parents": parents,
            "subscribers": subscribers,
            "isAvailable": isAvailable,
            "lastStatusChange": lastStatusChange
        ]
        try await db.collection(collection).document(documentId).setData(data)
    }

    /// Updates a baby document in Firestore
    public func updateBaby(_ baby: Baby) async throws {
        try await createBaby(baby) // Same operation with merge
    }

    /// Updates just the availability status (optimized for frequent updates)
    public func updateAvailability(babyId: UUID, isAvailable: Bool) async throws {
        let docId = babyId.uuidString
        try await updateAvailabilityInternal(docId: docId, isAvailable: isAvailable)
    }

    private nonisolated func updateAvailabilityInternal(docId: String, isAvailable: Bool) async throws {
        try await db.collection("babies").document(docId).updateData([
            "isAvailable": isAvailable,
            "lastStatusChange": FieldValue.serverTimestamp()
        ])
    }

    /// Fetches all babies the user is connected to
    public func fetchBabies(for userId: String) async throws -> [Baby] {
        try await fetchBabiesInternal(userId: userId)
    }

    private nonisolated func fetchBabiesInternal(userId: String) async throws -> [Baby] {
        // Query babies where user is a parent
        let parentQuery = db.collection("babies")
            .whereField("parents", arrayContains: userId)

        // Query babies where user is a subscriber
        let subscriberQuery = db.collection("babies")
            .whereField("subscribers", arrayContains: userId)

        let parentResults = try await parentQuery.getDocuments()
        let subscriberResults = try await subscriberQuery.getDocuments()

        var babies: [Baby] = []
        var seenIds: Set<String> = []

        for doc in parentResults.documents {
            if !seenIds.contains(doc.documentID) {
                if let baby = await Baby.fromFirestore(doc.data(), id: doc.documentID) {
                    babies.append(baby)
                    seenIds.insert(doc.documentID)
                }
            }
        }

        for doc in subscriberResults.documents {
            if !seenIds.contains(doc.documentID) {
                if let baby = await Baby.fromFirestore(doc.data(), id: doc.documentID) {
                    babies.append(baby)
                    seenIds.insert(doc.documentID)
                }
            }
        }

        return babies
    }

    /// Listens for real-time updates to a baby
    public func listenToBaby(id: UUID, onChange: @escaping @MainActor @Sendable (Baby?) -> Void) -> ListenerRegistration {
        let listener = db.collection("babies").document(id.uuidString)
            .addSnapshotListener { snapshot, error in
                guard let data = snapshot?.data() else {
                    Task { @MainActor in
                        onChange(nil)
                    }
                    return
                }
                Task { @MainActor in
                    let baby = Baby.fromFirestore(data, id: id.uuidString)
                    onChange(baby)
                }
            }
        listeners.append(listener)
        return listener
    }

    /// Removes all listeners
    public func removeAllListeners() {
        listeners.forEach { $0.remove() }
        listeners.removeAll()
    }

    // MARK: - Invite Operations

    /// Creates an invite document in Firestore
    public func createInvite(_ invite: Invite) async throws {
        let inviteId = invite.id.uuidString
        let babyId = invite.babyId.uuidString
        let role = invite.role.rawValue
        let createdBy = invite.createdBy.uuidString
        let createdAt = invite.createdAt
        let isRedeemed = invite.isRedeemed
        let expiresAt = invite.expiresAt

        try await setInviteDocument(
            inviteId: inviteId,
            babyId: babyId,
            role: role,
            createdBy: createdBy,
            createdAt: createdAt,
            isRedeemed: isRedeemed,
            expiresAt: expiresAt
        )
    }

    private nonisolated func setInviteDocument(
        inviteId: String,
        babyId: String,
        role: String,
        createdBy: String,
        createdAt: Date,
        isRedeemed: Bool,
        expiresAt: Date?
    ) async throws {
        var data: [String: Any] = [
            "babyId": babyId,
            "role": role,
            "createdBy": createdBy,
            "createdAt": createdAt,
            "isRedeemed": isRedeemed
        ]
        if let expiresAt {
            data["expiresAt"] = expiresAt
        }
        try await db.collection("invites").document(inviteId).setData(data)
    }

    /// Fetches an invite by ID
    public func fetchInvite(id: String) async throws -> Invite? {
        try await fetchInviteInternal(id: id)
    }

    private nonisolated func fetchInviteInternal(id: String) async throws -> Invite? {
        let doc = try await db.collection("invites").document(id).getDocument()
        guard let data = doc.data() else { return nil }
        return await Invite.fromFirestore(data, id: id)
    }

    /// Redeems an invite (marks it as used and adds user to baby)
    public func redeemInvite(_ invite: Invite, userId: String) async throws {
        let inviteId = invite.id.uuidString
        let babyId = invite.babyId.uuidString
        let isParent = invite.role == .parent

        try await redeemInviteInternal(inviteId: inviteId, babyId: babyId, userId: userId, isParent: isParent)
    }

    private nonisolated func redeemInviteInternal(inviteId: String, babyId: String, userId: String, isParent: Bool) async throws {
        let batch = db.batch()

        // Mark invite as redeemed
        let inviteRef = db.collection("invites").document(inviteId)
        batch.updateData([
            "redeemedBy": userId,
            "redeemedAt": FieldValue.serverTimestamp()
        ], forDocument: inviteRef)

        // Add user to baby
        let babyRef = db.collection("babies").document(babyId)
        let fieldToUpdate = isParent ? "parents" : "subscribers"
        batch.updateData([
            fieldToUpdate: FieldValue.arrayUnion([userId])
        ], forDocument: babyRef)

        try await batch.commit()
    }

    // MARK: - User Operations

    /// Creates or updates a user document
    public func saveUser(_ user: User) async throws {
        let userId = user.id.uuidString
        let name = user.name
        let deviceToken = user.deviceToken
        let babies = user.babies.map { $0.uuidString }

        try await saveUserInternal(userId: userId, name: name, deviceToken: deviceToken, babies: babies)
    }

    private nonisolated func saveUserInternal(userId: String, name: String?, deviceToken: String?, babies: [String]) async throws {
        var data: [String: Any] = [
            "babies": babies
        ]
        if let name {
            data["name"] = name
        }
        if let deviceToken {
            data["deviceToken"] = deviceToken
        }
        try await db.collection("users").document(userId).setData(data, merge: true)
    }

    /// Fetches a user by ID
    public func fetchUser(id: String) async throws -> User? {
        try await fetchUserInternal(id: id)
    }

    private nonisolated func fetchUserInternal(id: String) async throws -> User? {
        let doc = try await db.collection("users").document(id).getDocument()
        guard let data = doc.data() else { return nil }
        return await User.fromFirestore(data, id: id)
    }
}
