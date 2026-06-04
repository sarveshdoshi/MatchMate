//
//  MockRemoteDataSource.swift
//  MatchMateTests
//
//  Configurable mock for MatchRemoteDataSourceProtocol.
//

import Foundation
@testable import MatchMate

/// Configurable mock conforming to `MatchRemoteDataSourceProtocol`.
///
/// Set `result` to control the DTOs (or error) returned by `fetchUsers`.
final class MockRemoteDataSource: MatchRemoteDataSourceProtocol {
    var result: Result<[RandomUserDTO], Error> = .success([])

    private(set) var fetchUsersCallCount = 0

    func configureSuccess(_ dtos: [RandomUserDTO]) {
        result = .success(dtos)
    }

    func configureFailure(_ error: Error) {
        result = .failure(error)
    }

    func fetchUsers() async throws -> [RandomUserDTO] {
        fetchUsersCallCount += 1
        return try result.get()
    }
}
