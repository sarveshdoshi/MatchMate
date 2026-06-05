//
//  MatchCardContainer.swift
//  MatchMate
//
//  DI — Match Card feature container.
//

import Foundation

/// Composition root for the Match Card feature.
///
/// Receives the app-wide infrastructure it needs (Core Data, networking,
/// connectivity) as protocols and assembles the full dependency graph:
///
/// ```
/// RemoteDataSource ─┐
/// LocalDataSource  ─┼─▶ MatchRepository ─▶ UseCases ─▶ MatchListViewModel
/// NetworkMonitor   ─┘
/// ```
///
/// All wiring is constructor injection — no singletons, no service locators.
final class MatchCardContainer {
    private let coreDataStack: CoreDataStackProtocol
    private let networkService: NetworkServiceProtocol
    private let networkMonitor: NetworkMonitorProtocol

    init(
        coreDataStack: CoreDataStackProtocol,
        networkService: NetworkServiceProtocol,
        networkMonitor: NetworkMonitorProtocol
    ) {
        self.coreDataStack = coreDataStack
        self.networkService = networkService
        self.networkMonitor = networkMonitor
    }

    // MARK: - Factories

    /// Builds the feature coordinator with a fully wired root ViewModel.
    func makeCoordinator() -> MatchCardCoordinator {
        MatchCardCoordinator(viewModel: makeViewModel())
    }

    /// Assembles the Match Card dependency graph and returns the screen ViewModel.
    func makeViewModel() -> MatchListViewModel {
        let remoteDataSource = MatchRemoteDataSource(networkService: networkService)
        let localDataSource = MatchLocalDataSource(coreDataStack: coreDataStack)
        let repository = MatchRepository(
            remoteDataSource: remoteDataSource,
            localDataSource: localDataSource,
            networkMonitor: networkMonitor
        )
        let fetchUseCase = FetchMatchesUseCase(repository: repository)
        let updateUseCase = UpdateMatchStatusUseCase(repository: repository)
        return MatchListViewModel(
            fetchMatchesUseCase: fetchUseCase,
            updateMatchStatusUseCase: updateUseCase,
            networkMonitor: networkMonitor
        )
    }
}
