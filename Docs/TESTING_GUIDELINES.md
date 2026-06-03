# Testing Guidelines — MatchMate

## Philosophy

- Test behavior, not implementation details
- Protocol-based mocking (lightweight, hand-written)
- Cover happy path, error path, and edge cases
- Tests should be fast, deterministic, and isolated

---

## Test Target

`MatchMateTests` — single unified test target

---

## What to Test

### ViewModel Tests (`MatchListViewModelTests`)

```
- fetchMatches → online → state becomes .loaded with profiles
- fetchMatches → offline → state becomes .loaded with cached data
- fetchMatches → network error → state becomes .error
- fetchMatches → empty response → state becomes .loaded([])
- acceptMatch → updates correct profile to .accepted
- declineMatch → updates correct profile to .declined
- acceptMatch → persists to Core Data
- declineMatch → persists to Core Data
```

### Repository Tests (`MatchRepositoryTests`)

```
- online fetch → returns mapped profiles + caches to local
- offline fetch → returns local cached profiles
- online fetch fails → falls back to local cache
- updateStatus → writes to local data source
- fetch with empty API response → returns empty array
- fetch with malformed API response → returns error
```

### Mapper Tests (`MatchProfileMapperTests`)

```
- valid DTO → correct domain model
- missing optional fields → handled gracefully (defaults)
- multiple results → maps all correctly
```

### NetworkService Tests (`NetworkServiceTests`)

```
- successful response → returns decoded data
- 4xx response → returns appropriate NetworkError
- 5xx response → returns server error
- no internet → returns connectivity error
- malformed JSON → returns decoding error
```

---

## Mocking Strategy

- Define protocols for: `NetworkServiceProtocol`, `MatchRepositoryProtocol`, `NetworkMonitorProtocol`, `MatchLocalDataSource`, `MatchRemoteDataSource`
- Create mock implementations in test target:
  - `MockNetworkService`
  - `MockMatchRepository`
  - `MockNetworkMonitor`
  - `MockLocalDataSource`
  - `MockRemoteDataSource`
- Mocks are configurable (inject success/failure responses)

---

## Test Naming Convention

```swift
func test_fetchMatches_whenOnline_shouldReturnMappedProfiles()
func test_fetchMatches_whenOffline_shouldReturnCachedData()
func test_acceptMatch_shouldUpdateStatusToAccepted()
func test_declineMatch_shouldPersistDeclinedStatus()
```

Format: `test_{action}_when{Condition}_should{ExpectedResult}`

---

## Core Data Testing

- Use in-memory NSPersistentContainer for tests (no disk I/O)
- Reset store between tests for isolation
- Test both read and write operations

---

## What NOT to Test (for this scope)

- SwiftUI view rendering (no snapshot tests required)
- UI tests (nice to have, not essential)
- SDWebImage internals
- Network framework internals

---

## Test Organization

```
MatchMateTests/
├── ViewModels/
│   └── MatchListViewModelTests.swift
├── Repositories/
│   └── MatchRepositoryTests.swift
├── Mappers/
│   └── MatchProfileMapperTests.swift
├── Networking/
│   └── NetworkServiceTests.swift
└── Mocks/
    ├── MockNetworkService.swift
    ├── MockMatchRepository.swift
    ├── MockNetworkMonitor.swift
    ├── MockLocalDataSource.swift
    └── MockRemoteDataSource.swift
```
