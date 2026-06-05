//
//  FetchMatchesUseCase.swift
//  MatchMate
//
//  Domain Layer — business operation.
//  Depends only on the repository contract.
//

/// Fetches the list of match profiles.
///
/// Delegates to the repository. Kept as a discrete use case so behaviour
/// (caching, filtering, decoration) can be added later without touching callers.
final class FetchMatchesUseCase {
    private let repository: MatchRepositoryProtocol

    init(repository: MatchRepositoryProtocol) {
        self.repository = repository
    }

    /// Executes the fetch operation.
    /// - Returns: The current list of match profiles.
    func execute() async throws -> [MatchProfile] {
        try await repository.fetchMatches()
    }
}
