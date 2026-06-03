# Development Rules — MatchMate

## Core Principles

- Production-grade code quality (this is not a throwaway prototype)
- Offline-first persistence strategy
- Scalable architecture from day one
- Every layer independently testable

---

## Mandatory

- SwiftUI only (no UIKit)
- MVVM + Clean Architecture
- async/await for all asynchronous operations
- Combine for reactive data binding (ViewModel → View)
- Core Data for local persistence
- URLSession for networking (behind protocol)
- SDWebImageSwiftUI for image loading (via SPM)
- Protocol-based dependency injection (constructor injection)
- Coordinator-based navigation

---

## Forbidden

- Force unwraps (`!`)
- Implicitly unwrapped optionals (except @IBOutlet, which we don't use)
- Hardcoded strings in UI
- Business logic inside Views
- Direct networking inside ViewModels
- Singleton pattern for business logic
- `print()` in production code
- TODO / FIXME comments in final code
- Massive ViewModels (split into use cases)
- Any `Thread.sleep` or synchronous blocking

---

## View Rules

- Layout + binding only — no business logic
- Extract reusable components (card, buttons, status badge)
- Use `@StateObject` for ViewModel ownership
- Use `@ObservedObject` for injected ViewModels
- Accessibility labels on all interactive elements
- Dynamic Type support

---

## ViewModel Rules

- Annotate with `@MainActor`
- Expose state via `@Published` properties
- Use `ViewState<T>` enum for screen state
- Depend on protocols only (use cases, not concrete repositories)
- Handle all errors — never let exceptions propagate to View
- Cancellation-safe (store and cancel tasks appropriately)

---

## Networking Rules

- `NetworkService` conforms to `NetworkServiceProtocol`
- URLSession with async/await
- Type-safe `Endpoint` enum/struct for URL construction
- `NetworkError` enum for all failure cases
- Repository pattern: ViewModel never touches URLSession
- DTOs are Codable structs — separate from domain models
- Mapper converts DTO → Domain model

---

## Persistence Rules (Core Data)

- Dedicated `CoreDataStack` managing NSPersistentContainer
- Main context for UI reads
- Background context for writes (if needed for performance)
- Entity stores full profile + acceptance/decline status
- Writes happen immediately on user action (offline-safe)
- On fresh API fetch: upsert (don't duplicate existing profiles)

---

## Offline Behavior

- On launch: always show cached data from Core Data first
- If network available: fetch fresh data, merge into Core Data
- If offline: display cached data, accept/decline still functional
- `NetworkMonitor` (NWPathMonitor) tracks connectivity
- Architecture ready for sync-on-reconnect (even if API is read-only)

---

## Image Loading Rules

- Use `WebImage` from SDWebImageSwiftUI
- Provide placeholder image during load
- Leverage SDWebImage disk cache for offline display
- Handle failure gracefully (show fallback image)

---

## Combine Usage

- ViewModel publishes state changes via `@Published`
- Use `.receive(on: DispatchQueue.main)` where needed
- Cancellables stored properly (prevent leaks)
- Use Combine for composing async flows where it simplifies code

---

## Error Handling

- Network errors → mapped to `NetworkError` enum
- Core Data errors → logged, UI shows graceful fallback
- Decoding errors → treated as network failure (bad response)
- All errors surface to UI via `ViewState.error(message)`
- User always has a retry path

---

## Git Rules

- Small, atomic commits with clear messages
- Feature branch workflow
- No direct pushes to main
- Commit often — show progress in history

---

## Code Quality

- SwiftLint + SwiftFormat enforced
- Consistent naming conventions
- MARK comments for file organization
- Access control (internal by default, private where appropriate)
- No dead code
