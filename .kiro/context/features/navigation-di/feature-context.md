# Feature Context: Navigation & Dependency Injection

Feature ID: navigation-di
Status: Not Started

---

## Summary

Wire everything together: feature coordinator, DI container, app coordinator, and the main app entry point. This is the composition root that connects all layers.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/ARCHITECTURE.md]]
- #[[file:Docs/MODULE_BOUNDARIES.md]]

### Cross-Feature Dependencies
- Depends on ALL other features being complete:
  - `core-infrastructure` (CoreDataStack, NetworkService, NetworkMonitor)
  - `match-card-domain` (UseCases, Protocols)
  - `match-card-data` (Repository, DataSources)
  - `match-card-presentation` (ViewModel, Views)

---

## Scope

### Feature DI Container
- `MatchCardContainer`
  - Creates: MatchRemoteDataSource, MatchLocalDataSource, MatchRepository, FetchMatchesUseCase, UpdateMatchStatusUseCase, MatchListViewModel
  - Dependencies received: CoreDataStack, NetworkService, NetworkMonitor

### Root DI Container
- `DependencyContainer`
  - Creates: CoreDataStack, NetworkService, NetworkMonitor
  - Creates feature containers: MatchCardContainer
  - Single source of truth for app-wide dependencies

### Navigation
- `MatchCardCoordinator` — provides the root view for match card feature
- `MatchCardRoute` — enum for feature routes (currently just `.list`)
- `AppCoordinator` — top-level coordinator, composes feature coordinators

### App Entry
- Update `MatchMateApp.swift` to use DependencyContainer + AppCoordinator

---

## Files to Create

```
Features/MatchCard/Navigation/
├── MatchCardCoordinator.swift
└── MatchCardRoute.swift

Features/MatchCard/DI/
└── MatchCardContainer.swift

App/
├── DependencyContainer.swift
└── AppCoordinator.swift
```

### Files to Update
```
MatchMate/MatchMateApp.swift  ← wire DI + coordinator
```

---

## DI Container Pattern

```swift
// Root container
final class DependencyContainer {
    lazy var coreDataStack = CoreDataStack()
    lazy var networkService: NetworkServiceProtocol = NetworkService()
    lazy var networkMonitor: NetworkMonitorProtocol = NetworkMonitor()
    
    lazy var matchCardContainer = MatchCardContainer(
        coreDataStack: coreDataStack,
        networkService: networkService,
        networkMonitor: networkMonitor
    )
}

// Feature container
final class MatchCardContainer {
    private let coreDataStack: CoreDataStack
    private let networkService: NetworkServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol
    
    func makeViewModel() -> MatchListViewModel {
        let remoteDataSource = MatchRemoteDataSource(networkService: networkService)
        let localDataSource = MatchLocalDataSource(coreDataStack: coreDataStack)
        let repository = MatchRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
            networkMonitor: networkMonitor
        )
        let fetchUseCase = FetchMatchesUseCase(repository: repository)
        let updateUseCase = UpdateMatchStatusUseCase(repository: repository)
        return MatchListViewModel(
            fetchMatchesUseCase: fetchUseCase,
            updateMatchStatusUseCase: updateUseCase,
            networkMonitor: networkMonitor
        )
    }
}
```

---

## Acceptance Criteria

- [ ] MatchCardContainer creates all dependencies correctly
- [ ] DependencyContainer creates core services + feature containers
- [ ] AppCoordinator provides NavigationStack with root view
- [ ] MatchMateApp.swift uses DependencyContainer to launch app
- [ ] App launches and shows MatchListView with data
- [ ] Full data flow works: API → Repository → UseCase → ViewModel → View
- [ ] Accept/Decline persists and survives app restart
- [ ] Offline mode works (kill network → app shows cached data)
- [ ] No circular dependencies
- [ ] No singletons (except DependencyContainer at app level)
- [ ] Code compiles with zero errors

---

## Prompt for Chat Window

```
Implement the Navigation & DI layer for MatchMate and wire the app together.

Read these files for context:
- Docs/ARCHITECTURE.md
- Docs/MODULE_BOUNDARIES.md
- .kiro/context/features/navigation-di/feature-context.md

All other layers are already built. Create the DI containers, coordinators, and update MatchMateApp.swift to use them. Follow the DI container pattern in the feature context. The app should launch and display the match card list with full data flow working end-to-end.
```
