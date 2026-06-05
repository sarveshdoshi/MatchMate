//
//  NetworkServiceProtocol.swift
//  MatchMate
//
//  Core Infrastructure — Networking
//

import Foundation

/// Abstraction for performing network requests and decoding their responses.
///
/// Defined as a protocol so it can be mocked in unit tests and swapped without
/// touching callers (e.g. swapping URLSession for another transport).
protocol NetworkServiceProtocol {
    /// Performs the request described by `endpoint` and decodes the response into `T`.
    /// - Parameter endpoint: The type-safe endpoint to request.
    /// - Returns: A decoded value of type `T`.
    /// - Throws: A `NetworkError` describing the failure.
    func request<T: Decodable>(endpoint: Endpoint) async throws -> T
}
