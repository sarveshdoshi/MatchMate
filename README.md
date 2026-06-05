# MatchMate

A matrimonial match-card iOS app built with SwiftUI. MatchMate fetches candidate profiles from a public API, presents them as Shaadi.com-style match cards, and lets the user accept or decline each match. Decisions are stored locally and persist across launches and offline sessions.

---

## Features

- **Profile match cards** — a redesigned, Shaadi.com-style card with a circular avatar, a decision badge, a compatibility pill, and detail rows for age/location and region. Undecided cards offer **Pass / Connect** actions; decided cards show a **Member Accepted** / **Member Declined** status bar.
- **Status filter** — a filter in the navigation bar scopes the list to **All / Accepted / Declined**. Filtering is instant (no refetch) and shows a tailored empty state when a filter has no matches.
- **Persistent decisions** — accepting or declining a match is saved to a local Core Data store and survives app restarts.
- **Offline-first** — cached profiles are shown when there's no connection, and accept/decline keeps working offline. An offline banner informs the user of connectivity state.
- **Graceful degradation** — if a live fetch fails, the app falls back to cached data instead of showing an error.
- **Optimistic UI with feedback** — accept/decline updates the card instantly. If the underlying write fails, the change is rolled back **and** an alert tells the user the action couldn't be saved.
- **Pull-to-refresh** to re-fetch the latest profiles.
- **Loading, empty, and error states** with a retry path.
- **Accessibility** — VoiceOver labels on interactive elements and Dynamic Type support.
- **Consistent theming** — a shared `Theme` palette centralises the teal/coral brand colours used across the UI.

---

## Tech Stack

