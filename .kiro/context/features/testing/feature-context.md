# Feature Context: Unit Tests

Feature ID: testing
Status: Not Started

---

## Summary

Write comprehensive unit tests covering ViewModel, Repository, Mapper, and NetworkService. Use protocol-based mocks and in-memory Core Data.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/TESTING_GUIDELINES.md]]

### Cross-Feature Dependencies
- Depends on ALL implementation features being complete
- Needs understanding of all protocols and interfaces

---

## Scope

### Mocks to Create
- `MockNetworkService` — conforms to `NetworkServiceProtocol`, returns configurable results
- `MockMatchRepository` — conforms to `MatchRepositoryProtocol`, returns configurable results
- `MockNetworkMonitor` — conforms to `NetworkMonitorProtocol`, configurable `isConnected`
- `MockLocalDataSource` — in-memory implementation of local data source
- `MockRemoteDataSource` — configurable remote data source

### Test Suites

**MatchListViewModelTests**
```
- test_fetchMatches_whenOnline_shouldSetStateToLoaded
- test_fetchMatches_whenOffline_shouldReturnCachedProfiles
- test_fetchMatches_whenError_shouldSetStateToError
- test_fetchMatches_whenEmpty_shouldSetStateToLoadedEmpty
- test_acceptMatch_shouldUpdateProfileStatusToAccepted
- test_declineMatch_shouldUpdateProfileStatusToDeclined
- test_acceptMatch_shouldCallUpdateUseCase
- test_declineMatch_shouldCallUpdateUseCase
- test_initialState_shouldBeIdle
```

**MatchRepositoryTests**
```
- test_fetchMatches_whenOnline_shouldReturnRemoteProfiles
- test_fetchMatches_whenOnline_shouldCacheToLocal
- test_fetchMatches_whenOffline_shouldReturnLocalCache
- test_fetchMatches_whenOnlineFetchFails_shouldFallbackToLocal
- test_fetchMatches_preservesExistingStatusOnRefresh
- test_updateStatus_shouldPersistToLocal
- test_updateStatus_whenProfileNotFound_shouldThrow
```

**MatchProfileMapperTests**
```
- test_mapDTO_withValidData_shouldReturnProfile
- test_mapDTO_withMissingName_shouldReturnNil
- test_mapDTO_withInvalidImageURL_shouldHandleGracefully
- test_mapMultipleDTOs_shouldReturnAllValid
```

**NetworkServiceTests** (optional, uses MockURLProtocol)
```
- test_request_withValidResponse_shouldReturnDecodedData
- test_request_with404_shouldReturnServerError
- test_request_with500_shouldReturnServerError
- test_request_withInvalidJSON_shouldReturnDecodingError
```

---

## Files to Create

```
MatchMateTests/
├── Mocks/
│   ├── MockNetworkService.swift
│   ├── MockMatchRepository.swift
│   ├── MockNetworkMonitor.swift
│   ├── MockLocalDataSource.swift
│   └── MockRemoteDataSource.swift
├── ViewModels/
│   └── MatchListViewModelTests.swift
├── Repositories/
│   └── MatchRepositoryTests.swift
├── Mappers/
│   └── MatchProfileMapperTests.swift
└── Networking/
    └── NetworkServiceTests.swift (optional)
```

---

## Testing Patterns

```swift
// Mock example
final class MockMatchRepository: MatchRepositoryProtocol {
    var fetchResult: Result<[MatchProfile], Error> = .success([])
    var updateStatusCalled = false
    var lastUpdatedProfileId: String?
    var lastUpdatedStatus: MatchStatus?
    
    func fetchMatches() async throws -> [MatchProfile] {
        try fetchResult.get()
    }
    
    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        updateStatusCalled = true
        lastUpdatedProfileId = profileId
        lastUpdatedStatus = status
    }
}
```

```swift
// Core Data in-memory for tests
let container = NSPersistentContainer(name: "MatchMate")
let description = NSPersistentStoreDescription()
description.type = NSInMemoryStoreType
container.persistentStoreDescriptions = [description]
container.loadPersistentStores { _, error in ... }
```

---

## Acceptance Criteria

- [ ] All ViewModel tests pass
- [ ] All Repository tests pass
- [ ] All Mapper tests pass
- [ ] Mocks are lightweight and configurable
- [ ] Tests use in-memory Core Data (no disk)
- [ ] Tests are deterministic (no flakiness)
- [ ] Test names follow convention: test_{action}_when{Condition}_should{Result}
- [ ] No test depends on network or external state

---

## Prompt for Chat Window

```
Implement unit tests for MatchMate.

Read these files for context:
- Docs/TESTING_GUIDELINES.md
- .kiro/context/features/testing/feature-context.md

Create all mocks and test suites listed in the feature context. Use protocol-based mocks. Use in-memory Core Data for persistence tests. All tests must be deterministic and isolated. Follow the naming convention. Test the ViewModel, Repository, and Mapper layers.
```
