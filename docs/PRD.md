# Baby Office Hours - Product Requirements Document

## Overview

**One-liner**: One-way "bat signal" from parents to family when baby is available for FaceTime calls right now.

**Target User**: Parents of infants/toddlers who want to make their baby available for video calls without scheduling burden, and extended family (grandparents, aunts, uncles) who want to connect but don't know when it's a good time.

**Problem**: Family members either shy away from calling (not wanting to interrupt) or call at bad times (putting parents in the awkward position of declining). Parents don't want the overhead of scheduling, and family doesn't want to guess.

## Goals

### Primary Goal
Remove friction from spontaneous video calls: parents broadcast availability with one tap, family gets notified immediately and can reach out if they're free.

### Non-Goals
- NOT a scheduling or calendar app
- NOT a video calling app (signals availability for FaceTime, doesn't replace it)
- NOT a baby tracker (sleep, feeding, diapers, etc.)
- NOT building a macOS companion app (removed from scope)

## User Stories

### MVP (v1.0)

- US-1: As a parent, I want to create a profile for my baby so I can start broadcasting availability
- US-2: As a parent, I want to toggle availability on/off with one tap so I can signal when video calls are welcome
- US-3: As a parent, I want to invite my partner as a co-parent so they can also toggle availability from their phone
- US-4: As a parent, I want to invite family members to subscribe so they get notified when we're available
- US-5: As a parent, I want to send a cute invite via iMessage so the experience feels polished and delightful
- US-6: As a family member, I want to accept an invite and follow a baby so I can see when they're available
- US-7: As a family member, I want to receive a push notification when the baby becomes available so I don't miss the window
- US-8: As a family member, I want to see current availability status in the app so I know if now is a good time
- US-9: As a user, I want to see a list of all babies I'm connected to (as parent or subscriber) so I can manage multiple relationships

### Future (v2.0+)

- US-F1: As a parent, I want to send notifications via SMS/iMessage to people who don't have the app installed
- US-F2: As a parent, I want to share a QR code invite for in-person signup
- US-F3: As a parent, I want to choose a cute icon when broadcasting (e.g., 🍼 feeding vibes, 👶 awake and happy)
- US-F4: As a parent, I want to see "baby is busy - please hold" auto-status when already on a FaceTime call (requires iOS call state detection)
- US-F5: As a family member, I want to initiate a FaceTime call from within the app when the signal is up

## Features

### Implementation Progress

| Feature | Status | Notes |
|---------|--------|-------|
| 1. Baby Profile Creation | ✅ Done | Onboarding flow, Baby/User models, AppState |
| 2. Availability Toggle | ✅ Done | Custom toggle, animations, status messages |
| 3. Co-Parent Management | ✅ Done | Invite model, settings view, mock invite flow |
| 4. Subscriber Management | ⏳ Pending | |
| 5. Recipient Experience | ⏳ Pending | |
| 6. Multi-Baby List View | ✅ Done | Basic list with parent/subscriber views |

**Blocked items** (require Firebase):
- Push notifications for availability changes
- Real-time sync across devices
- Invite link generation and redemption

---

### Core Features (MVP)

#### Feature 1: Baby Profile Creation ✅
**Description**: Parent creates a baby profile with name. This makes them a "parent" with full permissions.

**User Story**: US-1

**Acceptance Criteria**:
- [x] Parent can create one baby profile
- [x] Baby has a name (editable later)
- [x] Creator automatically gets parent role (can toggle, manage subscribers)

#### Feature 2: Availability Toggle ✅
**Description**: Big, obvious button to broadcast "baby is available now" or turn off the signal.

**User Story**: US-2

**Acceptance Criteria**:
- [x] Parents see interactive toggle on baby card
- [ ] Toggle sends push notification to all subscribers when turned ON *(requires Firebase)*
- [ ] Toggle sends notification when turned OFF *(requires Firebase)*
- [ ] Status persists and syncs across all parent devices *(requires Firebase)*

#### Feature 3: Co-Parent Management ✅
**Description**: Invite another parent (partner) who gets full toggle and management permissions.

**User Story**: US-3

**Acceptance Criteria**:
- [x] Parent can invite co-parent from baby settings
- [x] Co-parent gets full permissions (toggle, add/remove subscribers, delete baby)
- [x] Co-parents see the same baby card with interactive toggle
- [x] Can add co-parent after initial setup (not just during onboarding)

#### Feature 4: Subscriber Management
**Description**: Invite family members as subscribers (read-only recipients of availability status).

**User Story**: US-4, US-5

**Acceptance Criteria**:
- [ ] Parent can generate shareable invite link
- [ ] Invite opens as iMessage with cute preview card
- [ ] Parent can see list of current subscribers
- [ ] Parent can remove subscribers

#### Feature 5: Recipient Experience
**Description**: Family members join via invite, see status, and receive notifications.

**User Story**: US-6, US-7, US-8

**Acceptance Criteria**:
- [ ] Tapping invite link opens app with "Join [Baby Name]'s office hours?" prompt
- [ ] Accepting invite adds baby to recipient's list
- [ ] Recipients see baby card with read-only status indicator (no toggle)
- [ ] Recipients receive push notification when status changes to "available"
- [ ] Recipients can unsubscribe from baby settings

#### Feature 6: Multi-Baby List View ✅
**Description**: Main screen shows all babies user is connected to (as parent or recipient).

**User Story**: US-9

**Acceptance Criteria**:
- [x] Babies displayed as vertical list (not grid)
- [x] Parent role: baby card shows interactive toggle
- [x] Recipient role: baby card shows read-only status
- [x] Empty state when no babies connected yet

### Future Features

- SMS/iMessage-only notifications for non-app users
- QR code invite scanning
- Icon picker for broadcast signal (battery of cute emojis)
- FaceTime call initiation from app
- Auto-detect "baby is busy" when already on FaceTime call (iOS call state API exploration)

## Technical Requirements

### Platforms
- iPhone only (iOS 17+)
- No iPad, Apple Watch, or macOS support in v1

### Data Model

**Baby**
- `id`: UUID
- `name`: String
- `createdBy`: User ID (creator)
- `parents`: [User IDs] (creator + co-parents)
- `subscribers`: [User IDs] (recipients)
- `isAvailable`: Bool (current status)
- `lastStatusChange`: Timestamp

**User**
- `id`: UUID
- `deviceToken`: String (for push notifications)
- `babies`: [Baby IDs] (all babies user is connected to)

**Invite**
- `id`: UUID (shareable code)
- `babyId`: Baby ID
- `role`: "parent" | "recipient"
- `createdBy`: User ID
- `expiresAt`: Timestamp (optional)

### Persistence
- **Strategy**: Firebase Firestore for data sync
- **Sync**: Real-time listeners for status changes
- **Push**: Firebase Cloud Messaging (FCM) for notifications

### External Integrations
- **Firebase**: Firestore (database), Cloud Messaging (push notifications), Authentication (anonymous or sign-in with Apple)
- **Apple Push Notification service (APNs)**: via Firebase

### Offline Support
No offline mode. App requires network connection to broadcast/receive signals.

## Design

### Key Screens

1. **Onboarding**: "Create your baby" or "Join via invite"
2. **Main Screen**: List of baby cards (toggle for parents, status for recipients)
3. **Baby Settings**: Name, co-parents list, subscribers list, invite links, delete baby
4. **Invite Accept**: Modal prompt "Join [Baby Name]'s office hours?"

### Navigation Pattern
- Single-screen app for most users (main baby list)
- Tap baby card → baby settings (modal or push)
- No tabs needed for v1

### Design References
- Clean, minimal, Apple HIG-compliant
- Playful "office hours" theming:
  - "The baby is in"
  - "The baby will see you now"
  - "Office hours are over"
- Cute, opinionated UI (not corporate/sterile)

### iMessage Invite Card
- Preview shows baby name + cute graphic
- Tappable link opens app
- Fallback for non-app users: text explaining what it is

## Constraints

- Firebase free tier (should be sufficient for expected scale)
- iOS 17+ only (can use latest SwiftUI features)
- Push notifications require user permission (handle gracefully if denied)
- iMessage preview cards require Universal Links setup

## Open Questions

- **Authentication**: Anonymous auth (device-based) or Sign in with Apple for account persistence across devices?
  - Recommendation: Start with Sign in with Apple (simple, privacy-focused, enables cross-device sync)

- **Invite link format**: Universal Link (babyofficehours://invite/xyz) or deep link?
  - Recommendation: Universal Link for iMessage previews

- **Notification copy**: What's the exact wording when baby becomes available?
  - Suggestion: "[Baby Name] is in! The baby will see you now 👶"

- **Status change notifications**: Notify on both ON and OFF, or just ON?
  - Recommendation: Notify on ON only (OFF is less urgent)

---

*Generated: 2025-12-28*
