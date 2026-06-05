//
//  ProfileAvatarView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// A circular profile avatar with a soft brand ring and an optional decision
/// badge anchored to the bottom-trailing edge.
///
/// The badge mirrors the card's decided state: a teal check once accepted, a
/// coral cross once declined, and nothing while the match is undecided.
struct ProfileAvatarView: View {
    let url: URL?
    let status: MatchStatus
    var diameter: CGFloat = 96

    var body: some View {
        ProfileImageView(url: url)
            .frame(width: diameter, height: diameter)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Theme.primary.opacity(0.25), lineWidth: 3)
            )
            .background(
                Circle()
                    .fill(Theme.primary.opacity(0.18))
                    .blur(radius: 6)
            )
            .overlay(alignment: .bottomTrailing) {
                if let badge = Badge(status: status) {
                    badgeView(badge)
                }
            }
    }

    // MARK: - Subviews

    private func badgeView(_ badge: Badge) -> some View {
        Image(systemName: badge.systemImage)
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 26, height: 26)
            .background(
                Circle()
                    .fill(badge.color)
                    .overlay(Circle().strokeBorder(Color(.systemBackground), lineWidth: 2))
            )
            .accessibilityHidden(true)
    }
}

// MARK: - Badge

private extension ProfileAvatarView {
    struct Badge {
        let systemImage: String
        let color: Color

        init?(status: MatchStatus) {
            switch status {
            case .accepted:
                systemImage = "checkmark"
                color = Theme.primary
            case .declined:
                systemImage = "xmark"
                color = Theme.accent
            case .none:
                return nil
            }
        }
    }
}

#Preview {
    HStack(spacing: 24) {
        ProfileAvatarView(url: nil, status: .none)
        ProfileAvatarView(url: nil, status: .accepted)
        ProfileAvatarView(url: nil, status: .declined)
    }
    .padding()
}
