# Approval Checklist (Global Template)

> **Note:** This is the reference template. Per-feature approval tracking lives in:
> `.kiro/context/features/{feature-id}/approvals.md`

---

## Requirement Approval

- [ ] Business goal clear
- [ ] Acceptance criteria clear
- [ ] Edge cases identified
- [ ] Open questions resolved

---

## Architecture Approval

- [ ] Follows MVVM
- [ ] Follows Clean Architecture
- [ ] Proper dependency direction
- [ ] No module boundary violations

---

## QA Approval

- [ ] Failure cases covered
- [ ] Edge cases covered
- [ ] Accessibility reviewed
- [ ] Localization reviewed

---

## TDD Approval

- [ ] Tests planned first
- [ ] Failure tests included
- [ ] Async tests included
- [ ] Regression tests included

---

## Implementation Approval

- [ ] Tests passing
- [ ] No lint violations (0 serious)
- [ ] No force unwraps
- [ ] No hardcoded strings
- [ ] Accessibility included
- [ ] Localization included
