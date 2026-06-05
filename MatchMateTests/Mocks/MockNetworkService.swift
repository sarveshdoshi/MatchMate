//
//  MockNetworkService.swift
//  MatchMateTests
//
//  Protocol-based mock for NetworkServiceProtocol.
//

import Foundation
@testable import MatchMate

/// Configurable mock conforming to `NetworkServiceProtocol`.
///
/// Set `result` to control the decoded value or error returned by `request`.
/// Because the protocol is generic, the configured success value is cast to the
/// requested type; a mismatch surfaces as `NetworkError.decodingError`.
final class MockNetworkService: NetworkServiceProtocol {
    /// The outcome returned by `request`. Defaults to a decoding error so an
    /// unconfigured mock fails loudly rather than silently.
    var result: Result<Any, Error> = .failure(NetworkError.decodingError)

    private(set) var requestCallCount = 0
    private(set) var lastEndpoint: Endpoint?

    /// Convenience configuration for a successful response.
    func configureSuccess(_ value: Any) {
        result = .success(value)
    }

    /// Convenience configuration for a failure.
    func configureFailure(_ error: Error) {
        result = .failure(error)
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        requestCallCount += 1
        lastEndpoint = endpoint

        switch result {
        case let .success(value):
            guard let typed = value as? T else {
                throw NetworkError.decodingError
            }
            return typed
        case let .failure(error):
            throw error
        }
    }
}
