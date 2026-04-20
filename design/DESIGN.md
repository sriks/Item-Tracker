# DESIGN.md

Design reference for ItemTracker. This document captures all UI/UX decisions made during the design process and should be used as the source of truth when building SwiftUI views.

---

## Device & Platform Target

- **Device**: iPhone 17 Pro (and all modern iPhones)
- **iOS**: 26.0+ — use iOS 26 Liquid Glass design language
- **Orientation**: Portrait only
- **Colour schemes**: Full light mode and dark mode support — no hardcoded colours

---

## Design Language: iOS 26 Liquid Glass

The app follows iOS 26's Liquid Glass aesthetic:

- Frosted translucent surfaces using `.ultraThinMaterial` or `.regularMaterial`
- Floating pill-shaped tab bar (not full-width) with blur background
- Thin hairline borders at low opacity (`Color.white.opacity(0.15)` in dark, `Color.black.opacity(0.1)` in light)
- No hard shadows — use opacity layers for depth
- Pure black wallpaper (`#080808`) in dark mode, off-white (`#F2F2F0`) in light mode
- Subtle ambient blobs behind glass surfaces are acceptable for depth (rendered via `RadialGradient` or `Canvas`)
- Dynamic Island — do not place content behind it

---

## Navigation: 3-Tab Architecture

**Tabs (in order):**

1. **Ask** — landing screen, primary action (SF Symbol: `magnifyingglass`). See the design inspiration under Ask folder.
2. **Items** — browse all items, entry point for spatial map (SF Symbol: `square.grid.2x2`)
3. **Settings** — preferences and theme (SF Symbol: `person.circle`)

**Tab bar treatment:**

- Floating pill — NOT a full-width bar
- Centred horizontally, floating above the home indicator
- Width: approximately 220pt (adapts to content)
- Background: `.ultraThinMaterial` with `Color.black.opacity(0.72)` overlay in dark mode
- Active tab: filled background pill within the bar (`Color.white.opacity(0.11)` in dark)
- Active icon + label: full-opacity white (dark) / black (light)
- Inactive icon + label: `opacity(0.3)`
- No coloured accent on active tab — pure monochrome in B&W theme

**Important:** The tab bar floats — it does NOT anchor to the bottom edge. Leave space for the home indicator below it.

---

## Colour System

### Two-Layer Colour Architecture

The app uses two independent colour layers that never bleed into each other:

#### Layer 1 — Shell Theme (accent colour)

Controls: tab bar active state, search bar tint, CTA buttons, mic button, answer pills.

Supported themes and their accent hex values:

| Theme name           | Accent colour           | Hex       |
| -------------------- | ----------------------- | --------- |
| Monochrome (default) | None — pure black/white | —         |
| Teal                 | Original green          | `#1D9E75` |
| Coral                | Warm red-orange         | `#D85A30` |
| Electric Indigo      | Blue-purple             | `#7F77DD` |
| Amber Gold           | Warm gold               | `#BA7517` |
| Arctic Blue          | Deep blue               | `#185FA5` |

In the **Monochrome theme**, the shell has zero colour. Room colours become the only colour in the entire UI — this is intentional and makes them more meaningful.

All themes are implemented as `MonochromeTheme` or `AccentTheme` (a single parameterised type). Theme instances carry the current `ColorScheme` internally so call sites receive pre-resolved `Color` values and need only one environment lookup: `@Environment(\.appTheme)`.

#### Layer 2 — Room Colours (spatial colour coding)

Controls: left-bar accent on list items, chip borders, filter pills, location selector swatches, map nodes.

Stored as a `ColorToken` enum (not a raw `Color`) so values are Codable for SwiftData serialisation. Room colours are the **same in both light and dark mode** — they are vivid enough to read on both black and near-white.

| Token     | Colour | Hex       | Default room |
| --------- | ------ | --------- | ------------ |
| `.amber`  | Amber  | `#EF9F27` | Kitchen      |
| `.blue`   | Blue   | `#378ADD` | Storage      |
| `.purple` | Purple | `#7F77DD` | Bathroom     |
| `.green`  | Green  | `#639922` | Office       |
| `.coral`  | Coral  | `#D85A30` | —            |
| `.teal`   | Teal   | `#1D9E75` | —            |
| `.pink`   | Pink   | `#D4537E` | —            |
| `.red`    | Red    | `#E24B4A` | —            |

