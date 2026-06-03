# Feature Context: Core Infrastructure

Feature ID: core-infrastructure
Status: Not Started

---

## Summary

Build the foundational infrastructure layer that all features depend on: networking, persistence (Core Data), connectivity monitoring, and shared utilities.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/ARCHITECTURE.md]]
- #[[file:Docs/DEVELOPMENT_RULES.md]]

### Cross-Feature Dependencies
- None — this is the foundation. All other features depend on this.

---

## Scope

### Networking
- `NetworkServiceProtocol` — async/await protocol for HTTP requests
- `NetworkService` — URLSession implementation
- `Endpoint` — type-safe URL builder (base URL: `https://randomuser.me/api/`)
- `HTTPMethod` — enum (GET, POST, etc.)
- `NetworkError` — enum covering all failure cases (noInternet, serverError, decodingError, invalidResponse, unknown)

### Persistence
- `CoreDataStack` — NSPersistentContainer setup with main + background contexts
- `MatchMate.xcdatamodeld` — Core Data model file
- `MatchEntity` — managed object with properties: id (UUID), firstName, lastName, age, city, state, country, thumbnailURL, largeImageURL, email, phone, status (String: none/accepted/declined), fetchedAt (Date)
- Upsert logic: if profile with same email exists, update rather than duplicate

### Connectivity
- `NetworkMonitorProtocol` — protocol exposing `isConnected: Bool` publisher
- `NetworkMonitor` — NWPathMonitor wrapper, publishes connectivity via Combine

### Shared Utilities
- `ViewState<T>` enum — idle, loading, loaded(T), error(String)

---

## Files to Create

```
Core/
├── Networking/
│   ├── NetworkServiceProtocol.swift
│   ├── NetworkService.swift
│   ├── Endpoint.swift
│   ├── HTTPMethod.swift
│   └── NetworkError.swift
├── Persistence/
│   ├── CoreDataStack.swift
│   └── MatchMate.xcdatamodeld/
├── Connectivity/
│   ├── NetworkMonitorProtocol.swift
│   └── NetworkMonitor.swift
└── Extensions/
    └── (as needed)

Shared/
└── Utilities/
    └── ViewState.swift
```

---

## Acceptance Criteria

- [ ] NetworkService can perform GET request and decode JSON response
- [ ] NetworkService surfaces typed errors (NetworkError)
- [ ] CoreDataStack initializes with persistent container
- [ ] MatchEntity stores all required profile fields + status
- [ ] Core Data supports in-memory store (for tests)
- [ ] NetworkMonitor publishes connectivity changes
- [ ] ViewState enum defined and usable by any ViewModel
- [ ] All services are protocol-defined (testable)
- [ ] Code compiles with zero errors/warnings

---

## API Reference

```
GET https://randomuser.me/api/?results=10

Response shape:
{
  "results": [
    {
      "name": { "title": "", "first": "", "last": "" },
      "location": { "city": "", "state": "", "country": "" },
      "email": "",
      "phone": "",
      "dob": { "date": "", "age": 0 },
      "picture": { "large": "", "medium": "", "thumbnail": "" },
      "login": { "uuid": "" }
    }
  ]
}
```

---

## Constraints

- URLSession only (no Alamofire)
- Core Data only (no Realm, no SwiftData)
- NWPathMonitor from Network framework
- No third-party dependencies in Core layer
- All protocols must be mockable for unit tests

---

## Prompt for Chat Window

```
Implement the Core Infrastructure for MatchMate.

Read these files for context:
- Docs/ARCHITECTURE.md
- Docs/DEVELOPMENT_RULES.md
- .kiro/context/features/core-infrastructure/feature-context.md

Build all files listed in the feature-context scope section. Follow the architecture strictly. Every service must be protocol-defined. Core Data must support in-memory store for testing. No force unwraps. async/await only.
```
