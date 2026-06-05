//
//  MatchRepositoryTests.swift
//  MatchMateTests
//
//  Verifies the offline-first orchestration in MatchRepository using
//  in-memory mock data sources and a configurable network monitor.
//

import XCTest
@testable import MatchMate

final class MatchRepositoryTests: XCTestCase {
    private var remote: MockRemoteDataSource!
    private var local: MockLocalDataSource!
    private var monitor: MockNetworkMonitor!
    private var sut: MatchRepository!

    override func setUp() {
        super.setUp()
        remote = MockRemoteDataSource()
        local = MockLocalDataSource()
        monitor = MockNetworkMonitor(isConnected: true)
        sut = MatchRepository(
            remoteDataSource: remote,
            localDataSource: local,
            networkMonitor: monitor
        )
    }

    override func tearDown() {
        remote = nil
        local = nil
        monitor = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Online Fetch

    func test_fetchMatches_whenOnline_shouldReturnRemoteProfiles() async throws {
        monitor.isConnected = true
        remote.configureSuccess([
            makeUserDTO(uuid: "a", first: "Ada"),
            makeUserDTO(uuid: "b", first: "Grace")
        ])

        let result = try await sut.fetchMatches()

        XCTAssertEqual(result.map(\.id), ["a", "b"])
        XCTAssertEqual(remote.fetchUsersCallCount, 1)
    }

    func test_fetchMatches_whenOnline_shouldCacheToLocal() async throws {
        monitor.isConnected = true
        remote.configureSuccess([makeUserDTO(uuid: "a", first: "Ada")])

        _ = try await sut.fetchMatches()

        XCTAssertEqual(local.saveCallCount, 1)
        XCTAssertEqual(local.lastSavedProfiles.map(\.id), ["a"])
        XCTAssertEqual(local.storage.map(\.id), ["a"])
    }

    func test_fetchMatches_whenOnline_shouldReturnMergedLocalState() async throws {
        // Local already holds an accepted decision for "a"; a refresh must keep it.
        local = MockLocalDataSource(initial: [makeProfile(id: "a", status: .accepted)])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)
        monitor.isConnected = true
        remote.configureSuccess([makeUserDTO(uuid: "a", first: "Ada")])

        let result = try await sut.fetchMatches()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.status, .accepted)
    }

    func test_fetchMatches_preservesExistingStatusOnRefresh() async throws {
        local = MockLocalDataSource(initial: [makeProfile(id: "a", status: .declined)])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)
        monitor.isConnected = true
        // Remote returns the same id with default .none status.
        remote.configureSuccess([makeUserDTO(uuid: "a", first: "Ada")])

        let result = try await sut.fetchMatches()

        XCTAssertEqual(result.first?.status, .declined)
    }

    // MARK: - Offline Fetch

    func test_fetchMatches_whenOffline_shouldReturnLocalCache() async throws {
        monitor.isConnected = false
        local = MockLocalDataSource(initial: [
            makeProfile(id: "x", status: .accepted),
            makeProfile(id: "y", status: .none)
        ])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)

        let result = try await sut.fetchMatches()

        XCTAssertEqual(result.map(\.id), ["x", "y"])
        XCTAssertEqual(remote.fetchUsersCallCount, 0, "Should not hit the network while offline")
        XCTAssertEqual(local.saveCallCount, 0)
    }

    // MARK: - Fallback

    func test_fetchMatches_whenOnlineFetchFails_shouldFallbackToLocal() async throws {
        monitor.isConnected = true
        local = MockLocalDataSource(initial: [makeProfile(id: "cached", status: .accepted)])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)
        remote.configureFailure(NetworkError.serverError(500))

        let result = try await sut.fetchMatches()

        XCTAssertEqual(result.map(\.id), ["cached"])
        XCTAssertEqual(result.first?.status, .accepted)
    }

    // MARK: - Empty Response

    func test_fetchMatches_whenEmptyAPIResponse_shouldReturnEmptyArray() async throws {
        monitor.isConnected = true
        remote.configureSuccess([])

        let result = try await sut.fetchMatches()

        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Update Status

    func test_updateStatus_shouldPersistToLocal() async throws {
        local = MockLocalDataSource(initial: [makeProfile(id: "a", status: .none)])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)

        try await sut.updateStatus(for: "a", to: .accepted)

        XCTAssertEqual(local.updateStatusCallCount, 1)
        XCTAssertEqual(local.lastUpdatedProfileId, "a")
        XCTAssertEqual(local.lastUpdatedStatus, .accepted)
        XCTAssertEqual(local.storage.first?.status, .accepted)
    }

    func test_updateStatus_shouldWriteRegardlessOfConnectivity() async throws {
        // Accept/decline must work offline.
        monitor.isConnected = false
        local = MockLocalDataSource(initial: [makeProfile(id: "a", status: .none)])
        sut = MatchRepository(remoteDataSource: remote, localDataSource: local, networkMonitor: monitor)

        try await sut.updateStatus(for: "a", to: .declined)

        XCTAssertEqual(local.storage.first?.status, .declined)
    }

    func test_updateStatus_whenLocalThrows_shouldPropagateError() async {
        local.throwsWhenUpdatingMissingProfile = true

        do {
            try await sut.updateStatus(for: "missing", to: .accepted)
            XCTFail("Expected updateStatus to throw")
        } catch {
            XCTAssertEqual(error as? TestError, .profileNotFound)
        }
    }
}
