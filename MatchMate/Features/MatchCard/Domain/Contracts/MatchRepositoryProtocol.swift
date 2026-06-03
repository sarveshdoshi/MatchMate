//
//  MatchRepositoryProtocol.swift
//  MatchMate
//
//  Domain Layer — repository contract.
//  Defines the boundary the Data layer must implement.
//  No framework dependencies.
//

/// Contract for fetching match profiles and persisting status changes.
/// Implemented by the Data layer; consumed by the Domain use cases.
protocol MatchRepositoryProtocol {
    /// Returns the current list of match profiles.
    func fetchMatches() async throws -> [MatchProfile]

    /// Updates the status of a single profile.
    /// - Parameters:
    ///   - profileId: The identifier of the profile to update.
    ///   - status: The new status to apply.
    func updateStatus(for profileId: String, to status: MatchStatus) async throws
}
