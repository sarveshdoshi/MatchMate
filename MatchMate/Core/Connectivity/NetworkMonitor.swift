//
//  NetworkMonitor.swift
//  MatchMate
//
//  Core Infrastructure — Connectivity
//

import Combine
import Foundation
import Network

/// `NWPathMonitor` wrapper that publishes connectivity changes via Combine.
final class NetworkMonitor: NetworkMonitorProtocol {
    @Published private var connected: Bool
    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    var isConnected: Bool { connected }

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $connected
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    init(queue: DispatchQueue = DispatchQueue(label: "com.matchmate.networkmonitor")) {
        self.monitor = NWPathMonitor()
        self.queue = queue
        // NWPathMonitor's `currentPath` is unreliable before `start()` delivers its
        // first update (it reports unsatisfied at cold launch). Assume connectivity
        // optimistically so the initial fetch attempts the network; the repository
        // safely falls back to the cache if that attempt fails. The first real
        // path update corrects this value moments later.
        self.connected = true
    }

    func start() {
        monitor.pathUpdateHandler = { [weak self] path in
            let isSatisfied = path.status == .satisfied
            DispatchQueue.main.async {
                self?.connected = isSatisfied
            }
        }
        monitor.start(queue: queue)
    }

    func stop() {
        monitor.cancel()
    }

    deinit {
        monitor.cancel()
    }
}
