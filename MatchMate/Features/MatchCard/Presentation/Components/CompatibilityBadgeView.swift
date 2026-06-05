//
//  CompatibilityBadgeView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// A small pill indicating how compatible a match is.
///
/// - Important: The MatchMate backend (randomuser.me) does not expose a
///   compatibility signal. This is a **presentation-only placeholder** so the
///   redesigned card matches the approved visual. Swap `Compatibility`'s source
///   for a real score (e.g. from the domain model) when the data exists — the
///   view itself does not need to change.
struct CompatibilityBadgeView: View {
    let level: Compatibility

    var body: some View {
        Label {
            Text(level.title)
                .font(.system(size: 13, weight: .semibold))
        } icon: {
            Image(systemName: level.systemImage)
                .font(.system(size: 12, weight: .bold))
        }
        .foregroundStyle(level.tint)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Capsule().fill(level.background))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(level.title))
    }
}

// MARK: - Compatibility

/// Presentation-level compatibility rating shown on the card.
enum Compatibility {
    case high
    case maybe

    var title: String {
        switch self {
        case .high: "Highly Compatible"
        case .maybe: "Maybe Compatible"
        }
    }

    var systemImage: String {
        switch self {
        case .high: "sparkles"
        case .maybe: "person.2.fill"
        }
    }

    var tint: Color {
        switch self {
        case .high: Theme.primary
        case .maybe: Theme.accent
        }
    }

    var background: Color {
        switch self {
        case .high: Theme.primarySoft
        case .maybe: Theme.accentSoft
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        CompatibilityBadgeView(level: .high)
        CompatibilityBadgeView(level: .maybe)
    }
    .padding()
}
