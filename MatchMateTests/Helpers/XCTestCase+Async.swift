//
//  XCTestCase+Async.swift
//  MatchMateTests
//
//  Small async helpers for awaiting fire-and-forget work deterministically.
//

import XCTest

extension XCTestCase {
    /// Polls `condition` until it becomes true or the timeout elapses.
    ///
    /// Used to await fire-and-forget `Task` work (e.g. the ViewModel's optimistic
    /// status persistence) without relying on fixed sleeps. The mocks complete
    /// synchronously, so the condition is typically satisfied on the first yields.
    func waitUntil(
        timeout: TimeInterval = 2.0,
        pollInterval: UInt64 = 1_000_000, // 1ms
        _ condition: @escaping () -> Bool
    ) async {
        let deadline = Date().addingTimeInterval(timeout)
        while !condition(), Date() < deadline {
            try? await Task.sleep(nanoseconds: pollInterval)
        }
    }
}