**Key rules:**

- Room colours use **outline/border only** — no filled backgrounds — in the monochrome theme
- In accent themes, room colours may use subtle fill (`opacity(0.12–0.18)`)
- Room colour assignment (room name → token) is deferred until a Room model exists

#### Theme persistence

The selected theme ID is stored in `UserDefaults`. The active theme is injected as `@Environment(\.appTheme)` at the root of the view hierarchy (`ContentView`). When the device colour scheme changes, `ContentView` re-injects a fresh theme instance with the new scheme baked in.

---

## Design Constants (`DesignConstants`)

A single `DesignConstants` enum holds all fixed shape and layout numbers. No view hardcodes these values directly.

---

## Semantic Colours

The `AppTheme` protocol defines the full set of semantic colour properties. Every view reads colours exclusively from `@Environment(\.appTheme)` — zero hardcoded opacity values in views.

**Text:**

- `primaryText` — `white.opacity(0.92)` dark / `black.opacity(0.88)` light
- `secondaryText` — `white.opacity(0.36)` dark / `black.opacity(0.38)` light
- `tertiaryText` — `white.opacity(0.30)` both modes

**Surfaces:**

- `cardBackground` — `white.opacity(0.06)` dark / `black.opacity(0.04)` light
- `inputBackground` — `white.opacity(0.09)` dark / `black.opacity(0.06)` light
- `hairline` — `white.opacity(0.09)` dark / `black.opacity(0.08)` light

**Interactive / accent:**

- `accent` — pure white/black (monochrome) or the theme's accent hex
- `accentMuted` — accent at `opacity(0.15)`
- `accentBorder` — accent at `opacity(0.35)`
- `searchBarBackground` — same as `inputBackground`
- `searchBarBorder` — `white.opacity(0.18)` dark / `black.opacity(0.14)` light (monochrome); accent at `opacity(0.40)` in accent themes
- `tabBarBackground` — `Color(white: 0.08).opacity(0.85)` dark / `Color(white: 0.92).opacity(0.88)` light
- `activeTabForeground` — white/black (monochrome) or accent
- `micButtonBackground` — `white.opacity(0.10)` dark / `black.opacity(0.08)` light (monochrome); accent at `opacity(0.20)` in accent themes
- `answerPillBackground` — `white.opacity(0.12)` dark / `black.opacity(0.08)` light (monochrome); accent at `opacity(0.18)` in accent themes
- `answerPillForeground` — `white.opacity(0.95)` dark / `black.opacity(0.90)` light
- `ctaBackground` — white/black (monochrome) or solid accent

---

## Ask Screen (Landing / Home)

This is the primary screen. It is **search-first** — the query bar is the dominant element.

### Layout (top to bottom)

```
Status bar (system)
─────────────────────────────
App header row (logo + name)
Large title: "Where is it?"
Subtitle: "Ask in plain English"
─────────────────────────────
Section label: "RECENT"
Grouped list — recent searches (4 rows max visible)
  [Question text]  [Answer pill]  [›]
─────────────────────────────
Section label: "TRY ASKING"
Suggestion chips (3 chips)
  [room dot] [suggestion text]
─────────────────────────────
↕ flex spacer
─────────────────────────────
Hairline divider
Search capsule (bottom, thumb-reachable)
  [search icon] [placeholder text] [mic button]
Floating pill tab bar
Home indicator (system)
```

### Typography (iOS system fonts)

Use SwiftUI semantic text styles everywhere — they scale with Dynamic Type automatically. Only fall back to `.font(.system(size:weight:))` when no style matches.

