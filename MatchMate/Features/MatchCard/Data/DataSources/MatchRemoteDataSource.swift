//
//  MatchRemoteDataSource.swift
//  MatchMate
//
//  Data Layer — remote source backed by the randomuser.me API.
//

import Foundation

/// Abstraction over the remote match source so the repository can be tested
/// against a mock without hitting the network.
protocol MatchRemoteDataSourceProtocol {
    /// Fetches a batch of users from the API.
    /// - Returns: The decoded user DTOs.
    /// - Throws: A `NetworkError` describing any failure.
    func fetchUsers() async throws -> [RandomUserDTO]
}

/// Fetches match profiles from `https://randomuser.me/api/` via `NetworkServiceProtocol`.
final class MatchRemoteDataSource: MatchRemoteDataSourceProtocol {
    private let networkService: NetworkServiceProtocol
    private let resultCount: Int

    init(networkService: NetworkServiceProtocol, resultCount: Int = 10) {
        self.networkService = networkService
        self.resultCount = resultCount
    }

    func fetchUsers() async throws -> [RandomUserDTO] {
        let endpoint = Endpoint(
            queryItems: [URLQueryItem(name: "results", value: String(resultCount))]
        )
        let response: RandomUserResponseDTO = try await networkService.request(endpoint: endpoint)
        return response.results
    }
}
