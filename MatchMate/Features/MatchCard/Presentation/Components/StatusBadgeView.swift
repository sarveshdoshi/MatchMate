//
//  StatusBadgeView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// A capsule badge reflecting a decided match status (accepted / declined).
struct StatusBadgeView: View {
    let status: MatchStatus

    var body: some View {
        if let style = Style(status: status) {
            Label(style.title, systemImage: style.systemImage)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    Capsule().fill(style.color)
                )
                .accessibilityElement(children: .ignore)
                .accessibilityLabel(Text(style.title))
        }
    }
}

// MARK: - Style

private extension StatusBadgeView {
    struct Style {
        let title: String
        let systemImage: String
        let color: Color

        init?(status: MatchStatus) {
            switch status {
            case .accepted:
                title = "Member Accepted"
                systemImage = "checkmark.circle.fill"
                color = .green
            case .declined:
                title = "Member Declined"
                systemImage = "xmark.circle.fill"
                color = .orange
            case .none:
                return nil
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatusBadgeView(status: .accepted)
        StatusBadgeView(status: .declined)
    }
}
