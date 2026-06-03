# Feature Context: Match Card — Data Layer

Feature ID: match-card-data
Status: Not Started

---

## Summary

Implement the data layer: DTOs, mappers, data sources (remote + local), and the repository that orchestrates offline-first data flow. This layer implements the Domain contracts.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/ARCHITECTURE.md]]
- #[[file:Docs/DEVELOPMENT_RULES.md]]

### Cross-Feature Dependencies
- Depends on `core-infrastructure` (NetworkService, CoreDataStack, NetworkMonitor)
- Depends on `match-card-domain` (MatchProfile, MatchStatus, MatchRepositoryProtocol)

---

## Scope

### DTOs
- `RandomUserResponseDTO` — top-level Codable response
  - `results: [RandomUserDTO]`
- `RandomUserDTO` — individual user Codable
  - Nested: `NameDTO { title, first, last }`
  - Nested: `LocationDTO { city, state, country }`
  - Nested: `DobDTO { date, age }`
  - Nested: `PictureDTO { large, medium, thumbnail }`
  - Nested: `LoginDTO { uuid }`
  - `email: String`, `phone: String`

### Mappers
- `MatchProfileMapper`
  - `static func map(_ dto: RandomUserDTO) -> MatchProfile?`
  - `static func map(_ entity: MatchEntity) -> MatchProfile?`
  - `static func mapToEntity(_ profile: MatchProfile, context: NSManagedObjectContext) -> MatchEntity`
  - Handles nil/missing fields gracefully (returns nil if critical fields missing)

### Data Sources
- `MatchRemoteDataSource`
  - Depends on: `NetworkServiceProtocol`
  - Method: `func fetchUsers() async throws -> [RandomUserDTO]`
  - Calls: `GET https://randomuser.me/api/?results=10`

- `MatchLocalDataSource`
  - Depends on: `CoreDataStack`
  - Methods:
    - `func fetchAll() async throws -> [MatchProfile]`
    - `func save(profiles: [MatchProfile]) async throws`
    - `func updateStatus(for profileId: String, to status: MatchStatus) async throws`
  - Upsert logic: match by `id` (login.uuid), update if exists

### Repository
- `MatchRepository` — conforms to `MatchRepositoryProtocol`
  - Depends on: `MatchRemoteDataSource`, `MatchLocalDataSource`, `NetworkMonitorProtocol`
  - `fetchMatches()` logic:
    1. If online → fetch remote → map DTOs → save to local → return merged list (preserving existing statuses)
    2. If offline → return local cache
    3. If online fetch fails → fallback to local cache
  - `updateStatus()` → delegates to local data source (immediate persist)

---

## Files to Create

```
Features/MatchCard/Data/
├── DTOs/
│   └── RandomUserResponseDTO.swift
├── Mappers/
│   └── MatchProfileMapper.swift
├── DataSources/
│   ├── MatchRemoteDataSource.swift
│   └── MatchLocalDataSource.swift
└── Repositories/
    └── MatchRepository.swift
```

---

## Acceptance Criteria

- [ ] RandomUserResponseDTO correctly decodes the API response
- [ ] MatchProfileMapper converts DTO → MatchProfile (handles missing fields)
- [ ] MatchProfileMapper converts MatchEntity → MatchProfile
- [ ] MatchRemoteDataSource fetches and returns DTOs
- [ ] MatchLocalDataSource reads/writes Core Data
- [ ] MatchLocalDataSource upserts (no duplicate profiles on re-fetch)
- [ ] MatchRepository uses online/offline strategy correctly
- [ ] MatchRepository preserves existing accept/decline status on re-fetch
- [ ] MatchRepository conforms to MatchRepositoryProtocol
- [ ] All dependencies injected via init (protocols)
- [ ] Code compiles with zero errors

---

## Offline-First Logic (Repository)

```
fetchMatches():
  if networkMonitor.isConnected:
    try:
      remoteDTOs = remoteDataSource.fetchUsers()
      profiles = mapper.map(remoteDTOs)
      localDataSource.save(profiles)  // upsert, preserving status
      return localDataSource.fetchAll()  // return merged state
    catch:
      return localDataSource.fetchAll()  // fallback on error
  else:
    return localDataSource.fetchAll()  // pure offline

updateStatus(profileId, status):
  localDataSource.updateStatus(profileId, status)  // always local
```

---

## Prompt for Chat Window

```
Implement the Data Layer for the MatchCard feature in MatchMate.

Read these files for context:
- Docs/ARCHITECTURE.md
- Docs/DEVELOPMENT_RULES.md
- .kiro/context/features/match-card-data/feature-context.md
- .kiro/context/features/core-infrastructure/feature-context.md (for Core APIs)
- .kiro/context/features/match-card-domain/feature-context.md (for domain models/protocols)

Build all files listed in the feature-context scope section. Implement offline-first repository logic. Upsert profiles on re-fetch (preserve existing statuses). All dependencies via protocol injection. Use async/await. No force unwraps.
```
