//
//  MatchMateApp.swift
//  MatchMate
//
//  Created by Sarvesh Doshi on 03/06/26.
//

import SwiftUI

@main
struct MatchMateApp: App {
    /// App-level composition root. Owns the shared infrastructure and feature
    /// containers for the lifetime of the app. Created once with `@main`.
    private let appCoordinator = AppCoordinator(container: DependencyContainer())

    var body: some Scene {
        WindowGroup {
            appCoordinator.rootView()
        }
    }
}
