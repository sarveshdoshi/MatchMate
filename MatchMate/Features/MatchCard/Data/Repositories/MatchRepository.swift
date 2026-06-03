//
//  MatchRepository.swift
//  MatchMate
//
//  Data Layer — orchestrates remote + local sources with offline-first logic.
//  Conforms to the Domain's MatchRepositoryProtocol.
//

import Foundation

/// Offline-first implementation of `MatchRepositoryProtocol`.
///
/// Coordinates the remote API and the local Core Data cache:
/// - **Online:** fetch from the API, map, upsert into the cache (preserving any
///   existing accept/decline status), then return the merged local state.
/// - **Offline:** return the cached profiles as-is.
/// - **Online but the fetch fails:** fall back to the cache so the UI still has data.
///
/// Status changes always write straight to the local cache so they work offline.
final class MatchRepository: MatchRepositoryProtocol {
    private let remoteDataSource: MatchRemoteDataSourceProtocol
    private let localDataSource: MatchLocalDataSourceProtocol
    private let networkMonitor: NetworkMonitorProtocol

    init(
        remoteDataSource: MatchRemoteDataSourceProtocol,
        localDataSource: MatchLocalDataSourceProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
        self.networkMonitor = networkMonitor
    }

    // MARK: - MatchRepositoryProtocol

    func fetchMatches() async throws -> [MatchProfile] {
        guard networkMonitor.isConnected else {
            // Pure offline: serve whatever is cached.
            return try await localDataSource.fetchAll()
        }

        do {
            let dtos = try await remoteDataSource.fetchUsers()
            let profiles = MatchProfileMapper.map(dtos)
            // Upsert: existing rows keep their accept/decline decision.
            try await localDataSource.save(profiles: profiles)
            // Return the merged local state as the single source of truth.
            return try await localDataSource.fetchAll()
        } catch {
            // Network/decoding failure: degrade gracefully to the cache.
            return try await localDataSource.fetchAll()
        }
    }

    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        // Always persist locally so accept/decline works offline.
        try await localDataSource.updateStatus(for: profileId, to: status)
    }
}
