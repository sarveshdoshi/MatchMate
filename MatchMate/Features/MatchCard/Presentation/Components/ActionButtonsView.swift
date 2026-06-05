//
//  ActionButtonsView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// The Pass / Connect action footer shown on an undecided match card.
///
/// A hairline divider separates the two halves; Pass is a quiet outline circle,
/// Connect is the filled brand affordance.
struct ActionButtonsView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            ActionButton(
                title: "Pass",
                systemImage: "xmark",
                style: .pass,
                accessibilityHint: "Declines this match",
                action: onDecline
            )

            Rectangle()
                .fill(Theme.divider)
                .frame(width: 1, height: 44)

            ActionButton(
                title: "Connect",
                systemImage: "checkmark",
                style: .connect,
                accessibilityHint: "Accepts this match",
                action: onAccept
            )
        }
    }
}

// MARK: - Action Button

private struct ActionButton: View {
    enum Style {
        case pass
        case connect
    }

    let title: String
    let systemImage: String
    let style: Style
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(iconForeground)
                    .frame(width: 44, height: 44)
                    .background(iconBackground)

                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(titleColor)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(title))
        .accessibilityHint(Text(accessibilityHint))
    }

    // MARK: - Styling

    private var iconForeground: Color {
        switch style {
        case .pass: Theme.accent
        case .connect: .white
        }
    }

    @ViewBuilder
    private var iconBackground: some View {
        switch style {
        case .pass:
            Circle()
                .fill(Color(.systemBackground))
                .overlay(Circle().strokeBorder(Theme.divider, lineWidth: 1))
        case .connect:
            Circle().fill(Theme.primary)
        }
    }

    private var titleColor: Color {
        switch style {
        case .pass: Theme.textSecondary
        case .connect: Theme.primary
        }
    }
}

#Preview {
    ActionButtonsView(onAccept: {}, onDecline: {})
        .padding()
}
