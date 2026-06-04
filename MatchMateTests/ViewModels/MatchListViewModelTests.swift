//
//  MatchListViewModelTests.swift
//  MatchMateTests
//
//  Verifies state transitions and accept/decline behaviour of MatchListViewModel.
//  Uses a mock repository (behind real use cases) and a mock network monitor.
//

import XCTest
@testable import MatchMate

@MainActor
final class MatchListViewModelTests: XCTestCase {
    private var repository: MockMatchRepository!
    private var monitor: MockNetworkMonitor!

    override func setUp() {
        super.setUp()
        repository = MockMatchRepository()
        monitor = MockNetworkMonitor(isConnected: true)
    }

    override func tearDown() {
        repository = nil
        monitor = nil
        super.tearDown()
    }

    private func makeSUT() -> MatchListViewModel {
        MatchListViewModel(
            fetchMatchesUseCase: FetchMatchesUseCase(repository: repository),
            updateMatchStatusUseCase: UpdateMatchStatusUseCase(repository: repository),
            networkMonitor: monitor
        )
    }

    // MARK: - Initial State

    func test_initialState_shouldBeIdle() {
        let sut = makeSUT()

        XCTAssertEqual(sut.state, .idle)
    }

    func test_init_shouldStartNetworkMonitor() {
        let sut = makeSUT()

        XCTAssertEqual(monitor.startCallCount, 1)
        XCTAssertTrue(sut.isOnline)
    }

    // MARK: - Fetch

    func test_fetchMatches_whenOnline_shouldSetStateToLoaded() async {
        let profiles = [makeProfile(id: "a"), makeProfile(id: "b")]
        repository.fetchResult = .success(profiles)
        let sut = makeSUT()

        await sut.fetchMatches()

        XCTAssertEqual(sut.state, .loaded(profiles))
        XCTAssertEqual(repository.fetchMatchesCallCount, 1)
    }

    func test_fetchMatches_whenOffline_shouldReturnCachedProfiles() async {
        // Offline path is decided by the repository; the VM simply renders results.
        monitor.isConnected = false
        let cached = [makeProfile(id: "cached", status: .accepted)]
        repository.fetchResult = .success(cached)
        let sut = makeSUT()

        await sut.fetchMatches()

        XCTAssertEqual(sut.state, .loaded(cached))
    }

    func test_fetchMatches_whenError_shouldSetStateToError() async {
        repository.fetchResult = .failure(NetworkError.serverError(500))
        let sut = makeSUT()

        await sut.fetchMatches()

        XCTAssertNotNil(sut.state.errorMessage)
        XCTAssertEqual(
            sut.state.errorMessage,
            NetworkError.serverError(500).errorDescription
        )
    }

    func test_fetchMatches_whenEmpty_shouldSetStateToLoadedEmpty() async {
        repository.fetchResult = .success([])
        let sut = makeSUT()

        await sut.fetchMatches()

        XCTAssertEqual(sut.state, .loaded([]))
    }

    func test_fetchMatches_whenErrorButCachedContentExists_shouldKeepLoaded() async {
        // First load succeeds, then a refresh fails: cached content must remain.
        let cached = [makeProfile(id: "a")]
        repository.fetchResult = .success(cached)
        let sut = makeSUT()
        await sut.fetchMatches()

        repository.fetchResult = .failure(NetworkError.noInternet)
        await sut.fetchMatches()

        XCTAssertEqual(sut.state, .loaded(cached))
        XCTAssertNil(sut.state.errorMessage)
    }

    // MARK: - Accept / Decline

    func test_acceptMatch_shouldUpdateProfileStatusToAccepted() async {
        let profile = makeProfile(id: "a", status: .none)
        repository.fetchResult = .success([profile])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.accept(profile: profile)

        // Optimistic update is synchronous.
        XCTAssertEqual(sut.state.value?.first?.status, .accepted)
    }

    func test_declineMatch_shouldUpdateProfileStatusToDeclined() async {
        let profile = makeProfile(id: "a", status: .none)
        repository.fetchResult = .success([profile])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.decline(profile: profile)

        XCTAssertEqual(sut.state.value?.first?.status, .declined)
    }

    func test_acceptMatch_shouldUpdateOnlyTargetedProfile() async {
        let first = makeProfile(id: "a", status: .none)
        let second = makeProfile(id: "b", status: .none)
        repository.fetchResult = .success([first, second])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.accept(profile: second)

        XCTAssertEqual(sut.state.value?.first(where: { $0.id == "a" })?.status, MatchStatus.none)
        XCTAssertEqual(sut.state.value?.first(where: { $0.id == "b" })?.status, .accepted)
    }

    func test_acceptMatch_shouldCallUpdateUseCase() async {
        let profile = makeProfile(id: "a", status: .none)
        repository.fetchResult = .success([profile])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.accept(profile: profile)

        await waitUntil { self.repository.updateStatusCallCount == 1 }
        XCTAssertEqual(repository.updateStatusCallCount, 1)
        XCTAssertEqual(repository.lastUpdatedProfileId, "a")
        XCTAssertEqual(repository.lastUpdatedStatus, .accepted)
    }

    func test_declineMatch_shouldCallUpdateUseCase() async {
        let profile = makeProfile(id: "a", status: .none)
        repository.fetchResult = .success([profile])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.decline(profile: profile)

        await waitUntil { self.repository.updateStatusCallCount == 1 }
        XCTAssertEqual(repository.updateStatusCallCount, 1)
        XCTAssertEqual(repository.lastUpdatedProfileId, "a")
        XCTAssertEqual(repository.lastUpdatedStatus, .declined)
    }

    func test_acceptMatch_whenAlreadyAccepted_shouldNotCallUseCase() async {
        let profile = makeProfile(id: "a", status: .accepted)
        repository.fetchResult = .success([profile])
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.accept(profile: profile)

        // No state change → no persistence call. Give any stray task a chance.
        await waitUntil(timeout: 0.2) { self.repository.updateStatusCallCount > 0 }
        XCTAssertEqual(repository.updateStatusCallCount, 0)
    }

    func test_acceptMatch_whenPersistenceFails_shouldRollBackOptimisticUpdate() async {
        let profile = makeProfile(id: "a", status: .none)
        repository.fetchResult = .success([profile])
        repository.updateStatusResult = .failure(NetworkError.serverError(500))
        let sut = makeSUT()
        await sut.fetchMatches()

        sut.accept(profile: profile)

        // Wait for the failing persistence task to roll back to the previous status.
        await waitUntil { sut.state.value?.first?.status == MatchStatus.none }
        XCTAssertEqual(sut.state.value?.first?.status, MatchStatus.none)
    }

    // MARK: - Connectivity

    func test_connectivityChange_shouldUpdateIsOnline() async {
        monitor.isConnected = true
        let sut = makeSUT()
        XCTAssertTrue(sut.isOnline)

        monitor.send(false)

        await waitUntil { sut.isOnline == false }
        XCTAssertFalse(sut.isOnline)
    }
}
