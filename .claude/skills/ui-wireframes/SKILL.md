---
name: UI Wireframes & Mockup Prompts
description: Create ASCII wireframes for iOS screens and generate Nano Banana Pro prompts for UI mockups. Use when user wants wireframes, mockups, screen designs, or says "design the screens" or "create mockups".
---

# UI Wireframes & Mockup Prompts

Create ASCII wireframes for key screens, iterate with the user, then generate Nano Banana Pro prompts they can use to create high-fidelity UI mockups.

## Prerequisites

- PRD should exist at `docs/PRD.md` (read it first for context)
- If no PRD exists, suggest running the PRD interview first

## Workflow

### Step 1: Identify Key Screens

Read the PRD and identify the core screens needed. Typically 4-6 screens for MVP:

1. List the screens from the PRD's "Key Screens" section
2. Propose the user flow connecting them
3. Confirm with user before wireframing

### Step 2: ASCII Wireframes

Create simple ASCII wireframes for each screen. Keep them rough but clear.

**Example format:**

```
┌─────────────────────────┐
│ ◀ Back      Home    ⚙️  │  <- Navigation bar
├─────────────────────────┤
│                         │
│   Welcome, Sarah        │  <- Header
│                         │
│ ┌─────────────────────┐ │
│ │ 🏃 Today's Workout  │ │  <- Card
│ │ 3 exercises · 20min │ │
│ │ [Start Now]         │ │
│ └─────────────────────┘ │
│                         │
│ ┌─────────────────────┐ │
│ │ 📊 Weekly Progress  │ │  <- Card
│ │ ████████░░ 80%      │ │
│ └─────────────────────┘ │
│                         │
├─────────────────────────┤
│  🏠    📋    👤    ⚙️   │  <- Tab bar
└─────────────────────────┘
```

**ASCII conventions:**
- `┌ ┐ └ ┘ │ ─ ├ ┤` for borders
- `[ Button ]` for tappable buttons
- `( Radio )` for radio buttons
- `[x] Checkbox` for checkboxes
- `[___________]` for text inputs
- `████░░` for progress bars
- Emoji for icons (SF Symbols equivalent)
- `<-` comments for element labels

### Step 3: Iterate

Present wireframes one or two at a time. Ask:
- "Does this layout match what you're thinking?"
- "Anything missing or in the wrong place?"
- "Should we adjust the hierarchy?"

Revise based on feedback until user approves.

### Step 4: Generate Nano Banana Pro Prompts

Once wireframes are approved, generate prompts for Nano Banana Pro.

**Use this template for a 4-screen mockup:**

```
Create a professional iOS app mockup showing exactly 4 iPhone screens arranged horizontally in a single high-resolution image.

APP CONCEPT:
{one-line description from PRD}

SCREENS (left to right):
1. {Screen 1 name}: {brief description of content/purpose}
2. {Screen 2 name}: {brief description of content/purpose}
3. {Screen 3 name}: {brief description of content/purpose}
4. {Screen 4 name}: {brief description of content/purpose}

VISUAL STYLE:
- Color palette: {primary color}, {secondary color}, {accent color}
- Style: {modern minimal / bold vibrant / soft friendly / etc.}
- Inspiration: {reference apps if mentioned in PRD}

TECHNICAL SPECS:
- Device: iPhone 16 Pro frame
- iOS 18 native components (SF Pro font, SF Symbols icons)
- 8pt grid spacing
- Realistic placeholder content (not lorem ipsum)
- Each screen labeled at bottom

COMPOSITION:
- Horizontal arrangement with subtle shadows
- Consistent lighting from top-left
- Neutral gradient background
- Clear visual hierarchy on each screen
```

**For individual screen deep-dives:**

```
Create a single high-fidelity iOS app screen mockup.

SCREEN: {Screen name}
PURPOSE: {what user accomplishes here}

CONTENT:
{list specific elements from the ASCII wireframe}

VISUAL STYLE:
- Color palette: {colors}
- Style: {descriptors}

SPECS:
- iPhone 16 Pro frame
- iOS 18 native components
- Realistic content, not placeholder text
- Show {specific state: empty / populated / loading / error}
```

### Step 5: Save Prompts

Write the generated prompts to `docs/mockup-prompts.md` so user can reference them.

## Output Format

Save to `docs/mockup-prompts.md`:

```markdown
# UI Mockup Prompts

Generated from ASCII wireframes for {App Name}.

## 4-Screen Overview

{paste the 4-screen prompt}

## Individual Screens

### Screen 1: {name}
{individual prompt}

### Screen 2: {name}
{individual prompt}

...

---
*Copy these prompts into Nano Banana Pro (Google AI Studio) to generate mockups.*
```

## Tips for Better Mockups

- Be specific about content (real names, real data, real copy)
- Mention design references from the PRD
- Specify states (empty, loading, error, success)
- Request "no placeholder text" or "realistic data"
- For apps with brand colors, include hex codes if known
- Request screen labels to keep track of the flow
