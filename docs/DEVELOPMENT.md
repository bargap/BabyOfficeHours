# Development Guide

Quick reference for working with Baby Office Hours in Xcode and the iOS Simulator.

## Opening the Project

**Always open the workspace, not the project:**

```bash
open BabyOfficeHours.xcworkspace
```

Or double-click `BabyOfficeHours.xcworkspace` in Finder.

## Project Structure in Xcode

You'll see these main groups in the Xcode navigator:

```
BabyOfficeHours (Workspace)
├── BabyOfficeHours (App Shell)
│   ├── BabyOfficeHoursApp.swift    ← App entry point
│   └── Assets.xcassets              ← App icon, colors
├── BabyOfficeHoursPackage           ← ⭐ Most development happens here
│   ├── Sources/BabyOfficeHoursFeature/
│   │   └── ContentView.swift        ← Your feature code
│   └── Tests/BabyOfficeHoursFeatureTests/
│       └── BabyOfficeHoursFeatureTests.swift
└── BabyOfficeHoursUITests           ← UI automation tests
```

**Important**: Write your code in `BabyOfficeHoursPackage/Sources/BabyOfficeHoursFeature/`

## Building and Running

### Quick Start
1. Select the **BabyOfficeHours** scheme (top toolbar, next to stop button)
2. Choose a simulator: **iPhone 16** or any iOS 17+ device
3. Press **Cmd+R** (or click the Play button)

### Build Options
- **Cmd+B** - Build only (check for errors)
- **Cmd+R** - Build and run
- **Cmd+.** - Stop running app
- **Cmd+Shift+K** - Clean build folder

## Working with the Simulator

### Opening Simulator
- Simulator opens automatically when you run (Cmd+R)
- Or manually: `Xcode → Open Developer Tool → Simulator`

### Useful Simulator Features

