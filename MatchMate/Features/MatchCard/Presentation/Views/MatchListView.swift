//
//  MatchListView.swift
//  MatchMate
//
//  Presentation Layer — View
//

import Combine
import SwiftUI

/// The match list screen.
///
/// Renders loading / error / empty / loaded states, an offline banner, and
/// pull-to-refresh. Pure layout + binding — all behaviour lives in the ViewModel.
struct MatchListView: View {
    @StateObject private var viewModel: MatchListViewModel

    init(viewModel: MatchListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.isOnline {
                offlineBanner
            }

            content
        }
        .navigationTitle("Profile Matches")
        .navigationBarTitleDisplayMode(.large)
        .background(Color(.systemGroupedBackground))
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                filterMenu
            }
        }
        .alert(item: $viewModel.actionAlert) { alert in
            Alert(
                title: Text("Action Failed"),
                message: Text(alert.message),
                dismissButton: .default(Text("OK"))
            )
        }
        .task {
            await viewModel.fetchMatches()
        }
    }

    // MARK: - Filter Menu

    private var filterMenu: some View {
        Menu {
            Picker("Filter matches", selection: $viewModel.filter) {
                ForEach(MatchFilter.allCases) { option in
                    Label(option.title, systemImage: option.systemImage)
                        .tag(option)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle\(viewModel.filter == .all ? "" : ".fill")")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.primary)
        }
        .accessibilityLabel(Text("Filter matches"))
        .accessibilityValue(Text(viewModel.filter.title))
    }

    // MARK: - Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("People who might be a great match for you")
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Footer

    private var footerNote: some View {
        HStack(spacing: 6) {
            Image(systemName: "lock.fill")
                .font(.system(size: 12))
            Text("Only you can see your matches and decisions.")
                .font(.system(size: 13))
        }
        .foregroundStyle(Theme.textSecondary)
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 16)
        .accessibilityElement(children: .combine)
    }

    // MARK: - Content

    @ViewBuilder
    private var content: some View {
        switch viewModel.filteredState {
        case .idle, .loading:
            LoadingView()
        case let .error(message):
            ErrorView(message: message) {
                Task { await viewModel.fetchMatches() }
            }
        case let .loaded(profiles):
            if profiles.isEmpty {
                refreshableEmptyState
            } else {
                matchList(profiles)
            }
        }
    }

    private func matchList(_ profiles: [MatchProfile]) -> some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                header

                ForEach(profiles) { profile in
                    MatchCardView(
                        profile: profile,
                        onAccept: { viewModel.accept(profile: profile) },
                        onDecline: { viewModel.decline(profile: profile) }
                    )
                    .animation(.easeInOut(duration: 0.3), value: profile.status)
                }

                footerNote
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .refreshable {
            await viewModel.fetchMatches()
        }
    }

    private var refreshableEmptyState: some View {
        ScrollView {
            EmptyStateView(
                title: viewModel.filter.emptyTitle,
                message: viewModel.filter.emptyMessage,
                systemImage: emptyStateIcon
            )
            .frame(minHeight: 400)
        }
        .refreshable {
            await viewModel.fetchMatches()
        }
    }

    /// Icon for the empty state: a filter glyph when a filter is hiding results,
    /// otherwise the default "no matches" glyph.
    private var emptyStateIcon: String {
        switch viewModel.filter {
        case .all:
            return "heart.slash"
        case .accepted, .declined:
            return viewModel.hasAnyProfiles ? viewModel.filter.systemImage : "heart.slash"
        }
    }

    // MARK: - Offline Banner

    private var offlineBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: "wifi.slash")
            Text("You're offline. Showing saved matches.")
                .font(.footnote.weight(.medium))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.gray)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("You are offline. Showing saved matches."))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        MatchListView(viewModel: PreviewFactory.makeViewModel())
    }
}

// MARK: - Preview Support

/// Builds a fully wired ViewModel backed by an in-memory mock repository for previews.
private enum PreviewFactory {
    static func makeViewModel() -> MatchListViewModel {
        let repository = MockMatchRepository()
        return MatchListViewModel(
            fetchMatchesUseCase: FetchMatchesUseCase(repository: repository),
            updateMatchStatusUseCase: UpdateMatchStatusUseCase(repository: repository),
            networkMonitor: MockNetworkMonitor()
        )
    }
}

/// In-memory repository for previews; conforms to the Domain contract.
private final class MockMatchRepository: MatchRepositoryProtocol {
    private var profiles: [MatchProfile] = [
        MatchProfile(
            id: "1",
            firstName: "Jordan",
            lastName: "Rivera",
            age: 28,
            city: "Austin",
            state: "Texas",
            country: "USA",
            thumbnailURL: nil,
            largeImageURL: nil,
            email: "jordan@example.com",
            phone: "555-0100",
            status: .none
        ),
        MatchProfile(
            id: "2",
            firstName: "Sam",
            lastName: "Lee",
            age: 31,
            city: "Seattle",
            state: "Washington",
            country: "USA",
            thumbnailURL: nil,
            largeImageURL: nil,
            email: "sam@example.com",
            phone: "555-0101",
            status: .accepted
        ),
    ]

    func fetchMatches() async throws -> [MatchProfile] {
        profiles
    }

    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        guard let index = profiles.firstIndex(where: { $0.id == profileId }) else { return }
        let existing = profiles[index]
        profiles[index] = MatchProfile(
            id: existing.id,
            firstName: existing.firstName,
            lastName: existing.lastName,
            age: existing.age,
            city: existing.city,
            state: existing.state,
            country: existing.country,
            thumbnailURL: existing.thumbnailURL,
            largeImageURL: existing.largeImageURL,
            email: existing.email,
            phone: existing.phone,
            status: status
        )
    }
}

/// Always-online network monitor for previews.
private final class MockNetworkMonitor: NetworkMonitorProtocol {
    var isConnected: Bool = true

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        Just(true).eraseToAnyPublisher()
    }

    func start() {}
    func stop() {}
}
