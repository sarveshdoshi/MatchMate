# Shared Contracts Registry

This file lists all shared models, components, and routes that cross feature boundaries.
Load this file in any feature tab to understand what's available globally.

---

## Shared Models (Shared/Models/)

| Model    | Owner Feature | Public Interface                          | File                        |
|----------|---------------|-------------------------------------------|-----------------------------|
| Country  | auth-login    | `.name`, `.dialCode`, `.isoCode`, `.flag` | Shared/Models/Country.swift |

---

## Shared UI Components (Shared/UI/)

| Component           | Description                              | File                              |
|---------------------|------------------------------------------|-----------------------------------|
| PrimaryButton       | Loader-morph CTA, successFeedback opt-in | Shared/UI/PrimaryButton.swift     |
| SearchableListSheet | Generic full-screen searchable sheet     | Shared/UI/SearchableListSheet.swift |

---

## Shared Resources (Shared/Resources/)

| Resource         | Description                        | File                              |
|------------------|------------------------------------|-----------------------------------|
| countryCode.json | Bundled country list (240 entries) | Shared/Resources/countryCode.json |

---

## Feature Navigation Routes (public entry points)

| Feature    | Route                          | Payload              |
|------------|--------------------------------|----------------------|
| auth-login | `AuthRoute.login`              | —                    |
| auth-login | `AuthRoute.verifyOTP`          | `MobileNumber`       |

---

## Cross-Feature Data Contracts

| Contract       | Owner Feature | Consumers          | Key Detail                                      |
|----------------|---------------|--------------------|-------------------------------------------------|
| MobileNumber   | auth-login    | otp-verification   | `.e164` is the only sanctioned API wire-format  |

---

## How to Add New Entries

When a feature creates something reusable:
1. Add it to the appropriate table above
2. Note the owner feature
3. Document the public interface or key invariant
