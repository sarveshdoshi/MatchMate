//
//  UpdateMatchStatusUseCase.swift
//  MatchMate
//
//  Domain Layer — business operation.
//  Depends only on the repository contract.
//

/// Updates the status (accepted / declined / none) of a single match profile.
///
/// Delegates to the repository. Kept as a discrete use case so validation or
/// side effects can be layered in later without touching callers.
final class UpdateMatchStatusUseCase {
    private let repository: MatchRepositoryProtocol

    init(repository: MatchRepositoryProtocol) {
        self.repository = repository
    }

    /// Executes the status update.
    /// - Parameters:
    ///   - profileId: The identifier of the profile to update.
    ///   - status: The new status to apply.
    func execute(profileId: String, status: MatchStatus) async throws {
        try await repository.updateStatus(for: profileId, to: status)
    }
}
