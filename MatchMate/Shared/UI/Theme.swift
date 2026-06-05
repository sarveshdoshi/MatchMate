//
//  Theme.swift
//  MatchMate
//
//  Shared — UI
//

import SwiftUI

/// App-wide brand palette.
///
/// Centralises the colours used by reusable UI so screens stay visually
/// consistent and a rebrand touches a single file. Cross-cutting and
/// feature-agnostic, so it lives in `Shared/UI`.
enum Theme {
    // MARK: - Brand

    /// Primary teal used for positive actions, accents, and the accepted state.
    static let primary = Color(red: 0.07, green: 0.52, blue: 0.55)

    /// Softer teal tint for badges and pill backgrounds.
    static let primarySoft = Color(red: 0.07, green: 0.52, blue: 0.55).opacity(0.12)

    /// Coral/pink used for the decline / "maybe" affordances and declined state.
    static let accent = Color(red: 0.95, green: 0.39, blue: 0.45)

    /// Softer coral tint for badges and pill backgrounds.
    static let accentSoft = Color(red: 0.95, green: 0.39, blue: 0.45).opacity(0.12)

    // MARK: - Surfaces

    /// Card surface colour (adapts to light/dark).
    static let cardSurface = Color(.secondarySystemGroupedBackground)

    /// Hairline divider colour.
    static let divider = Color(.separator).opacity(0.5)

    // MARK: - Text

    /// Primary text colour for names and emphasis.
    static let textPrimary = Color(.label)

    /// Secondary text colour for supporting detail rows.
    static let textSecondary = Color(.secondaryLabel)
}
