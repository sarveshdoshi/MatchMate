//
//  AppCoordinator.swift
//  MatchMate
//
//  App — top-level coordinator composing feature coordinators.
//

import SwiftUI

/// Top-level coordinator for the app.
///
/// Composes feature coordinators built from the root `DependencyContainer` and
/// provides the initial scene's root view. Adding a new feature means building
/// its coordinator here and exposing a new root — existing features are untouched.
///
/// Holds no observable state of its own; it is a pure composition root, so it is
/// a plain reference type rather than an `ObservableObject`.
final class AppCoordinator {
    private let container: DependencyContainer
    private let matchCardCoordinator: MatchCardCoordinator

    init(container: DependencyContainer) {
        self.container = container
        self.matchCardCoordinator = container.matchCardContainer.makeCoordinator()
    }

    /// The app's root view. Currently the Match Card feature is the entry point.
    func rootView() -> some View {
        matchCardCoordinator.start()
    }
}
