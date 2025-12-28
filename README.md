# Baby Office Hours

**One-way "bat signal" from parents to family when baby is available for FaceTime calls.**

A modern iOS app built with Swift 6 and SwiftUI that removes friction from spontaneous video calls. Parents broadcast availability with one tap, family gets notified immediately and can reach out if they're free.

## Tech Stack

- **Language**: Swift 6
- **UI Framework**: SwiftUI
- **Minimum iOS**: 17.0
- **Platforms**: iPhone only
- **Backend**: Firebase (Firestore + Cloud Messaging)
- **Architecture**: Workspace + SPM package

## AI Assistant Rules Files

This template includes **opinionated rules files** for popular AI coding assistants. These files establish coding standards, architectural patterns, and best practices for modern iOS development using the latest APIs and Swift features.

### Included Rules Files
- **Claude Code**: `CLAUDE.md` - Claude Code rules
- **Cursor**: `.cursor/*.mdc` - Cursor-specific rules
- **GitHub Copilot**: `.github/copilot-instructions.md` - GitHub Copilot rules

### Customization Options
These rules files are **starting points** - feel free to:
- ✅ **Edit them** to match your team's coding standards
- ✅ **Delete them** if you prefer different approaches
- ✅ **Add your own** rules for other AI tools
- ✅ **Update them** as new iOS APIs become available

### What Makes These Rules Opinionated
- **No ViewModels**: Embraces pure SwiftUI state management patterns
- **Swift 6+ Concurrency**: Enforces modern async/await over legacy patterns
- **Latest APIs**: Recommends iOS 18+ features with optional iOS 26 guidelines
- **Testing First**: Promotes Swift Testing framework over XCTest
- **Performance Focus**: Emphasizes @Observable over @Published for better performance

**Note for AI assistants**: You MUST read the relevant rules files before making changes to ensure consistency with project standards.

## Project Architecture

```
BabyOfficeHours/
├── BabyOfficeHours.xcworkspace/              # Open this file in Xcode
├── BabyOfficeHours.xcodeproj/                # App shell project
├── BabyOfficeHours/                          # App target (minimal)
│   ├── Assets.xcassets/                # App-level assets (icons, colors)
│   ├── BabyOfficeHoursApp.swift              # App entry point
│   └── BabyOfficeHours.xctestplan            # Test configuration
├── BabyOfficeHoursPackage/                   # 🚀 Primary development area
│   ├── Package.swift                   # Package configuration
│   ├── Sources/BabyOfficeHoursFeature/       # Your feature code
│   └── Tests/BabyOfficeHoursFeatureTests/    # Unit tests
└── BabyOfficeHoursUITests/                   # UI automation tests
```

## Key Architecture Points

### Workspace + SPM Structure
- **App Shell**: `BabyOfficeHours/` contains minimal app lifecycle code
- **Feature Code**: `BabyOfficeHoursPackage/Sources/BabyOfficeHoursFeature/` is where most development happens
- **Separation**: Business logic lives in the SPM package, app target just imports and displays it

### Buildable Folders (Xcode 16)
- Files added to the filesystem automatically appear in Xcode
- No need to manually add files to project targets
- Reduces project file conflicts in teams

## Development Notes

### Code Organization
Most development happens in `BabyOfficeHoursPackage/Sources/BabyOfficeHoursFeature/` - organize your code as you prefer.

### Public API Requirements
Types exposed to the app target need `public` access:
```swift
public struct NewView: View {
    public init() {}
    
    public var body: some View {
        // Your view code
    }
}
```

### Adding Dependencies
Edit `BabyOfficeHoursPackage/Package.swift` to add SPM dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/example/SomePackage", from: "1.0.0")
],
targets: [
    .target(
        name: "BabyOfficeHoursFeature",
        dependencies: ["SomePackage"]
    ),
]
```

### Test Structure
- **Unit Tests**: `BabyOfficeHoursPackage/Tests/BabyOfficeHoursFeatureTests/` (Swift Testing framework)
- **UI Tests**: `BabyOfficeHoursUITests/` (XCUITest framework)
- **Test Plan**: `BabyOfficeHours.xctestplan` coordinates all tests

## Configuration

### XCConfig Build Settings
Build settings are managed through **XCConfig files** in `Config/`:
- `Config/Shared.xcconfig` - Common settings (bundle ID, versions, deployment target)
- `Config/Debug.xcconfig` - Debug-specific settings  
- `Config/Release.xcconfig` - Release-specific settings
- `Config/Tests.xcconfig` - Test-specific settings

### Entitlements Management
App capabilities are managed through a **declarative entitlements file**:
- `Config/BabyOfficeHours.entitlements` - All app entitlements and capabilities
- AI agents can safely edit this XML file to add HealthKit, CloudKit, Push Notifications, etc.
- No need to modify complex Xcode project files

### Asset Management
- **App-Level Assets**: `BabyOfficeHours/Assets.xcassets/` (app icon, accent color)
- **Feature Assets**: Add `Resources/` folder to SPM package if needed

### SPM Package Resources
To include assets in your feature package:
```swift
.target(
    name: "BabyOfficeHoursFeature",
    dependencies: [],
    resources: [.process("Resources")]
)
```

## Getting Started

### Prerequisites
- Xcode 16+ (for Swift 6 support)
- iOS 17+ device or simulator
- Firebase account (for backend services)

### Setup

1. **Open the workspace** in Xcode:
   ```bash
   open BabyOfficeHours.xcworkspace
   ```

2. **Configure Firebase**:
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Download `GoogleService-Info.plist`
   - Add it to the `BabyOfficeHours/` directory (already in .gitignore)

3. **Build and run**:
   - Select the `BabyOfficeHours` scheme
   - Choose a simulator or device
   - Press Cmd+R to build and run

### Development Workflow

1. **Make changes** in `BabyOfficeHoursPackage/Sources/BabyOfficeHoursFeature/`
2. **Write tests** in `BabyOfficeHoursPackage/Tests/BabyOfficeHoursFeatureTests/`
3. **Run tests** with Cmd+U or via the test navigator

## Features (MVP)

- ✅ Baby profile creation
- ✅ One-tap availability toggle
- ✅ Co-parent management
- ✅ Subscriber invites via iMessage
- ✅ Push notifications for availability changes
- ✅ Multi-baby support

See `docs/PRD.md` for full product requirements.

## Project Structure

See `CLAUDE.md` for detailed architecture guidelines and coding standards.

---

**Generated with XcodeBuildMCP** - Tools for AI-assisted iOS development workflows.