| Element            | SwiftUI style                         | Approx. size | Colour (dark)                                           |
| ------------------ | ------------------------------------- | ------------ | ------------------------------------------------------- |
| Page title         | `.largeTitle.bold()` + `tracking(-1)` | 34pt         | `primaryText`                                           |
| Subtitle           | `.subheadline`                        | 15pt         | `secondaryText`                                         |
| App name header    | `.subheadline.weight(.semibold)`      | 15pt         | `primaryText`                                           |
| Section label      | `.caption.weight(.semibold)`          | 12pt         | `tertiaryText` — `.textCase(.uppercase)`                |
| Recent question    | `.subheadline`                        | 15pt         | `primaryText` at `opacity(0.82)`                        |
| Answer pill text   | `.footnote.weight(.medium)`           | 13pt         | `answerPillForeground`                                  |
| Chip text          | `.subheadline`                        | 15pt         | `secondaryText`                                         |
| Search placeholder | `.callout`                            | 16pt         | `tertiaryText`                                          |
| Tab label          | `.caption2.weight(.medium)`           | 11pt         | active: `activeTabForeground`, inactive: `tertiaryText` |

### App header

- Logo: 32×32pt rounded rect (`cornerRadius: 9`), white background in dark mode, filled with app icon mark
- App name: "ItemTracker", `.subheadline.weight(.semibold)`

### Large title

- "Where is it?" — `.largeTitle.bold()`, `tracking(-1)`
- Subtitle: "Ask in plain English" — `.subheadline`, `secondaryText`

### Recent searches grouped list

- Background: `cardBackground`, `cornerRadius: cornerRadiusCard`, border `borderWidth hairline`
- Row separator: `borderWidth hairline` hairline, inset `16pt` from edges
- Row padding: `13pt` vertical, `16pt` horizontal
- Disclosure chevron: right side, `tertiaryText`
- Answer pill: `answerPillBackground`, `border borderWidth`, `cornerRadius: cornerRadiusTag`, `padding: 3pt vertical, 10pt horizontal`
- Tapping a row re-runs the query

### Suggestion chips ("Try asking")

- Layout: vertical stack, `gap: itemGap`
- Each chip: `cardBackground`, `borderWidth`, `cornerRadius: cornerRadiusChip`, `padding: 11pt vertical, 14pt horizontal`
- Room dot: 8pt circle filled with the room's `ColorToken` colour
- In monochrome: chip border uses the room's `ColorToken` colour at `opacity(0.55)` — the only colour in the UI
- In accent themes: chip border uses `accentBorder`
- Tapping a chip pre-fills the search bar

### Search bar (bottom)

- Position: above tab bar, separated by a `borderWidth hairline` hairline
- Shape: `cornerRadius: cornerRadiusInput`, full width minus `horizontalPadding` padding
- Background: `searchBarBackground`
- Border: `borderWidth searchBarBorder`
- Padding inside: `14pt` vertical, `18pt` horizontal
- Search icon: SF Symbol `magnifyingglass`, `.callout`, `secondaryText`
- Placeholder: "Ask where something is…"
- Mic button: 32×32pt circle, `micButtonBackground`, SF Symbol `mic.fill`
- On tap: expand to full keyboard input, placeholder clears, mic button becomes send button (`arrow.up.circle.fill`)

### Floating pill tab bar

- Width: ~220pt, centred
- Height: ~68pt including internal padding
- Background: `.ultraThinMaterial` + `tabBarBackground`
- `cornerRadius: cornerRadiusTabBar`
- Border: `borderWidth hairline` in dark
- Active tab pill: `white.opacity(0.11)` background, `cornerRadius: 22`
- Tab icons: SF Symbols, `.title3` size, `weight: .regular`
- Tab labels: `.caption2.weight(.medium)`
- Bottom padding from home indicator: `tabBarBottomPadding`

---

## Items Screen

Entry point for all saved items. Contains two views toggled by a segmented control.

### View toggle

- Position: top-right of screen, next to "All items" heading
- Style: small segmented control — `List | Map`
- Background: `inputBackground`, `cornerRadius: 7`
- Active segment: `white.opacity(0.14)` fill

### List view

