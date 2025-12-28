import Testing
@testable import BabyOfficeHoursFeature
import Foundation

// MARK: - Baby Model Tests

@Suite("Baby Model")
struct BabyTests {

    @Test("Baby initializes with creator as parent")
    @MainActor
    func babyInitializesWithCreatorAsParent() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        #expect(baby.name == "Emma")
        #expect(baby.createdBy == creatorId)
        #expect(baby.parents.count == 1)
        #expect(baby.parents.contains(creatorId))
        #expect(baby.isAvailable == false)
    }

    @Test("Add co-parent succeeds")
    @MainActor
    func addCoParentSucceeds() {
        let creatorId = UUID()
        let coParentId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.addParent(coParentId)

        #expect(result == true)
        #expect(baby.parents.count == 2)
        #expect(baby.parents.contains(coParentId))
    }

    @Test("Add duplicate parent fails")
    @MainActor
    func addDuplicateParentFails() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.addParent(creatorId)

        #expect(result == false)
        #expect(baby.parents.count == 1)
    }

    @Test("Remove co-parent succeeds")
    @MainActor
    func removeCoParentSucceeds() {
        let creatorId = UUID()
        let coParentId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)
        baby.addParent(coParentId)

        let result = baby.removeParent(coParentId)

        #expect(result == true)
        #expect(baby.parents.count == 1)
        #expect(!baby.parents.contains(coParentId))
    }

    @Test("Cannot remove creator")
    @MainActor
    func cannotRemoveCreator() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.removeParent(creatorId)

        #expect(result == false)
        #expect(baby.parents.count == 1)
        #expect(baby.parents.contains(creatorId))
    }

    @Test("isParent returns correct value")
    @MainActor
    func isParentReturnsCorrectValue() {
        let creatorId = UUID()
        let coParentId = UUID()
        let randomId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)
        baby.addParent(coParentId)

        #expect(baby.isParent(creatorId) == true)
        #expect(baby.isParent(coParentId) == true)
        #expect(baby.isParent(randomId) == false)
    }

    @Test("coParentCount returns correct count")
    @MainActor
    func coParentCountReturnsCorrectCount() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        #expect(baby.coParentCount == 0)

        baby.addParent(UUID())
        #expect(baby.coParentCount == 1)

        baby.addParent(UUID())
        #expect(baby.coParentCount == 2)
    }
}

// MARK: - Invite Model Tests

@Suite("Invite Model")
struct InviteTests {

    @Test("Invite initializes correctly")
    @MainActor
    func inviteInitializesCorrectly() {
        let babyId = UUID()
        let creatorId = UUID()
        let invite = Invite(babyId: babyId, role: .parent, createdBy: creatorId)

        #expect(invite.babyId == babyId)
        #expect(invite.role == .parent)
        #expect(invite.createdBy == creatorId)
        #expect(invite.isRedeemed == false)
        #expect(invite.isValid == true)
    }

    @Test("Invite expiration works correctly")
    @MainActor
    func inviteExpirationWorksCorrectly() {
        let babyId = UUID()
        let creatorId = UUID()

        // Non-expired invite
        let validInvite = Invite(
            babyId: babyId,
            role: .parent,
            createdBy: creatorId,
            expiresAt: Date().addingTimeInterval(3600)
        )
        #expect(validInvite.isExpired == false)
        #expect(validInvite.isValid == true)

        // Expired invite
        let expiredInvite = Invite(
            babyId: babyId,
            role: .parent,
            createdBy: creatorId,
            expiresAt: Date().addingTimeInterval(-3600)
        )
        #expect(expiredInvite.isExpired == true)
        #expect(expiredInvite.isValid == false)
    }

    @Test("Redeeming invite marks it as redeemed")
    @MainActor
    func redeemingInviteMarksAsRedeemed() {
        let babyId = UUID()
        let creatorId = UUID()
        let redeemerId = UUID()
        let invite = Invite(babyId: babyId, role: .parent, createdBy: creatorId)

        invite.redeem(by: redeemerId)

        #expect(invite.isRedeemed == true)
        #expect(invite.redeemedBy == redeemerId)
        #expect(invite.redeemedAt != nil)
        #expect(invite.isValid == false)
    }

    @Test("Cannot redeem already redeemed invite")
    @MainActor
    func cannotRedeemAlreadyRedeemedInvite() {
        let babyId = UUID()
        let creatorId = UUID()
        let firstRedeemer = UUID()
        let secondRedeemer = UUID()
        let invite = Invite(babyId: babyId, role: .parent, createdBy: creatorId)

        invite.redeem(by: firstRedeemer)
        invite.redeem(by: secondRedeemer)

        #expect(invite.redeemedBy == firstRedeemer)
    }

