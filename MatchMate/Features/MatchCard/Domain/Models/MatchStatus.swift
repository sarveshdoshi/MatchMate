//
//  MatchStatus.swift
//  MatchMate
//
//  Domain Layer — pure business model.
//  No framework dependencies.
//

/// Represents the user's decision on a given match profile.
enum MatchStatus: String, CaseIterable, Equatable {
    /// No decision has been made yet.
    case none
    /// The profile has been accepted.
    case accepted
    /// The profile has been declined.
    case declined
}
