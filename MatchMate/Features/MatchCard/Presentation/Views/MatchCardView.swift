//
//  MatchCardView.swift
//  MatchMate
//
//  Presentation Layer — View
//

import SwiftUI

/// A single match profile card.
///
/// Shows the profile image, name, and location. When undecided it offers
/// Accept/Decline buttons; once decided it shows a status badge instead.
struct MatchCardView: View {
    let profile: MatchProfile
    let onAccept: () -> Void
    let onDecline: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ProfileImageView(url: profile.largeImageURL)

            VStack(spacing: 16) {
                details

                actionArea
            }
            .padding(20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(accessibilitySummary))
    }

    // MARK: - Subviews

    private var details: some View {
        VStack(spacing: 6) {
            Text(profile.fullName)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.teal)
                .multilineTextAlignment(.center)

            Text(profile.locationSummary)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
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
        var summary = "\(profile.fullName), \(profile.locationSummary)"
        switch profile.status {
        case .accepted:
            summary += ", accepted"
        case .declined:
            summary += ", declined"
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
        "\(age), \(city), \(state)"
    }
}

#Preview {
    let base = MatchProfile(
        id: "1",
        firstName: "Jordan",
        lastName: "Rivera",
        age: 28,
        city: "Austin",
        state: "Texas",
        country: "USA",
        thumbnailURL: nil,
        largeImageURL: nil,
        email: "jordan@example.com",
        phone: "555-0100",
        status: .none
    )

    return ScrollView {
        VStack(spacing: 20) {
            MatchCardView(profile: base, onAccept: {}, onDecline: {})
            MatchCardView(
                profile: MatchProfile(
                    id: "2",
                    firstName: "Sam",
                    lastName: "Lee",
                    age: 31,
                    city: "Seattle",
                    state: "Washington",
                    country: "USA",
                    thumbnailURL: nil,
                    largeImageURL: nil,
                    email: "sam@example.com",
                    phone: "555-0101",
                    status: .accepted
                ),
                onAccept: {},
                onDecline: {}
            )
        }
        .padding()
    }
}
