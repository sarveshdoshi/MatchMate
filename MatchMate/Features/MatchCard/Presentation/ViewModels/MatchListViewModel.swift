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

    /// The active status filter. `state` always holds the full set; the view
    /// renders `filteredState`, so changing this re-scopes the list instantly
    /// without re-fetching.
    @Published var filter: MatchFilter = .all

    /// A transient, user-facing message for a failed action (e.g. a decision
    /// that couldn't be saved and was rolled back). The view binds to this to
    /// present an alert; it clears once dismissed.
    @Published var actionAlert: ActionAlert?

    // MARK: - Derived State

    /// `state` with the active filter applied to its loaded profiles.
    ///
    /// Loading/error pass through unchanged; only the loaded payload is scoped.
    var filteredState: ViewState<[MatchProfile]> {
        guard case let .loaded(profiles) = state else { return state }
        return .loaded(filter.apply(to: profiles))
    }

    /// Whether any profiles are loaded, regardless of the active filter. Lets the
    /// view distinguish "nothing loaded yet" from "filter hid everything".
    var hasAnyProfiles: Bool {
        (state.value?.isEmpty == false)
    }

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
                guard let self else { return }
                // Detect an offline → online transition so we can refresh.
                let cameBackOnline = connected && !self.isOnline
                self.isOnline = connected

                if cameBackOnline {
                    // Connectivity restored (or established for the first time
                    // after launch, before NWPathMonitor's initial callback).
                    // Pull fresh data so the UI reflects reality in real time.
                    Task { await self.fetchMatches() }
                }
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
                // Roll back the optimistic change and tell the user it didn't stick.
                revert(profileId: profile.id, to: previous)
                actionAlert = ActionAlert(
                    message: Self.actionFailureMessage(for: status, error: error)
                )
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

    /// Builds the user-facing message shown when a decision fails to persist and
    /// the optimistic UI change has been rolled back.
    private static func actionFailureMessage(for status: MatchStatus, error: Error) -> String {
        let action: String
        switch status {
        case .accepted: action = "accept"
        case .declined: action = "decline"
        case .none: action = "update"
        }

        if let description = (error as? LocalizedError)?.errorDescription {
            return "Couldn't \(action) this match: \(description) Please try again."
        }
        return "Couldn't \(action) this match. Please try again."
    }
}

// MARK: - Action Alert

/// A lightweight, identifiable alert payload for transient action failures.
struct ActionAlert: Identifiable {
    let id = UUID()
    let message: String
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
