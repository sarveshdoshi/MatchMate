---
inclusion: auto
---

# Feature Isolation Rules

## Parallel Development Safety

When multiple features are being developed in parallel tabs:

1. **Scope your work** — Only modify files within the active feature's boundary
2. **Never overwrite** another feature's context files
3. **Update shared-contracts.md** when creating cross-feature models/components
4. **Check active-features.md** before modifying shared code to avoid conflicts
5. **Cross-feature references** — Use `#[[file:...]]` syntax to load, never copy content between feature contexts

## Feature Boundary Rules

- Each feature owns its folder: `Features/{FeatureName}/`
- Shared code goes in: `Shared/Models/`, `Shared/UI/`, `Shared/Resources/`
- Core infrastructure goes in: `Core/`
- A feature may READ another feature's context for dependency info
- A feature must NOT MODIFY another feature's context without explicit instruction

## Context File Ownership

| File | Owner | Who Can Modify |
|------|-------|----------------|
| `features/{id}/feature-context.md` | Feature owner | Only that feature's workflow |
| `features/{id}/task-context.md` | Feature owner | Only that feature's workflow |
| `features/{id}/test-plan.md` | Feature owner | Only that feature's workflow |
| `features/{id}/approvals.md` | Feature owner | Only that feature's workflow |
| `global/shared-contracts.md` | All features | Any feature adding shared items |
| `global/architecture.md` | Project-wide | Only on architectural decisions |
| `active-features.md` | Project-wide | When adding/updating features |
