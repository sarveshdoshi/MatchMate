//
//  ActionButtonsView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// Accept / Decline circular action buttons shown on an undecided match card.
struct ActionButtonsView: View {
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        HStack(spacing: 48) {
            CircularActionButton(
                systemImage: "xmark",
                tint: .orange,
                accessibilityLabel: "Decline",
                accessibilityHint: "Declines this match",
                action: onDecline
            )

            CircularActionButton(
                systemImage: "checkmark",
                tint: .green,
                accessibilityLabel: "Accept",
                accessibilityHint: "Accepts this match",
                action: onAccept
            )
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Circular Action Button

private struct CircularActionButton: View {
    let systemImage: String
    let tint: Color
    let accessibilityLabel: String
    let accessibilityHint: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(tint)
                .frame(width: 56, height: 56)
                .background(
                    Circle()
                        .fill(tint.opacity(0.12))
                )
                .overlay(
                    Circle()
                        .strokeBorder(tint.opacity(0.4), lineWidth: 1.5)
                )
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .accessibilityLabel(Text(accessibilityLabel))
        .accessibilityHint(Text(accessibilityHint))
    }
}

#Preview {
    ActionButtonsView(onAccept: {}, onDecline: {})
}
