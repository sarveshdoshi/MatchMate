# Module Boundaries — MatchMate

## Design Philosophy

Even though the initial scope is a single feature (match cards), the architecture is designed for multi-feature scale. Module boundaries are enforced from the start to demonstrate engineering maturity.

---

## High-Level Dependency Graph

```
App (entry point, composition root)
 ↓
Features/ (feature modules)
 ↓           ↓
Domain ← Data (Data implements Domain contracts)
 ↓
Core/ (infrastructure)
 ↓
Shared/ (cross-cutting UI + utilities)
```

---

## App Layer

| Item | Responsibility |
|------|---------------|
| MatchMateApp | SwiftUI App entry, scene setup |
| AppCoordinator | Composes feature coordinators |
| DependencyContainer | Root DI — creates and provides all dependencies |

Rules:
- Composition root only — no business logic
- Instantiates containers, wires dependencies
- Owns the NavigationStack

---

## Features Layer

Each feature is fully self-contained:

```
Features/{FeatureName}/
├── Presentation/  (Views, ViewModels, Components)
├── Domain/        (Models, UseCases, Contracts)
├── Data/          (DTOs, Repositories, DataSources, Mappers)
├── Navigation/    (Coordinator, Routes)
└── DI/            (Feature-specific container)
```

### Current Features

| Feature | Responsibility |
|---------|---------------|
| MatchCard | Profile listing, card display, accept/decline actions |

### Future Features (architecture supports)
- ProfileDetail — detailed profile view
- Chat — messaging between matched users
- Settings — user preferences
- Filters — match filtering criteria

---

## Core Layer

Infrastructure shared across all features:

| Module | Responsibility |
|--------|---------------|
| Networking | URLSession service, endpoint builder, error types |
| Persistence | Core Data stack, managed object extensions |
| Connectivity | NWPathMonitor wrapper for online/offline detection |
| Extensions | Common Swift/Foundation/SwiftUI extensions |

Rules:
- Core has **zero knowledge** of any feature
- All services defined as protocols
- Features depend on Core protocols, not concrete implementations

---

## Shared Layer

Cross-cutting utilities and reusable UI:

| Module | Responsibility |
|--------|---------------|
| UI | LoadingView, ErrorView, EmptyStateView |
| Utilities | ViewState enum, common helpers |

Rules:
- No feature-specific logic
- No Core dependencies
- Purely reusable, stateless components

---

## Dependency Rules (enforced)

| From | Can Depend On | Cannot Depend On |
|------|--------------|-----------------|
| App | Features, Core, Shared | — |
| Feature/Presentation | Feature/Domain, Shared | Feature/Data, Core |
| Feature/Domain | Nothing (pure Swift) | Presentation, Data, Core, Shared |
| Feature/Data | Feature/Domain (protocols), Core | Presentation |
| Feature/Navigation | Feature/Presentation | Data, Domain directly |
| Core | Foundation, Network framework | Features, Shared |
| Shared | SwiftUI, Foundation | Features, Core |

---

## Cross-Feature Communication

- Features **never** import each other directly
- Communication via Coordinator (navigation) or shared contracts
- Shared models live in `Shared/` if needed by multiple features
- Feature-specific models stay inside the feature

---

## Adding a New Feature

1. Create `Features/{NewFeature}/` with full layer structure
2. Create feature DI container
3. Create feature Coordinator + Routes
4. Register coordinator in AppCoordinator
5. Register container in root DependencyContainer
6. No existing feature code should be modified
