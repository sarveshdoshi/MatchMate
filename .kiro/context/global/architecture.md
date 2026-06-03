# Project Architecture (Global)

## Conventions
- SwiftUI
- MVVM + Clean Architecture
- async/await only
- Combine for reactive binding
- Feature-modular structure
- Coordinator navigation (NavigationStack)
- Protocol-based DI (constructor injection)
- Offline-first data strategy
- No force unwraps
- Accessibility supported
- SDWebImageSwiftUI for image loading

## Layer Structure (per feature)
- Presentation: Views, ViewModels (@MainActor), Components
- Domain: Models, Contracts (protocols), UseCases
- Data: DTOs, DataSources, Repositories, Mappers
- Navigation: Coordinator, Routes
- DI: Feature container

## Dependency Direction
- Presentation → Domain ← Data
- Domain never imports Data or Presentation
- Data implements Domain contracts
- Navigation orchestrates Presentation
- Core provides infrastructure to Data layer

## Package Management
- SPM only
- Dependencies: SDWebImageSwiftUI

## Navigation
- Coordinator + NavigationStack
- Each feature exposes its own Coordinator
- App-level AppCoordinator composes feature coordinators

## Networking
- URLSession with async/await
- Protocol-defined (NetworkServiceProtocol)
- Type-safe Endpoint construction

## Persistence
- Core Data (NSPersistentContainer)
- Offline-first: always read local, sync when online
- Accept/Decline persisted immediately

## Connectivity
- NWPathMonitor wrapped in NetworkMonitor
- Protocol-defined for testability

## Image Loading
- SDWebImageSwiftUI (WebImage)
- Disk caching for offline support
- Placeholder + failure fallback

## Testing
- XCTest
- Protocol-based mocks (hand-written)
- Single test target: MatchMateTests
- In-memory Core Data store for tests
