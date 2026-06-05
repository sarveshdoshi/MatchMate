//
//  MatchLocalDataSourceTests.swift
//  MatchMateTests
//
//  Exercises the real Core Data-backed local data source against an in-memory
//  store (no disk I/O). Verifies read/write, upsert-by-id, and status preservation.
//

import XCTest
@testable import MatchMate

final class MatchLocalDataSourceTests: XCTestCase {
    private var stack: CoreDataStack!
    private var sut: MatchLocalDataSource!

    override func setUp() {
        super.setUp()
        // Fresh in-memory store per test → full isolation, no on-disk side effects.
        stack = CoreDataStack(inMemory: true)
        sut = MatchLocalDataSource(coreDataStack: stack)
    }

    override func tearDown() {
        stack = nil
        sut = nil
        super.tearDown()
    }

    // MARK: - Read / Write

    func test_fetchAll_whenEmpty_shouldReturnEmpty() async throws {
        let result = try await sut.fetchAll()

        XCTAssertTrue(result.isEmpty)
    }

    func test_save_thenFetchAll_shouldReturnSavedProfiles() async throws {
        let profiles = [
            makeProfile(id: "a", firstName: "Ada"),
            makeProfile(id: "b", firstName: "Grace")
        ]

        try await sut.save(profiles: profiles)
        let result = try await sut.fetchAll()

        XCTAssertEqual(Set(result.map(\.id)), ["a", "b"])
    }

    func test_save_withEmptyArray_shouldRemainEmpty() async throws {
        try await sut.save(profiles: [])

        let result = try await sut.fetchAll()
        XCTAssertTrue(result.isEmpty)
    }

    // MARK: - Upsert

    func test_save_withExistingID_shouldUpsertNotDuplicate() async throws {
        try await sut.save(profiles: [makeProfile(id: "a", firstName: "Ada")])
        try await sut.save(profiles: [makeProfile(id: "a", firstName: "Adelle")])

        let result = try await sut.fetchAll()

        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.firstName, "Adelle")
    }

    func test_save_withExistingAcceptedProfile_shouldPreserveStatusOnRefresh() async throws {
        // Seed with no decision, then accept, then re-save (refresh) with .none.
        try await sut.save(profiles: [makeProfile(id: "a", status: .none)])
        try await sut.updateStatus(for: "a", to: .accepted)

        try await sut.save(profiles: [makeProfile(id: "a", firstName: "Refreshed", status: .none)])

        let result = try await sut.fetchAll()
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.status, .accepted, "Refresh must preserve the user's decision")
        XCTAssertEqual(result.first?.firstName, "Refreshed", "Other fields should still update")
    }

    // MARK: - Update Status

    func test_updateStatus_shouldPersistDeclinedStatus() async throws {
        try await sut.save(profiles: [makeProfile(id: "a", status: .none)])

        try await sut.updateStatus(for: "a", to: .declined)

        let result = try await sut.fetchAll()
        XCTAssertEqual(result.first?.status, .declined)
    }

    func test_updateStatus_whenProfileMissing_shouldNotThrowAndNotInsert() async throws {
        // Real source logs and returns for an unknown id (no-op), rather than throwing.
        try await sut.updateStatus(for: "ghost", to: .accepted)

        let result = try await sut.fetchAll()
        XCTAssertTrue(result.isEmpty)
    }
}
