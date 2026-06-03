# Active Features Registry

| Feature ID | Feature Name | Current Stage | Status |
|------------|--------------|---------------|--------|
| core-infrastructure | Core Infrastructure | Ready | Not Started |
| match-card-domain | Match Card — Domain | Ready | Not Started |
| match-card-data | Match Card — Data | Ready | Not Started |
| match-card-presentation | Match Card — Presentation | Ready | Not Started |
| navigation-di | Navigation & DI | Ready | Not Started |
| testing | Unit Tests | Ready | Not Started |

---

## How to Add a New Feature

1. Create folder: `.kiro/context/features/{feature-id}/`
2. Copy templates into it:
   - `feature-context.md` (from `.kiro/templates/context/feature-context-template.md`)
   - `task-context.md` (from `.kiro/templates/context/task-context-template.md`)
   - `test-plan.md` (from `.kiro/templates/context/test-plan-template.md`)
   - `approvals.md` (from `.kiro/templates/context/approvals-template.md`)
3. Register the feature in this file (add a row above)
4. Add your PRD to `.kiro/templates/features` or reference it in the feature-context

---

## Status Values
- `Not Started` — folder scaffolded, awaiting PRD/requirement analysis
- `In Progress` — actively being worked on
- `Blocked` — waiting on dependency or clarification
- `Complete` — all stages passed, implementation merged
