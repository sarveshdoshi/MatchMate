//
//  MatchCardCoordinator.swift
//  MatchMate
//
//  Navigation Layer — feature coordinator.
//

import Combine
import SwiftUI

/// Coordinator for the Match Card feature.
///
/// Owns the feature's `NavigationStack` and navigation path, and resolves
/// `MatchCardRoute` values into concrete destination views. Holds the
/// feature's root `MatchListViewModel` (built by `MatchCardContainer`) so the
/// navigation layer never reaches into the Data or Domain layers directly.
///
/// Today the feature has a single screen (the list). New screens are added by
/// extending `MatchCardRoute` and `destination(for:)` — no changes to callers.
final class MatchCardCoordinator: ObservableObject {
    /// Drives type-safe pushes onto the feature's navigation stack.
    @Published var path: [MatchCardRoute] = []

    private let viewModel: MatchListViewModel

    init(viewModel: MatchListViewModel) {
        self.viewModel = viewModel
    }

    /// The feature's root view, wrapped in its own `NavigationStack`.
    func start() -> some View {
        MatchCardCoordinatorView(coordinator: self)
    }

    /// Resolves a route into its destination view.
    @ViewBuilder
    func destination(for route: MatchCardRoute) -> some View {
        switch route {
        case .list:
            MatchListView(viewModel: viewModel)
        }
    }
}

// MARK: - Coordinator View

/// SwiftUI host that binds the coordinator's path to a `NavigationStack` and
/// renders the feature's root plus any pushed routes.
private struct MatchCardCoordinatorView: View {
    @ObservedObject var coordinator: MatchCardCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.destination(for: .list)
                .navigationDestination(for: MatchCardRoute.self) { route in
                    coordinator.destination(for: route)
                }
        }
    }
}
