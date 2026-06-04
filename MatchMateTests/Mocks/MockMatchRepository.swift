//
//  MockMatchRepository.swift
//  MatchMateTests
//
//  Protocol-based mock for MatchRepositoryProtocol.
//

import Foundation
@testable import MatchMate

/// Configurable mock conforming to `MatchRepositoryProtocol`.
///
/// Drives ViewModel/use-case tests without touching the data layer. Configure
/// `fetchResult` / `updateStatusResult` and inspect the recorded call state.
final class MockMatchRepository: MatchRepositoryProtocol {
    // MARK: - Configurable Behaviour

    var fetchResult: Result<[MatchProfile], Error> = .success([])
    var updateStatusResult: Result<Void, Error> = .success(())

    // MARK: - Recorded State

    private(set) var fetchMatchesCallCount = 0
    private(set) var updateStatusCallCount = 0
    private(set) var lastUpdatedProfileId: String?
    private(set) var lastUpdatedStatus: MatchStatus?

    // MARK: - MatchRepositoryProtocol

    func fetchMatches() async throws -> [MatchProfile] {
        fetchMatchesCallCount += 1
        return try fetchResult.get()
    }

    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        updateStatusCallCount += 1
        lastUpdatedProfileId = profileId
        lastUpdatedStatus = status
        try updateStatusResult.get()
    }
}
