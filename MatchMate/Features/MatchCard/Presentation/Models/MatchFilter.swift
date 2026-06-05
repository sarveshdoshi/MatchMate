//
//  MatchFilter.swift
//  MatchMate
//
//  Presentation Layer — Model
//

import Foundation

/// The status filter applied to the match list.
///
/// A presentation-level concern (it scopes what the list shows, not how data is
/// fetched), so it lives in the Presentation layer and owns its own filtering.
enum MatchFilter: String, CaseIterable, Identifiable {
    case all
    case accepted
    case declined

    var id: String {
        rawValue
    }

    /// User-facing title shown in the filter menu.
    var title: String {
        switch self {
        case .all: "All"
        case .accepted: "Accepted"
        case .declined: "Declined"
        }
    }

    /// SF Symbol representing the filter in the menu.
    var systemImage: String {
        switch self {
        case .all: "person.2"
        case .accepted: "checkmark.circle"
        case .declined: "xmark.circle"
        }
    }

    /// Title for the empty state when this filter yields no results.
    var emptyTitle: String {
        switch self {
        case .all: "No Matches Yet"
        case .accepted: "No Accepted Matches"
        case .declined: "No Declined Matches"
        }
    }

    /// Supporting message for the empty state when this filter yields no results.
    var emptyMessage: String {
        switch self {
        case .all: "Pull down to refresh and find new matches."
        case .accepted: "Profiles you accept will show up here."
        case .declined: "Profiles you decline will show up here."
        }
    }

    /// Returns the subset of `profiles` matching this filter.
    func apply(to profiles: [MatchProfile]) -> [MatchProfile] {
        switch self {
        case .all:
            return profiles
        case .accepted:
            return profiles.filter { $0.status == .accepted }
        case .declined:
            return profiles.filter { $0.status == .declined }
        }
    }
}