- Each item row: `cardBackground`, `cornerRadius: cornerRadiusRoom`, `border borderWidth hairline`
- Left colour bar: 3pt wide, full row height, filled with room `ColorToken` colour — `cornerRadius: 2`
- Item text: 14pt regular, `primaryText`
- Room tag pill: outline only using room colour (`opacity(0.5)` border, room colour text)
- Date: 12pt, `tertiaryText`

### Filter pills

- Horizontal scroll row below heading
- "All" pill: `accent` fill when active (monochrome)
- Room filter pills: `ColorToken` colour border + text, transparent background
- Active room filter: `ColorToken` colour background at `opacity(0.18)`

### Map view (future feature)

- Toggled via the `List | Map` segmented control — no separate tab needed
- Floor plan grid of rooms, each room card uses its `ColorToken` colour as a border
- Selected room: `ColorToken` colour border at full opacity, plus tick indicator
- Items in selected room listed in a detail panel below the map grid

### Bottom search bar

- Same capsule style as Ask screen
- Placeholder: "Filter items…"
- Right side: `+` FAB button (32×32 circle) to add new item
- FAB background: monochrome → `micButtonBackground`; accent themes → `ctaBackground`

---

## Tag an Item (Add Content) Screen

Presented as a sheet modal sliding up over the Items screen.

### Sheet handle

- 36×4pt pill, `white.opacity(0.20)`, centred at top

### Fields

- **Note textarea**: free-text, "Describe what it is and where you put it"
  - Background: `inputBackground`, border `borderWidth hairline`, `cornerRadius: cornerRadiusRoom`
  - Min height: ~80pt
- **Location selector**: 2×2 grid of room cards
  - Each card: `cornerRadius: cornerRadiusRoom`, room colour swatch dot (8pt), room name (medium), item count (muted)
  - Unselected: `cardBackground` background, `hairline` border
  - Selected: `cardBackground` background, room `ColorToken` colour border at `opacity(0.6)`, green tick indicator top-right

### Save button

- Full width, `cornerRadius: cornerRadiusChip`
- Background: `ctaBackground`
- Text: black (monochrome dark) / white (accent themes)

---

## SF Symbols Reference

| UI element           | Symbol                  |
| -------------------- | ----------------------- |
| Ask tab              | `magnifyingglass`       |
| Items tab            | `square.grid.2x2`       |
| Settings tab         | `person.circle`         |
| Search icon in bar   | `magnifyingglass`       |
| Mic button           | `mic.fill`              |
| Send button (active) | `arrow.up.circle.fill`  |
| Disclosure chevron   | `chevron.right`         |
| List view toggle     | `list.bullet`           |
| Map view toggle      | `map`                   |
| Add item FAB         | `plus`                  |
| Room selected tick   | `checkmark.circle.fill` |

---

## Implementation Priority

Build in this order:

1. Theme infrastructure (`AppTheme` protocol, `MonochromeTheme`, `AccentTheme`, `ColorToken`, `DesignConstants`, environment key) — **done**
2. `AskView` — full Ask screen layout
   - `AppHeaderView` — logo + name
   - `RecentSearchesView` — grouped list component
   - `SuggestionChipsView` — chip list
   - `BottomSearchBarView` — capsule search input
   - `FloatingTabBar` — pill tab bar
3. `ItemsView` — list + map toggle (next sprint)
4. `TagItemSheetView` — modal add sheet (next sprint)
5. Theme picker UI in Settings — Teal, Coral, Indigo, Amber, Arctic Blue (Settings sprint)
6. Room colour picker UI (future feature)

---

## Notes for Implementation

- All colours must come from `@Environment(\.appTheme)` — zero hardcoded opacity values in views
- Room colours come from `ColorToken.color` — never inline hex
- The floating tab bar is implemented as an overlay using `ZStack` or `.overlay(alignment: .bottom)` — NOT a `TabView` toolbar
- The search bar is pinned to the bottom of the safe area, above the tab bar
- `AskView` uses a `ScrollView` for the main content area so it scrolls behind the fixed bottom elements
- Large title styling: `.font(.largeTitle.bold())` with `.tracking(-1)`
- Dynamic Island: use `safeAreaInset` or respect `.safeAreaPadding(.top)` — never hardcode top padding
