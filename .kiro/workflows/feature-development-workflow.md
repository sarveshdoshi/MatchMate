# Autonomous Feature Development Workflow

## Objective

Fully automate AI-driven feature development using:
- requirement analysis
- clarification loops
- architecture validation
- QA review
- TDD planning
- approval gates
- incremental implementation

---

## Context Loading (Before Any Stage)

Every stage must begin by loading the correct feature context:

1. Identify the **feature-id** from the user's message or `active-features.md`
2. Load: `.kiro/context/features/{feature-id}/feature-context.md`
3. Load: `.kiro/context/features/{feature-id}/task-context.md`
4. Load: `.kiro/context/global/architecture.md`
5. Load: `.kiro/context/global/shared-contracts.md`
6. Check "Cross-Feature Dependencies" and load referenced files if needed
7. **All writes go to the active feature's folder only**

### After Each Stage Completes:
- Update `task-context.md` with new stage status
- Update `approvals.md` if a gate was passed
- Update `shared-contracts.md` if new shared items were created
- Update `active-features.md` if status changed

---

## New Feature Scaffolding

When starting a new feature (e.g., "build a PRD for X"):
1. Create `.kiro/context/features/{feature-id}/` with files from templates:
   - `feature-context.md`
   - `task-context.md`
   - `test-plan.md`
   - `approvals.md`
2. Register in `.kiro/context/active-features.md`
3. Fill in Dependencies section with known cross-feature refs

---

# Workflow Stages

## Stage 1 — Requirement Analysis

Agent:
- Requirement Analyst

Responsibilities:
- Read PRD
- Analyze requirements
- Detect ambiguities
- Detect risks
- Detect missing edge cases

Output:
- requirement summary
- clarification questions
- confidence score

If ambiguity exists:
→ move to Clarification Loop

---

## Stage 2 — Clarification Loop

Agent:
- Clarification Engine

Responsibilities:
- Ask clarification questions
- Prevent assumptions
- Validate business rules

Loop:
- continue until ambiguity resolved

Exit Criteria:
- no open questions
- confidence score acceptable

---

## Stage 3 — Architecture Review

Agent:
- Solution Architect

Responsibilities:
- Validate scalability
- Validate module boundaries
- Validate navigation
- Validate dependency direction

Reject If:
- architecture violations exist
- scalability concerns exist

---

## Stage 4 — QA Review

Agent:
- QA Lead

Responsibilities:
- Identify edge cases
- Identify failure scenarios
- Identify regression risks
- Validate accessibility risks

Reject If:
- missing failure coverage
- missing edge-case coverage

---

## Stage 5 — TDD Planning

Agent:
- TDD Specialist

Responsibilities:
- Generate failing test plan
- Generate validation tests
- Generate async tests
- Generate edge-case tests

Reject If:
- incomplete test coverage

---

## Stage 6 — Approval Gate

Agent:
- Approval Orchestrator

Responsibilities:
- Validate all previous stages

Reject If:
- ambiguity exists
- tests incomplete
- architecture issues exist

Only after approval:
→ implementation allowed

---

## Stage 7 — Atomic Task Generation

Agent:
- Engineering Manager

Responsibilities:
- Generate independent tasks
- Optimize execution order
- Ensure revertability

Rules:
- one responsibility per task
- independently testable
- independently reviewable

---

## Stage 8 — Incremental Implementation

Agent:
- Senior iOS Developer

Responsibilities:
- Generate failing tests first
- Generate minimal implementation
- Validate passing tests

Rules:
- incremental only
- no large implementations
- architecture compliance mandatory

---

## Stage 9 — Refactor Review

Agent:
- Refactor Reviewer

Responsibilities:
- Detect duplication
- Detect architecture drift
- Improve maintainability

---

## Stage 10 — Regression Validation

Agent:
- QA Lead

Responsibilities:
- Validate existing flows
- Validate failure handling
- Validate edge cases

---

## Stage 11 — Final Approval

Agent:
- Approval Orchestrator

Responsibilities:
- Final implementation validation

Output:
- APPROVED
or
- REJECTED