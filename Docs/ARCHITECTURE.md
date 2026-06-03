# Architecture — MatchMate

## Tech Stack

- **UI**: SwiftUI
- **Architecture**: MVVM + Clean Architecture
- **Concurrency**: async/await
- **Reactive Binding**: Combine
- **Networking**: URLSession (async/await)
- **Image Loading**: SDWebImageSwiftUI (via SPM)
- **Persistence**: Core Data
- **Connectivity**: NWPathMonitor (Network framework)
- **Linting**: SwiftLint + SwiftFormat

---

## Architecture Style

- Feature-modular Clean Architecture
- Designed for scale: each feature is self-contained with its own layers
- Coordinator-based navigation (NavigationStack + Coordinator pattern)
- Protocol-driven dependency injection (constructor injection)
- Offline-first data strategy

---

## Project Structure

```
MatchMate/
├── App/
│   ├── MatchMateApp.swift
│   ├── AppCoordinator.swift
│   └── DependencyContainer.swift
│
├── Features/
│   └── MatchCard/
│       ├── Presentation/
│       │   ├── Views/
│       │   │   ├── MatchListView.swift
│       │   │   └── MatchCardView.swift
│       │   ├── ViewModels/
│       │   │   └── MatchListViewModel.swift
│       │   └── Components/
│       │       ├── ProfileImageView.swift
│       │       ├── ActionButtonsView.swift
│       │       └── StatusBadgeView.swift
│       ├── Domain/
│       │   ├── Models/
│       │   │   ├── MatchProfile.swift
│       │   │   └── MatchStatus.swift
│       │   ├── UseCases/
│       │   │   ├── FetchMatchesUseCase.swift
│       │   │   └── UpdateMatchStatusUseCase.swift
│       │   └── Contracts/
│       │       └── MatchRepositoryProtocol.swift
│       ├── Data/
│       │   ├── DTOs/
│       │   │   └── RandomUserResponseDTO.swift
│       │   ├── Repositories/
│       │   │   └── MatchRepository.swift
│       │   ├── DataSources/
│       │   │   ├── MatchRemoteDataSource.swift
│       │   │   └── MatchLocalDataSource.swift
│       │   └── Mappers/
│       │       └── MatchProfileMapper.swift
│       ├── Navigation/
│       │   ├── MatchCardCoordinator.swift
│       │   └── MatchCardRoute.swift
│       └── DI/
│           └── MatchCardContainer.swift
│
├── Core/
│   ├── Networking/
│   │   ├── NetworkService.swift
│   │   ├── NetworkServiceProtocol.swift
│   │   ├── Endpoint.swift
│   │   ├── HTTPMethod.swift
│   │   └── NetworkError.swift
│   ├── Persistence/
│   │   ├── CoreDataStack.swift
│   │   ├── MatchMate.xcdatamodeld/
│   │   └── ManagedObjectExtensions.swift
│   ├── Connectivity/
│   │   ├── NetworkMonitor.swift
│   │   └── NetworkMonitorProtocol.swift
│   └── Extensions/
│       ├── Publisher+Extensions.swift
│       └── View+Extensions.swift
│
├── Shared/
│   ├── UI/
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   └── EmptyStateView.swift
│   └── Utilities/
│       └── ViewState.swift
│
└── Resources/
    └── Assets.xcassets/
```

---

## Layer Responsibilities

### Presentation Layer
- SwiftUI Views (layout + binding only)
- ViewModels (@MainActor, @Published state, Combine pipelines)
- Reusable UI components (cards, buttons, badges)

### Domain Layer
- Pure business models (no framework imports)
- Use cases (single-responsibility business operations)
- Protocols/Contracts (repository interfaces)

### Data Layer
- Remote data source (API calls via NetworkService)
- Local data source (Core Data reads/writes)
- Repository (orchestrates remote + local, offline-first logic)
- DTOs (Codable API response models)
- Mappers (DTO → Domain model conversion)

### Navigation Layer
- Coordinator pattern with NavigationStack
- Route enums for type-safe navigation
- Feature coordinators compose into AppCoordinator

### Core Layer
- Infrastructure services (networking, persistence, connectivity)
- Protocol-defined for testability
- Shared across all features

---

## Dependency Direction

```
Presentation → Domain ← Data
                 ↑
               Core
```

- Domain is the innermost layer — no outward dependencies
- Presentation depends on Domain (models, use cases)
- Data depends on Domain (implements protocols) + Core (networking, persistence)
- Core is standalone infrastructure

---

## Data Flow

```
API (randomuser.me)
       ↓
NetworkService (URLSession async/await)
       ↓
RemoteDataSource → DTO
       ↓
Mapper → Domain Model
       ↓
Repository (writes to Core Data + returns to caller)
       ↓
UseCase
       ↓
ViewModel (@Published via Combine)
       ↓
View (SwiftUI binding)
```

---

## Offline-First Strategy

1. **App launch** → Repository reads from Core Data (local-first)
2. **If online** → Fetch from API, map, merge into Core Data, emit updated list
3. **If offline** → Return cached Core Data profiles as-is
4. **Accept/Decline** → Always writes to Core Data immediately (works offline)
5. **Reconnection** → Architecture supports sync (no server endpoint exists for this API, but pattern is in place)

---

## State Management

All ViewModels use a unified state enum:

```swift
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}
```

Combined with Combine's `@Published` for reactive UI updates.

---

## Image Loading

- **SDWebImageSwiftUI** (via SPM)
- Provides caching, placeholder, transition animations
- Handles offline gracefully (serves from disk cache)

---

## Dependency Injection

- Protocol-based (all dependencies defined as protocols)
- Constructor injection (no service locators, no singletons for logic)
- Per-feature DI containers that compose into root `DependencyContainer`
- Enables easy mocking for tests

---

## Navigation

- Coordinator pattern wrapping NavigationStack
- Each feature exposes a Coordinator
- AppCoordinator composes feature coordinators
- Routes defined as enums for compile-time safety
- Designed so adding screens (profile detail, chat, settings) is trivial

---

## Error Handling

- `NetworkError` enum for typed network failures
- Repository surfaces domain-level errors
- ViewModel maps errors to user-facing messages via `ViewState.error`
- No force unwraps — all optionals handled safely
- Core Data errors logged and gracefully degraded

---

## Scalability Considerations

This architecture supports:
- Adding new features (registration, chat, profile detail) without touching existing code
- Swapping networking layer (e.g., Alamofire) by conforming to `NetworkServiceProtocol`
- Swapping persistence (e.g., SwiftData) by conforming to data source protocols
- Adding real-time sync when a backend supports it
- A/B testing via DI container configuration
- Unit testing every layer in isolation
