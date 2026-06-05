//
//  MatchCardRoute.swift
//  MatchMate
//
//  Navigation Layer — type-safe feature routes.
//

import Foundation

/// Type-safe routes for the Match Card feature.
///
/// The feature currently has a single screen — the match list — which acts as
/// the navigation root. Additional destinations (e.g. profile detail, chat) can
/// be added as cases here and rendered by `MatchCardCoordinator` without
/// touching existing call sites.
enum MatchCardRoute: Hashable {
    case list
}
