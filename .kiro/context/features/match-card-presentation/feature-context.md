# Feature Context: Match Card — Presentation Layer

Feature ID: match-card-presentation
Status: Not Started

---

## Summary

Build the UI layer: ViewModel with Combine-powered state management, SwiftUI views for the match card list, individual card design, and action handling (accept/decline). Uses SDWebImageSwiftUI for images.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/ARCHITECTURE.md]]
- #[[file:Docs/DEVELOPMENT_RULES.md]]

### Cross-Feature Dependencies
- Depends on `match-card-domain` (MatchProfile, MatchStatus, FetchMatchesUseCase, UpdateMatchStatusUseCase)
- Depends on `core-infrastructure` (ViewState, NetworkMonitorProtocol)
- SDWebImageSwiftUI package must be added to project

---

## Scope

### ViewModel
- `MatchListViewModel`
  - `@MainActor`, `ObservableObject`
  - Dependencies (injected): `FetchMatchesUseCase`, `UpdateMatchStatusUseCase`, `NetworkMonitorProtocol`
  - Published state: `@Published var state: ViewState<[MatchProfile]> = .idle`
  - Published connectivity: `@Published var isOnline: Bool = true`
  - Methods:
    - `func fetchMatches() async` — loads profiles, updates state
    - `func accept(profile: MatchProfile)` — updates status to .accepted
    - `func decline(profile: MatchProfile)` — updates status to .declined
  - On accept/decline: update the local array immediately (optimistic UI) + persist via use case

### Views
- `MatchListView`
  - NavigationStack with title "Profile Matches"
  - Shows loading spinner when state is .loading
  - Shows error view with retry when state is .error
  - Shows ScrollView/List of MatchCardView items when state is .loaded
  - Offline indicator banner when !isOnline
  - Pull-to-refresh support

- `MatchCardView`
  - Card layout (rounded corners, shadow, white background)
  - Profile image (large) at top — using SDWebImageSwiftUI `WebImage`
  - Name (first + last) — bold, prominent
  - Details: "Age, City, State"
  - If status == .none: show Accept + Decline buttons
  - If status == .accepted: show green "Accepted" badge, hide buttons
  - If status == .declined: show orange/red "Declined" badge, hide buttons

### Reusable Components
- `ProfileImageView` — SDWebImageSwiftUI WebImage wrapper with placeholder and failure state
- `ActionButtonsView` — Accept (checkmark, green) + Decline (X, red/orange) circular buttons
- `StatusBadgeView` — "Member Accepted" (green) or "Member Declined" (orange) label/badge

---

## Files to Create

```
Features/MatchCard/Presentation/
├── Views/
│   ├── MatchListView.swift
│   └── MatchCardView.swift
├── ViewModels/
│   └── MatchListViewModel.swift
└── Components/
    ├── ProfileImageView.swift
    ├── ActionButtonsView.swift
    └── StatusBadgeView.swift

Shared/UI/
├── LoadingView.swift
├── ErrorView.swift
└── EmptyStateView.swift
```

---

## Card Design Spec

```
┌─────────────────────────────┐
│                             │
│        [Profile Image]      │  ← Large, rounded top corners
│                             │
├─────────────────────────────┤
│                             │
│      First Last Name        │  ← Bold, teal/dark color
│      Age, City, State       │  ← Gray subtitle
│                             │
│    [✕]           [✓]       │  ← Decline (left) / Accept (right)
│                             │  ← Circular buttons with icons
│                             │
└─────────────────────────────┘

After action:
┌─────────────────────────────┐
│        [Profile Image]      │
├─────────────────────────────┤
│      First Last Name        │
│      Age, City, State       │
│                             │
│    ┌── Member Accepted ──┐  │  ← Green badge (or "Member Declined" orange)
│    └─────────────────────┘  │
└─────────────────────────────┘
```

---

## Acceptance Criteria

- [ ] MatchListViewModel fetches profiles and publishes state
- [ ] Loading state shows spinner
- [ ] Error state shows message + retry button
- [ ] Loaded state shows list of cards
- [ ] Each card shows profile image, name, age + location
- [ ] Cards with status .none show Accept/Decline buttons
- [ ] Tapping Accept → card shows "Member Accepted" green badge, buttons hidden
- [ ] Tapping Decline → card shows "Member Declined" orange badge, buttons hidden
- [ ] Status persists (reload app → status preserved)
- [ ] Offline: cached cards display correctly
- [ ] Offline indicator visible when no network
- [ ] Pull-to-refresh triggers re-fetch
- [ ] Images load via SDWebImageSwiftUI with placeholder
- [ ] Smooth animation on accept/decline transition
- [ ] Accessibility labels on buttons and cards
- [ ] Code compiles with zero errors

---

## UI/UX Notes

- Card style: white background, corner radius 16, subtle shadow
- Image: aspect ratio fill, clipped to card top
- Name: system font, semibold, size ~20, teal color
- Location: system font, regular, size ~14, gray
- Accept button: green tint, checkmark SF Symbol
- Decline button: orange/red tint, xmark SF Symbol
- Status badge: rounded capsule, colored background with white text
- Animate status change (button fade out, badge fade in)
- Cards in a vertical scroll (LazyVStack or List)

---

## SDWebImageSwiftUI Usage

```swift
import SDWebImageSwiftUI

WebImage(url: profile.largeImageURL)
    .resizable()
    .placeholder {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .overlay(ProgressView())
    }
    .indicator(.activity)
    .transition(.fade(duration: 0.3))
    .scaledToFill()
    .frame(height: 250)
    .clipped()
```

---

## Prompt for Chat Window

```
Implement the Presentation Layer for the MatchCard feature in MatchMate.

Read these files for context:
- Docs/ARCHITECTURE.md
- Docs/DEVELOPMENT_RULES.md
- .kiro/context/features/match-card-presentation/feature-context.md
- .kiro/context/features/match-card-domain/feature-context.md (for domain models)

Build all files listed in the feature-context scope section. Use SDWebImageSwiftUI for images (import SDWebImageSwiftUI). ViewModel is @MainActor with Combine @Published state. Cards must show accept/decline buttons OR status badge based on MatchStatus. Animate transitions. Add accessibility labels. Follow the card design spec in the feature context.
```