    @Test("Shareable code is generated")
    @MainActor
    func shareableCodeIsGenerated() {
        let invite = Invite(babyId: UUID(), role: .parent, createdBy: UUID())

        #expect(invite.shareableCode.hasPrefix("babyofficehours://invite/"))
        #expect(invite.shareableCode.count > 25)
    }
}

// MARK: - AppState Tests

@Suite("AppState Co-Parent Management")
struct AppStateCoParentTests {

    @Test("Create co-parent invite succeeds for parent")
    @MainActor
    func createCoParentInviteSucceedsForParent() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let invite = appState.createCoParentInvite(for: baby)

        #expect(invite != nil)
        #expect(invite?.babyId == baby.id)
        #expect(invite?.role == .parent)
        #expect(invite?.createdBy == appState.currentUser.id)
        #expect(appState.pendingInvites.count == 1)
    }

    @Test("Create co-parent invite fails for non-parent")
    @MainActor
    func createCoParentInviteFailsForNonParent() {
        let appState = AppState()
        let otherUser = User()
        let baby = Baby(name: "Emma", createdBy: otherUser.id)
        appState.babies.append(baby)

        let invite = appState.createCoParentInvite(for: baby)

        #expect(invite == nil)
        #expect(appState.pendingInvites.isEmpty)
    }

    @Test("Redeem invite adds user as parent")
    @MainActor
    func redeemInviteAddsUserAsParent() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")
        let invite = appState.createCoParentInvite(for: baby)!

        // Simulate a different user redeeming
        let newUser = User()
        appState.currentUser = newUser
        appState.babies = [baby] // Make baby visible to new user

        let result = appState.redeemInvite(invite)

        #expect(result != nil)
        #expect(baby.parents.contains(newUser.id))
        #expect(invite.isRedeemed == true)
    }

    @Test("Redeem expired invite fails")
    @MainActor
    func redeemExpiredInviteFails() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let expiredInvite = Invite(
            babyId: baby.id,
            role: .parent,
            createdBy: appState.currentUser.id,
            expiresAt: Date().addingTimeInterval(-3600)
        )
        appState.pendingInvites.append(expiredInvite)

        let result = appState.redeemInvite(expiredInvite)

        #expect(result == nil)
        #expect(baby.parents.count == 1)
    }

    @Test("Cancel invite removes it from pending")
    @MainActor
    func cancelInviteRemovesFromPending() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")
        let invite = appState.createCoParentInvite(for: baby)!

        let result = appState.cancelInvite(invite)

        #expect(result == true)
        #expect(appState.pendingInvites.isEmpty)
    }

    @Test("Remove co-parent succeeds")
    @MainActor
    func removeCoParentSucceeds() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")
        let coParentId = UUID()
        baby.addParent(coParentId)

        let result = appState.removeCoParent(coParentId, from: baby)

        #expect(result == true)
        #expect(!baby.parents.contains(coParentId))
    }

    @Test("Cannot remove creator via removeCoParent")
    @MainActor
    func cannotRemoveCreatorViaRemoveCoParent() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let result = appState.removeCoParent(appState.currentUser.id, from: baby)

        #expect(result == false)
        #expect(baby.parents.contains(appState.currentUser.id))
    }

    @Test("Simulate co-parent invite accepted adds co-parent")
    @MainActor
    func simulateCoParentInviteAcceptedAddsCoParent() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let mockCoParent = appState.simulateCoParentInviteAccepted(for: baby)

        #expect(baby.parents.count == 2)
        #expect(baby.parents.contains(mockCoParent.id))
    }

    @Test("isCreator returns correct value")
    @MainActor
    func isCreatorReturnsCorrectValue() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        #expect(appState.isCreator(of: baby) == true)

        let otherBaby = Baby(name: "Other", createdBy: UUID())
        appState.babies.append(otherBaby)

        #expect(appState.isCreator(of: otherBaby) == false)
    }
}

// MARK: - Baby Subscriber Tests

@Suite("Baby Subscriber Management")
struct BabySubscriberTests {

    @Test("Add subscriber succeeds")
    @MainActor
    func addSubscriberSucceeds() {
        let creatorId = UUID()
        let subscriberId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.addSubscriber(subscriberId)

        #expect(result == true)
        #expect(baby.subscribers.count == 1)
        #expect(baby.subscribers.contains(subscriberId))
    }

    @Test("Add duplicate subscriber fails")
    @MainActor
    func addDuplicateSubscriberFails() {
        let creatorId = UUID()
        let subscriberId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)
        baby.addSubscriber(subscriberId)

