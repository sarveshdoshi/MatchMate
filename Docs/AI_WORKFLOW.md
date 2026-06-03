# AI Workflow — MatchMate

## Approach

Incremental, layer-by-layer development. Build bottom-up so each layer compiles independently before the next is added.

---

## Guiding Principles

- Build for production quality, not "just an assignment"
- Every file must be complete and functional (no placeholders)
- Follow architecture strictly — no shortcuts
- Ask before assuming any requirement
- Keep files focused (single responsibility)

---

## Implementation Phases

### Phase 1 — Core Infrastructure

- `CoreDataStack` (NSPersistentContainer setup)
- Core Data model (`MatchMate.xcdatamodeld` with MatchEntity)
- `NetworkServiceProtocol` + `NetworkService` (URLSession async/await)
- `Endpoint` (type-safe URL builder for randomuser.me)
- `NetworkError` enum
- `NetworkMonitorProtocol` + `NetworkMonitor` (NWPathMonitor)
- `ViewState<T>` enum

### Phase 2 — Domain Layer

- `MatchProfile` model (domain representation of a match)
- `MatchStatus` enum (none, accepted, declined)
- `MatchRepositoryProtocol`
- `FetchMatchesUseCase`
- `UpdateMatchStatusUseCase`

### Phase 3 — Data Layer

- `RandomUserResponseDTO` (Codable, mirrors API response)
- `MatchProfileMapper` (DTO → Domain)
- `MatchRemoteDataSource` (fetches from API)
- `MatchLocalDataSource` (reads/writes Core Data)
- `MatchRepository` (orchestrates remote + local, offline-first)

### Phase 4 — Presentation Layer

- `MatchListViewModel` (@MainActor, Combine, ViewState)
- `MatchCardView` (single profile card with image, details, buttons)
- `ProfileImageView` (SDWebImageSwiftUI WebImage wrapper)
- `ActionButtonsView` (Accept / Decline circular buttons)
- `StatusBadgeView` (Accepted / Declined label after action)
- `MatchListView` (List/ScrollView of cards)

### Phase 5 — Navigation & DI

- `MatchCardCoordinator`
- `MatchCardRoute`
- `MatchCardContainer` (feature DI)
- `DependencyContainer` (root composition)
- `AppCoordinator`
- Wire everything in `MatchMateApp.swift`

### Phase 6 — Polish & Quality

- Error state UI (retry button)
- Loading state (skeleton or spinner)
- Empty state
- Smooth animations on accept/decline
- Accessibility labels
- SDWebImage placeholders and failure images
- SwiftLint / SwiftFormat pass

### Phase 7 — Testing

- ViewModel unit tests (fetch, accept, decline, offline)
- Repository unit tests (online fetch, offline fallback, status update)
- Mapper unit tests (DTO → Domain conversion)
- NetworkService tests (mock URLProtocol)

### Phase 8 — Documentation

- README.md (functionality, tech stack, setup instructions, screenshots)
- Clean commit history

---

## Validation After Each Phase

- Code compiles without errors or warnings
- Architecture boundaries respected (check imports)
- No force unwraps, no hardcoded strings
- Existing functionality not broken

---

## AI Behavior Rules

- Never skip a phase
- Never generate code that doesn't compile
- If a dependency from a previous phase is missing, build it first
- Ask for clarification rather than assume
- One responsibility per file
- Each phase should be a committable unit
