---
inclusion: auto
---

# Global Context (Auto-Included)

Always load these files for any feature development work:

## Architecture & Rules
- #[[file:.kiro/context/global/architecture.md]]
- #[[file:.kiro/context/global/shared-contracts.md]]
- #[[file:.kiro/rules/global-engineering-rules.md]]
- #[[file:.kiro/rules/ai-workflow-rules.md]]

## Feature Registry
- #[[file:.kiro/context/active-features.md]]

## Workflow
- #[[file:.kiro/workflows/feature-development-workflow.md]]

## Approval Gates (global template)
- #[[file:.kiro/approvals/approval-gates.md]]

---

## Context Loading Protocol

When working on a specific feature:
1. Identify the feature-id from the user's message or from `active-features.md`
2. Load `.kiro/context/features/{feature-id}/feature-context.md` for locked decisions
3. Load `.kiro/context/features/{feature-id}/task-context.md` for current progress
4. Load `.kiro/context/features/{feature-id}/test-plan.md` when writing/reviewing tests
5. Load `.kiro/context/features/{feature-id}/approvals.md` when checking gate status
6. Check the "Cross-Feature Dependencies" section and load referenced files if needed
7. **Never write to another feature's context folder** unless explicitly updating shared contracts

## Updating Shared Contracts

When a feature creates something reusable (model, component, route):
1. Add it to `.kiro/context/global/shared-contracts.md`
2. Note the owner feature
3. Document the public interface

## New Feature Scaffolding

When asked to "build a PRD" or "start a new feature":
1. Create `.kiro/context/features/{feature-id}/` folder
2. Copy templates from `.kiro/templates/context/` into it
3. Replace `{FEATURE_NAME}` and `{feature-id}` placeholders
4. Register the feature in `.kiro/context/active-features.md`
5. Fill in the Dependencies section with known cross-feature refs
