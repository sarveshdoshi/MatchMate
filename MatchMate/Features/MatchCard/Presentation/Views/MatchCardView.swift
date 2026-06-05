//
//  MatchCardView.swift
//  MatchMate
//
//  Presentation Layer — View
//

import SwiftUI

/// A single match profile card.
///
/// Lays out a circular avatar (with a decision badge) beside the profile's
/// compatibility pill, name, and detail rows. A footer hosts the Pass/Connect
/// actions while undecided, and a status bar once a decision is made.
struct MatchCardView: View {
    let profile: MatchProfile
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack(alignment: .center, spacing: 16) {
                ProfileAvatarView(url: profile.largeImageURL, status: profile.status)

                details
            }

            Divider()
                .overlay(Theme.divider)

            actionArea
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Theme.cardSurface)
        )
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(accessibilitySummary))
    }

    // MARK: - Subviews

    private var details: some View {
        VStack(alignment: .leading, spacing: 8) {
            CompatibilityBadgeView(level: profile.compatibility)

            Text(profile.fullName)
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                ProfileInfoRow(systemImage: "mappin.and.ellipse", text: profile.locationSummary)
                ProfileInfoRow(systemImage: "building.2.fill", text: profile.regionSummary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var actionArea: some View {
        switch profile.status {
        case .none:
            ActionButtonsView(onAccept: onAccept, onDecline: onDecline)
                .transition(.opacity.combined(with: .scale))
        case .accepted, .declined:
            StatusBadgeView(status: profile.status)
                .transition(.opacity.combined(with: .scale))
        }
    }

    // MARK: - Accessibility

    private var accessibilitySummary: String {
        var summary = "\(profile.fullName), \(profile.compatibility.title), \(profile.locationSummary)"
        switch profile.status {
        case .accepted:
            summary += ", Member Accepted"
        case .declined:
            summary += ", Member Declined"
        case .none:
            break
        }
        return summary
    }
}

// MARK: - MatchProfile Presentation Helpers

private extension MatchProfile {
    var fullName: String {
        "\(firstName) \(lastName)"
    }

    var locationSummary: String {
        "\(age), \(city)"
    }

    var regionSummary: String {
        [state, country]
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }

    /// Presentation-only compatibility rating.
    ///
    /// The API provides no compatibility signal, so this is derived
    /// deterministically from the stable profile id purely to populate the
    /// redesigned card. Replace with a real domain value when available.
    var compatibility: Compatibility {
        abs(id.hashValue).isMultiple(of: 2) ? .high : .maybe
    }
}

#Preview {
    let base = MatchProfile(
        id: "1",
        firstName: "Florence",
        lastName: "Gagné",
        age: 43,
        city: "Keswick",
        state: "Yukon",
        country: "Canada",
        thumbnailURL: nil,
        largeImageURL: nil,
        email: "florence@example.com",
        phone: "555-0100",
        status: .none
    )

    return ScrollView {
        VStack(spacing: 20) {
            MatchCardView(profile: base, onAccept: {}, onDecline: {})
            MatchCardView(
                profile: MatchProfile(
                    id: "2",
                    firstName: "Nilton",
                    lastName: "da Luz",
                    age: 44,
                    city: "Conselheiro Lafaiete",
                    state: "Alagoas",
                    country: "Brazil",
                    thumbnailURL: nil,
                    largeImageURL: nil,
                    email: "nilton@example.com",
                    phone: "555-0101",
                    status: .declined
                ),
                onAccept: {},
                onDecline: {}
            )
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
