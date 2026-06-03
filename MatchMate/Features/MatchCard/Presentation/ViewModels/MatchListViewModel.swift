//
//  MatchListViewModel.swift
//  MatchMate
//
//  Presentation Layer — ViewModel
//

import Combine
import Foundation

/// Drives the match list screen.
///
/// Owns the screen `ViewState`, observes connectivity, and coordinates
/// accept/decline actions with optimistic UI updates that fall back on failure.
@MainActor
final class MatchListViewModel: ObservableObject {
    // MARK: - Published State

    @Published private(set) var state: ViewState<[MatchProfile]> = .idle
    @Published private(set) var isOnline: Bool = true

    // MARK: - Dependencies

    private let fetchMatchesUseCase: FetchMatchesUseCase
    private let updateMatchStatusUseCase: UpdateMatchStatusUseCase
    private let networkMonitor: NetworkMonitorProtocol

    // MARK: - Private State

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(
        fetchMatchesUseCase: FetchMatchesUseCase,
        updateMatchStatusUseCase: UpdateMatchStatusUseCase,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.fetchMatchesUseCase = fetchMatchesUseCase
        self.updateMatchStatusUseCase = updateMatchStatusUseCase
        self.networkMonitor = networkMonitor

        observeConnectivity()
    }

    // MARK: - Connectivity

    private func observeConnectivity() {
        isOnline = networkMonitor.isConnected
        networkMonitor.start()

        networkMonitor.isConnectedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] connected in
                self?.isOnline = connected
            }
            .store(in: &cancellables)
    }

    // MARK: - Loading

    /// Loads the match profiles and publishes the resulting state.
    func fetchMatches() async {
        // Avoid clobbering existing content with a full-screen spinner during refresh.
        if state.value == nil {
            state = .loading
        }

        do {
            let profiles = try await fetchMatchesUseCase.execute()
            state = .loaded(profiles)
        } catch {
            // Keep showing cached content if we already have some; otherwise surface the error.
            if state.value == nil {
                state = .error(Self.message(for: error))
            }
        }
    }

    // MARK: - Actions

    /// Accepts a profile, updating the UI optimistically before persisting.
    func accept(profile: MatchProfile) {
        updateStatus(of: profile, to: .accepted)
    }

    /// Declines a profile, updating the UI optimistically before persisting.
    func decline(profile: MatchProfile) {
        updateStatus(of: profile, to: .declined)
    }

    private func updateStatus(of profile: MatchProfile, to status: MatchStatus) {
        guard var profiles = state.value,
              let index = profiles.firstIndex(where: { $0.id == profile.id })
        else { return }

        let previous = profiles[index]
        guard previous.status != status else { return }

        // Optimistic update.
        profiles[index] = previous.withStatus(status)
        state = .loaded(profiles)

        Task { [weak self] in
            guard let self else { return }
            do {
                try await updateMatchStatusUseCase.execute(
                    profileId: profile.id,
                    status: status
                )
            } catch {
                // Roll back the optimistic change on failure.
                revert(profileId: profile.id, to: previous)
            }
        }
    }

    private func revert(profileId: String, to previous: MatchProfile) {
        guard var profiles = state.value,
              let index = profiles.firstIndex(where: { $0.id == profileId })
        else { return }

        profiles[index] = previous
        state = .loaded(profiles)
    }

    // MARK: - Error Mapping

    private static func message(for error: Error) -> String {
        if let description = (error as? LocalizedError)?.errorDescription {
            return description
        }
        return "We couldn't load your matches. Please try again."
    }
}

// MARK: - MatchProfile Status Helper

private extension MatchProfile {
    /// Returns a copy of the profile with an updated status.
    func withStatus(_ newStatus: MatchStatus) -> MatchProfile {
        MatchProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            age: age,
            city: city,
            state: state,
            country: country,
            thumbnailURL: thumbnailURL,
            largeImageURL: largeImageURL,
            email: email,
            phone: phone,
            status: newStatus
        )
    }
}
