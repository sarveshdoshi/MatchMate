//
//  DependencyContainer.swift
//  MatchMate
//
//  App — root composition root (single app-level container).
//

import Foundation

/// Root dependency container for the app.
///
/// Creates the shared Core infrastructure (Core Data, networking, connectivity)
/// exactly once and exposes it to per-feature containers. This is the only
/// app-level singleton-style object; it holds no business logic and simply wires
/// dependencies together via constructor injection.
///
/// Core services are declared `lazy` so they are created on first use and shared
/// across every feature container that depends on them.
final class DependencyContainer {
    // MARK: - Core Infrastructure

    let coreDataStack: CoreDataStackProtocol
    let networkService: NetworkServiceProtocol
    let networkMonitor: NetworkMonitorProtocol

    // MARK: - Feature Containers

    lazy var matchCardContainer = MatchCardContainer(
        coreDataStack: coreDataStack,
        networkService: networkService,
        networkMonitor: networkMonitor
    )

    // MARK: - Init

    /// Creates the container, allowing infrastructure to be substituted in tests.
    init(
        coreDataStack: CoreDataStackProtocol = CoreDataStack(),
        networkService: NetworkServiceProtocol = NetworkService(),
        networkMonitor: NetworkMonitorProtocol = NetworkMonitor()
    ) {
        self.coreDataStack = coreDataStack
        self.networkService = networkService
        self.networkMonitor = networkMonitor
    }
}
