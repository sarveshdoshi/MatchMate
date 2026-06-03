# Feature Context: Match Card — Domain Layer

Feature ID: match-card-domain
Status: Not Started

---

## Summary

Define the pure business models, use case protocols, and repository contracts for the match card feature. This layer has ZERO external dependencies — pure Swift only.

---

## Dependencies

### Global Context (always load)
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:Docs/ARCHITECTURE.md]]
- #[[file:Docs/MODULE_BOUNDARIES.md]]

### Cross-Feature Dependencies
- Depends on `core-infrastructure` being complete (for understanding the Core Data entity shape)
- But this layer does NOT import Core — it defines its own models

---

## Scope

### Models
- `MatchProfile` — domain model representing a user profile
  - Properties: id (String), firstName (String), lastName (String), age (Int), city (String), state (String), country (String), thumbnailURL (URL), largeImageURL (URL), email (String), phone (String), status (MatchStatus)
  - Conforms to: Identifiable, Equatable

- `MatchStatus` — enum representing user's decision
  - Cases: .none, .accepted, .declined
  - Conforms to: String, CaseIterable, Equatable

### Contracts (Protocols)
- `MatchRepositoryProtocol`
  - `func fetchMatches() async throws -> [MatchProfile]`
  - `func updateStatus(for profileId: String, to status: MatchStatus) async throws`

### Use Cases
- `FetchMatchesUseCase`
  - Depends on: `MatchRepositoryProtocol`
  - Method: `func execute() async throws -> [MatchProfile]`
  - Simply delegates to repository (single responsibility, but enables interception/decoration later)

- `UpdateMatchStatusUseCase`
  - Depends on: `MatchRepositoryProtocol`
  - Method: `func execute(profileId: String, status: MatchStatus) async throws`
  - Validates status transition (can't accept/decline if already has same status — or allow toggle, your call)

---

## Files to Create

```
Features/MatchCard/Domain/
├── Models/
│   ├── MatchProfile.swift
│   └── MatchStatus.swift
├── Contracts/
│   └── MatchRepositoryProtocol.swift
└── UseCases/
    ├── FetchMatchesUseCase.swift
    └── UpdateMatchStatusUseCase.swift
```

---

## Acceptance Criteria

- [ ] MatchProfile is Identifiable and Equatable
- [ ] MatchStatus is a String-backed enum with none/accepted/declined
- [ ] MatchRepositoryProtocol defines fetch + updateStatus
- [ ] FetchMatchesUseCase delegates to repository protocol
- [ ] UpdateMatchStatusUseCase delegates to repository protocol
- [ ] ZERO imports of Foundation frameworks beyond what's needed (URL requires Foundation)
- [ ] No imports of SwiftUI, CoreData, Combine, or Network
- [ ] Code compiles with zero errors

---

## Rules

- This is the innermost layer — it must remain pure
- No networking, no persistence, no UI
- Only Foundation imports (for URL type)
- Models are value types (struct)
- Use cases are classes/structs with protocol dependencies injected via init

---

## Prompt for Chat Window

```
Implement the Domain Layer for the MatchCard feature in MatchMate.

Read these files for context:
- Docs/ARCHITECTURE.md
- Docs/MODULE_BOUNDARIES.md
- .kiro/context/features/match-card-domain/feature-context.md

Build all files listed in the feature-context scope section. This is the pure domain layer — NO imports of SwiftUI, CoreData, Combine, UIKit. Only Foundation (for URL). Models are structs. Use cases depend on protocol-defined repository. Follow Clean Architecture strictly.
```
