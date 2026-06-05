//
//  MockLocalDataSource.swift
//  MatchMateTests
//
//  In-memory mock for MatchLocalDataSourceProtocol.
//

import Foundation
@testable import MatchMate

/// In-memory implementation of `MatchLocalDataSourceProtocol`.
///
/// Mimics the real source's upsert-by-id behaviour, including preserving an
/// existing profile's accept/decline status when re-saving. Optional error
/// hooks let tests exercise failure paths.
final class MockLocalDataSource: MatchLocalDataSourceProtocol {
    /// Backing store keyed by profile id, ordered by insertion.
    private(set) var storage: [MatchProfile] = []

    // MARK: - Error Injection

    var fetchAllError: Error?
    var saveError: Error?
    var updateStatusError: Error?

    /// When true, `updateStatus` throws if the id is not present.
    var throwsWhenUpdatingMissingProfile = false

    // MARK: - Recorded State

    private(set) var fetchAllCallCount = 0
    private(set) var saveCallCount = 0
    private(set) var updateStatusCallCount = 0
    private(set) var lastSavedProfiles: [MatchProfile] = []
    private(set) var lastUpdatedProfileId: String?
    private(set) var lastUpdatedStatus: MatchStatus?

    init(initial: [MatchProfile] = []) {
        storage = initial
    }

    // MARK: - MatchLocalDataSourceProtocol

    func fetchAll() async throws -> [MatchProfile] {
        fetchAllCallCount += 1
        if let fetchAllError {
            throw fetchAllError
        }
        return storage
    }

    func save(profiles: [MatchProfile]) async throws {
        saveCallCount += 1
        lastSavedProfiles = profiles
        if let saveError {
            throw saveError
        }

        for profile in profiles {
            if let index = storage.firstIndex(where: { $0.id == profile.id }) {
                // Upsert: refresh fields but preserve the existing decision.
                let existingStatus = storage[index].status
                storage[index] = profile.with(status: existingStatus)
            } else {
                storage.append(profile)
            }
        }
    }

    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        updateStatusCallCount += 1
        lastUpdatedProfileId = profileId
        lastUpdatedStatus = status
        if let updateStatusError {
            throw updateStatusError
        }

        guard let index = storage.firstIndex(where: { $0.id == profileId }) else {
            if throwsWhenUpdatingMissingProfile {
                throw TestError.profileNotFound
            }
            return
        }
        storage[index] = storage[index].with(status: status)
    }
}
