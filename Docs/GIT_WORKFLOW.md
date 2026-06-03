# Git Workflow — MatchMate

## Branching Strategy

```
main (production-ready, protected)
 └── develop (integration branch)
      ├── feature/core-infrastructure
      ├── feature/match-card-domain
      ├── feature/match-card-data
      ├── feature/match-card-presentation
      ├── feature/navigation-di
      └── feature/testing
```

---

## Branch Roles

| Branch | Purpose | Merges Into |
|--------|---------|-------------|
| `main` | Stable, production-ready code | — |
| `develop` | Integration branch, all features merge here | `main` |
| `feature/*` | Individual feature work | `develop` |

---

## Feature Branch Workflow

1. Branch off `develop`: `git checkout -b feature/{name} develop`
2. Implement the feature (atomic commits)
3. Ensure code compiles with zero errors
4. Merge into `develop`: `git checkout develop && git merge feature/{name}`
5. Delete feature branch after merge

---

## Merge Order (respects dependencies)

### Wave 1 (no dependencies, parallel)
- `feature/core-infrastructure`
- `feature/match-card-domain`

### Wave 2 (depends on Wave 1)
- `feature/match-card-data`
- `feature/match-card-presentation`

### Wave 3 (depends on all above)
- `feature/navigation-di`
- `feature/testing`

### Final
- Merge `develop` → `main` when app is fully working

---

## Commit Message Convention

Format: `type(scope): description`

Examples:
```
feat(core): add NetworkService with async/await
feat(domain): add MatchProfile and MatchStatus models
feat(data): implement offline-first MatchRepository
feat(ui): implement MatchCardView with SDWebImage
fix(core): handle empty response from API
test(vm): add MatchListViewModel unit tests
docs: update README with setup instructions
chore: configure SwiftLint rules
```

Types: feat, fix, test, docs, chore, refactor

---

## Rules

- Never commit directly to `main`
- Never commit directly to `develop` (use feature branches)
- Keep commits atomic and focused
- Each commit should compile
- Write meaningful commit messages
- Delete feature branches after merge