| Concern | Choice |
|---------|--------|
| UI | SwiftUI |
| Architecture | MVVM + Clean Architecture |
| Concurrency | Swift `async/await` |
| Reactive binding | Combine (`@Published`, connectivity stream) |
| Networking | `URLSession` (protocol-abstracted) |
| Persistence | Core Data |
| Connectivity | `NWPathMonitor` (Network framework) |
| Image loading | [SDWebImageSwiftUI](https://github.com/SDWebImage/SDWebImageSwiftUI) |
| Dependency management | Swift Package Manager |
| Testing | XCTest |

---

## Architecture

MatchMate uses **MVVM layered on Clean Architecture**, organised so the single feature today can scale to many features without rework.

```
Presentation  →  Domain  ←  Data
                   ↑
                 Core
```

- **Domain** is the innermost layer — pure Swift models, use cases, and repository protocols. No framework imports.
- **Data** implements the Domain's repository protocol using a remote (API) and a local (Core Data) data source.
- **Presentation** holds the `@MainActor` ViewModel and SwiftUI views, depending only on Domain use cases.
- **Core** provides shared infrastructure (networking, persistence, connectivity) behind protocols so every layer is testable and swappable.

### Dependency Flow

```
randomuser.me API
      │  URLSession (async/await)
      ▼
MatchRemoteDataSource ──► DTO ──► MatchProfileMapper ──► MatchProfile (domain)
      │                                                        │
      ▼                                                        ▼
MatchRepository  ◄──────────────  MatchLocalDataSource (Core Data, upsert)
      │  (offline-first orchestration)
      ▼
FetchMatchesUseCase / UpdateMatchStatusUseCase
      ▼
MatchListViewModel  (@MainActor, ViewState, Combine)
      ▼
MatchListView / MatchCardView  (SwiftUI)
```

### Offline-First Strategy

The repository is the single source of truth and applies this logic:

- **Online** → fetch from API, map, upsert into Core Data (existing accept/decline status is **preserved**), return the merged local state.
- **Offline** → return cached profiles directly.
- **Online but fetch fails** → fall back to the cache so the UI still has data.
- **Accept/Decline** → always written straight to Core Data, so it works with or without a connection.
- **Failed write** → the optimistic UI change is rolled back and the user is shown an alert explaining the decision couldn't be saved.

### Dependency Injection

Composition happens through plain, protocol-based containers with constructor injection — no service-locator or global singletons for business logic:

- `DependencyContainer` (app root) creates the shared Core services once.
- `MatchCardContainer` (feature) builds the data sources, repository, use cases, and ViewModel.
- `AppCoordinator` composes feature coordinators and provides the root view.

This makes every layer independently unit-testable with hand-written mocks.

---

## Project Structure

```
MatchMate/
├── App/
│   ├── AppCoordinator.swift          # Composes feature coordinators
│   └── DependencyContainer.swift     # Root composition root
├── Core/
│   ├── Networking/                   # NetworkService, Endpoint, NetworkError
│   ├── Persistence/                  # CoreDataStack + .xcdatamodeld
│   └── Connectivity/                 # NetworkMonitor (NWPathMonitor)
├── Features/
│   └── MatchCard/
│       ├── Presentation/             # Views, ViewModel, Components, Models (filter)
│       ├── Domain/                   # Models, UseCases, Contracts
│       ├── Data/                     # DTOs, DataSources, Repository, Mapper
│       ├── Navigation/               # Coordinator + Route
│       └── DI/                       # MatchCardContainer
├── Shared/
│   ├── UI/                           # LoadingView, ErrorView, EmptyStateView, Theme
│   └── Utilities/                    # ViewState<T>
└── MatchMateApp.swift                # @main entry point

MatchMateTests/                       # Unit tests + mocks + fixtures
Docs/                                 # Architecture, rules, testing, git workflow
```

---

## API

Profiles are fetched from the [Random User Generator](https://randomuser.me):

```
GET https://randomuser.me/api/?results=10
```

The response is decoded into DTOs and mapped to the `MatchProfile` domain model. Profiles are uniquely identified by their `login.uuid`.

---

## Getting Started

### Requirements

- Xcode 16+ (project deployment target: iOS 26.5)
- Swift 5
- Internet connection on first launch (subsequent launches work offline from cache)

### Run

1. Clone the repository:
   ```bash
   git clone https://github.com/sarveshdoshi/MatchMate.git
   cd MatchMate
   ```
2. Open `MatchMate.xcodeproj` in Xcode.
3. Swift Package Manager resolves **SDWebImageSwiftUI** automatically on first open. If it doesn't, trigger **File → Packages → Resolve Package Versions**.
4. Select an iOS Simulator (e.g. iPhone 17 Pro) and press **⌘R**.

### Test

Run the unit test suite with **⌘U**, or from the command line:

```bash
xcodebuild test \
  -project MatchMate.xcodeproj \
  -scheme MatchMate \
  -destination "platform=iOS Simulator,name=iPhone 17 Pro"
```

---

## Testing

The project ships with **48 unit tests** covering the logic-bearing layers. UI rendering is intentionally not unit-tested.

| Suite | Focus |
|-------|-------|
| `MatchListViewModelTests` | State transitions, optimistic accept/decline + rollback, connectivity, offline |
| `MatchRepositoryTests` | Online/offline paths, fallback-on-failure, status preservation on refresh |
| `MatchLocalDataSourceTests` | Core Data upsert (no duplicates), status persistence — uses an in-memory store |
| `MatchProfileMapperTests` | DTO → domain mapping, missing/invalid field handling |
| `NetworkServiceTests` | Success, 4xx/5xx, decoding errors, no-internet — via `MockURLProtocol` |

All dependencies are mocked through protocols, and Core Data tests use an in-memory store for isolation and speed.

---

## Engineering Approach

Development was organised into independent, layer-scoped feature branches integrated through a **Git Flow** model (`main` ← `develop` ← `feature/*`). Each layer was built, committed, build-verified, and merged in dependency order:

```
core-infrastructure ─┐
match-card-domain ───┼─► develop ─► match-card-data ─┐
                                    match-card-presentation ─┼─► develop ─► navigation-di ─┐
                                                                            testing ───────┼─► develop ─► main
```

See [`Docs/`](Docs) for the full architecture, development rules, module boundaries, testing guidelines, and git workflow.

---

## Design Decisions & Trade-offs

- **Single source of truth in Core Data.** Even online, reads return the merged local state, so the UI is always consistent with persisted decisions.
- **Status preserved on refresh.** Re-fetching profiles upserts by stable id and never overwrites a user's accept/decline choice.
- **Optimistic updates with rollback and feedback.** The card reflects the user's action immediately; if the write fails, the change is reverted and an alert surfaces the failure, so the UI never lies about what's stored.
- **No sync-to-server.** The Random User API is read-only, so there's no remote write-back. The architecture (repository + data sources) is structured to add server sync later without touching the UI or domain layers.
- **Compatibility pill is a presentation placeholder.** The API exposes no compatibility signal, so the "Highly / Maybe Compatible" pill is derived deterministically in the presentation layer purely for the card visual. It's isolated behind a `Compatibility` type and ready to be wired to a real score when one exists.
- **Protocol-first.** Networking, persistence, and connectivity are all protocol-abstracted, which is what enables the focused unit-test suite and would allow swapping (e.g. URLSession → Alamofire, Core Data → SwiftData) with minimal blast radius.