        let result = baby.addSubscriber(subscriberId)

        #expect(result == false)
        #expect(baby.subscribers.count == 1)
    }

    @Test("Parent cannot be subscriber")
    @MainActor
    func parentCannotBeSubscriber() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.addSubscriber(creatorId)

        #expect(result == false)
        #expect(baby.subscribers.isEmpty)
    }

    @Test("Remove subscriber succeeds")
    @MainActor
    func removeSubscriberSucceeds() {
        let creatorId = UUID()
        let subscriberId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)
        baby.addSubscriber(subscriberId)

        let result = baby.removeSubscriber(subscriberId)

        #expect(result == true)
        #expect(baby.subscribers.isEmpty)
    }

    @Test("Remove non-existent subscriber fails")
    @MainActor
    func removeNonExistentSubscriberFails() {
        let creatorId = UUID()
        let randomId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        let result = baby.removeSubscriber(randomId)

        #expect(result == false)
    }

    @Test("isSubscriber returns correct value")
    @MainActor
    func isSubscriberReturnsCorrectValue() {
        let creatorId = UUID()
        let subscriberId = UUID()
        let randomId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)
        baby.addSubscriber(subscriberId)

        #expect(baby.isSubscriber(subscriberId) == true)
        #expect(baby.isSubscriber(randomId) == false)
        #expect(baby.isSubscriber(creatorId) == false)
    }

    @Test("subscriberCount returns correct count")
    @MainActor
    func subscriberCountReturnsCorrectCount() {
        let creatorId = UUID()
        let baby = Baby(name: "Emma", createdBy: creatorId)

        #expect(baby.subscriberCount == 0)

        baby.addSubscriber(UUID())
        #expect(baby.subscriberCount == 1)

        baby.addSubscriber(UUID())
        #expect(baby.subscriberCount == 2)
    }
}

// MARK: - AppState Subscriber Tests

@Suite("AppState Subscriber Management")
struct AppStateSubscriberTests {

    @Test("Create subscriber invite succeeds for parent")
    @MainActor
    func createSubscriberInviteSucceedsForParent() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let invite = appState.createSubscriberInvite(for: baby)

        #expect(invite != nil)
        #expect(invite?.babyId == baby.id)
        #expect(invite?.role == .subscriber)
        #expect(invite?.createdBy == appState.currentUser.id)
        #expect(appState.pendingInvites.count == 1)
    }

    @Test("Create subscriber invite fails for non-parent")
    @MainActor
    func createSubscriberInviteFailsForNonParent() {
        let appState = AppState()
        let otherUser = User()
        let baby = Baby(name: "Emma", createdBy: otherUser.id)
        appState.babies.append(baby)

        let invite = appState.createSubscriberInvite(for: baby)

        #expect(invite == nil)
        #expect(appState.pendingInvites.isEmpty)
    }

    @Test("Redeem subscriber invite adds user as subscriber")
    @MainActor
    func redeemSubscriberInviteAddsUserAsSubscriber() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")
        let invite = appState.createSubscriberInvite(for: baby)!

        // Simulate a different user redeeming
        let newUser = User()
        appState.currentUser = newUser
        appState.babies = [baby]

        let result = appState.redeemInvite(invite)

        #expect(result != nil)
        #expect(baby.subscribers.contains(newUser.id))
        #expect(invite.isRedeemed == true)
    }

    @Test("Remove subscriber succeeds")
    @MainActor
    func removeSubscriberSucceeds() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")
        let subscriberId = UUID()
        baby.addSubscriber(subscriberId)

        let result = appState.removeSubscriber(subscriberId, from: baby)

        #expect(result == true)
        #expect(!baby.subscribers.contains(subscriberId))
    }

    @Test("Remove subscriber fails for non-parent")
    @MainActor
    func removeSubscriberFailsForNonParent() {
        let appState = AppState()
        let otherUser = User()
        let baby = Baby(name: "Emma", createdBy: otherUser.id)
        let subscriberId = UUID()
        baby.addSubscriber(subscriberId)
        appState.babies.append(baby)

        let result = appState.removeSubscriber(subscriberId, from: baby)

        #expect(result == false)
        #expect(baby.subscribers.contains(subscriberId))
    }

    @Test("Simulate subscriber invite accepted adds subscriber")
    @MainActor
    func simulateSubscriberInviteAcceptedAddsSubscriber() {
        let appState = AppState()
        let baby = appState.createBaby(name: "Emma")

        let mockSubscriber = appState.simulateSubscriberInviteAccepted(for: baby)

        #expect(baby.subscribers.count == 1)
        #expect(baby.subscribers.contains(mockSubscriber.id))
    }
}
