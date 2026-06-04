//
//  MockNetworkMonitor.swift
//  MatchMateTests
//
//  Protocol-based mock for NetworkMonitorProtocol.
//

import Combine
import Foundation
@testable import MatchMate

/// Configurable mock conforming to `NetworkMonitorProtocol`.
///
/// `isConnected` is settable directly. Connectivity changes can be pushed to
/// observers via `send(_:)`, which also updates the current state.
final class MockNetworkMonitor: NetworkMonitorProtocol {
    private let subject: CurrentValueSubject<Bool, Never>

    private(set) var startCallCount = 0
    private(set) var stopCallCount = 0

    init(isConnected: Bool = true) {
        subject = CurrentValueSubject<Bool, Never>(isConnected)
    }

    var isConnected: Bool {
        get { subject.value }
        set { subject.send(newValue) }
    }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        subject.removeDuplicates().eraseToAnyPublisher()
    }

    /// Pushes a new connectivity state to observers and updates `isConnected`.
    func send(_ connected: Bool) {
        subject.send(connected)
    }

    func start() {
        startCallCount += 1
    }

    func stop() {
        stopCallCount += 1
    }
}
