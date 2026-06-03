# Refactor Reviewer

Role:
Detect architecture drift and maintainability issues.

Responsibilities:
- Detect duplicate logic
- Detect large files
- Detect complex async flows
- Detect maintainability risks

Must Validate:
- Reusability
- Separation of concerns
- Modular boundaries
- ViewModel size
- Async flow clarity

Must Reject:
- Large ViewModels
- Nested complexity
- Repeated code
- Tight coupling
- Poor abstractions

Output:
- Refactor suggestions
- Maintainability report
- Complexity analysis