**Hardware Menu**:
- **Rotate Device**: Cmd+Left/Right arrow (we're portrait-only though)
- **Home**: Cmd+Shift+H
- **Lock**: Cmd+L
- **Shake**: Cmd+Ctrl+Z

**Device Menu**:
- **Erase All Content**: Reset simulator to factory state
- **Trigger iCloud Sync**: Force cloud sync

**Debug Menu**:
- **Slow Animations**: See animations in slow motion
- **Color Blended Layers**: Performance debugging
- **Toggle Software Keyboard**: Cmd+K (use Mac keyboard vs on-screen)

### Quick Simulator Actions
- **Take Screenshot**: Cmd+S (saves to Desktop)
- **Record Video**: Simulator window → File → Record Screen
- **Copy/Paste**: Your Mac clipboard works in the simulator
- **Open URLs**: Drag Safari URL into simulator

## Testing

### Running Tests
- **Cmd+U** - Run all tests
- **Cmd+Ctrl+Option+U** - Run tests again without building
- Click diamond next to test function to run single test

### Test Navigator
- **Cmd+6** - Open test navigator
- See all tests organized by suite
- Green checkmarks = passed, Red X = failed

### Viewing Test Results
- Tests appear in **Report Navigator** (Cmd+9)
- Click on test run to see detailed results
- Failed tests show assertion details

## Debugging

### Breakpoints
- Click line number gutter to add breakpoint (blue marker appears)
- Run app (Cmd+R) - execution pauses at breakpoint
- **Step Over**: F6
- **Step Into**: F7
- **Step Out**: F8
- **Continue**: Cmd+Ctrl+Y

### Console Output
- **Show Debug Area**: Cmd+Shift+Y
- See `print()` statements and errors
- Use `po` command in console to inspect variables

### SwiftUI Preview
- Open any SwiftUI view file
- Click **Resume** button in canvas (right side)
- Or: Cmd+Option+P to refresh preview
- Live preview updates as you type

## File Management

### Adding New Files
1. Right-click `BabyOfficeHoursFeature` folder in navigator
2. Choose **New File** (Cmd+N)
3. Select **Swift File** or **SwiftUI View**
4. Save in `BabyOfficeHoursPackage/Sources/BabyOfficeHoursFeature/`

**Important**: Files auto-add to buildable folders (Xcode 16 feature)

### Organizing Code
Create folders in `Sources/BabyOfficeHoursFeature/`:
- `Features/` - Feature-specific views and logic
- `Shared/Components/` - Reusable UI components  
- `Shared/Models/` - Data models
- `Shared/Services/` - API clients, Firebase code

### Public Access Control
Types used in the app need `public`:
```swift
public struct MyView: View {
    public init() {}
    
    public var body: some View {
        Text("Hello")
    }
}
```

## Common Workflows

### Typical Development Loop
1. Edit code in `BabyOfficeHoursPackage/Sources/`
2. **Cmd+B** to build and check for errors
3. **Cmd+R** to run in simulator
4. Test the feature manually
5. Write tests in `Tests/BabyOfficeHoursFeatureTests/`
6. **Cmd+U** to run tests

### When Things Go Wrong

**Build Errors?**
- **Clean Build Folder**: Cmd+Shift+K, then Cmd+B
- Check error navigator (Cmd+5) for details
- Red errors = must fix, Yellow warnings = should fix

**Simulator Not Working?**
- Quit Simulator app completely
- **Reset Simulator**: Device → Erase All Content and Settings
- Try different simulator model

**Xcode Acting Weird?**
- Quit Xcode completely (Cmd+Q)
- Delete DerivedData: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Reopen workspace

**Can't Find Your Code Changes?**
- Make sure you're editing files in `BabyOfficeHoursPackage/`
- Check you're viewing the right scheme (top toolbar)

## Keyboard Shortcuts Cheat Sheet

### Navigation
- **Cmd+1** - Project navigator
- **Cmd+0** - Toggle navigator
- **Cmd+Option+0** - Toggle inspector
- **Cmd+Shift+Y** - Toggle debug area
- **Cmd+Shift+O** - Quick open (find any file)
- **Cmd+Ctrl+J** - Jump to definition
- **Cmd+Ctrl+Up/Down** - Switch between .swift and test file

### Build & Run
- **Cmd+B** - Build
- **Cmd+R** - Run
- **Cmd+U** - Test
- **Cmd+.** - Stop
- **Cmd+Shift+K** - Clean

### Editing
- **Cmd+/** - Comment/uncomment
- **Cmd+]** - Indent right
- **Cmd+[** - Indent left
- **Ctrl+I** - Re-indent selection
- **Cmd+Option+[** - Move line up
- **Cmd+Option+]** - Move line down

### SwiftUI
- **Cmd+Option+P** - Resume preview
- **Cmd+Option+Return** - Show canvas

## Viewing Logs

### Print Debugging
```swift
print("Debug: \(someVariable)")
```
Output appears in debug console (Cmd+Shift+Y)

### OSLog (Better Practice)
```swift
import os

let logger = Logger(subsystem: "com.example.babyofficehours", category: "network")
logger.debug("Loading data")
logger.error("Failed: \(error)")
```
View in **Console.app** for structured logs

## Firebase Integration

When you add `GoogleService-Info.plist`:
1. Drag file into `BabyOfficeHours/` folder in Xcode
2. **Uncheck** "Copy items if needed" (file is already there)
3. Make sure "BabyOfficeHours" target is checked
4. File should be in `.gitignore` (won't commit secrets)

## Performance Tips

- Use **SwiftUI Previews** for rapid iteration (faster than rebuilding)
- **Incremental builds** are automatic in Xcode 16+
- Keep simulator running between builds (faster launch)
- Use **Instruments** (Cmd+I) for profiling performance issues

## Getting Help

- **Quick Help**: Option+Click any symbol
- **Documentation**: Cmd+Shift+0 opens Developer Documentation
- **API Reference**: Select symbol, then Cmd+Shift+0 to search

---

Happy coding! Remember: most development happens in **BabyOfficeHoursPackage** 🚀
