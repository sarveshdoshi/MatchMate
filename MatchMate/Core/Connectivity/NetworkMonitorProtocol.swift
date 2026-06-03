//
//  NetworkMonitorProtocol.swift
//  MatchMate
//
//  Core Infrastructure — Connectivity
//

import Combine
import Foundation

/// Abstraction over connectivity monitoring so it can be mocked in tests.
protocol NetworkMonitorProtocol: AnyObject {
    /// The current connectivity state.
    var isConnected: Bool { get }

    /// A publisher that emits whenever the connectivity state changes.
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }

    /// Begins observing connectivity changes.
    func start()

    /// Stops observing connectivity changes.
    func stop()
}
