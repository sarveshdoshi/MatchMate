//
//  StatusBadgeView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// A full-width footer bar reflecting a decided match status.
///
/// Accepted renders as a solid teal bar; declined as a soft coral bar. Both
/// carry a leading icon, a label, and a trailing chevron hinting at detail.
struct StatusBadgeView: View {
    let status: MatchStatus

    var body: some View {
        if let style = Style(status: status) {
            HStack(spacing: 12) {
                Image(systemName: style.systemImage)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(style.iconColor)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(style.iconBackground))

                Text(style.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(style.foreground)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(style.foreground.opacity(0.8))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(style.background)
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
        let foreground: Color
        let background: Color
        let iconColor: Color
        let iconBackground: Color

        init?(status: MatchStatus) {
            switch status {
            case .accepted:
                title = "Member Accepted"
                systemImage = "checkmark"
                foreground = .white
                background = Theme.primary
                iconColor = Theme.primary
                iconBackground = .white
            case .declined:
                title = "Member Declined"
                systemImage = "xmark"
                foreground = Theme.accent
                background = Theme.accentSoft
                iconColor = Theme.accent
                iconBackground = .white
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
    .padding()
}
