//
//  MatchLocalDataSource.swift
//  MatchMate
//
//  Data Layer — local source backed by Core Data.
//  Reads on the view context, writes on a background context, upsert by id.
//

import CoreData
import Foundation
import os

/// Abstraction over the local match store so the repository can be tested
/// against a mock without a real Core Data stack.
protocol MatchLocalDataSourceProtocol {
    /// Returns all cached profiles.
    func fetchAll() async throws -> [MatchProfile]

    /// Inserts or updates the given profiles, preserving any existing
    /// accept/decline status for profiles already present.
    func save(profiles: [MatchProfile]) async throws

    /// Updates the status of a single profile, persisting immediately.
    func updateStatus(for profileId: String, to status: MatchStatus) async throws
}

/// Core Data-backed implementation of `MatchLocalDataSourceProtocol`.
///
/// Upserts by the domain `id` (`login.uuid`): when a profile already exists its
/// row is updated in place — and its existing status is preserved — rather than
/// duplicated. Writes happen on a private-queue background context so they remain
/// safe and non-blocking, including while offline.
final class MatchLocalDataSource: MatchLocalDataSourceProtocol {
    private let coreDataStack: CoreDataStackProtocol
    private let logger = Logger(subsystem: "com.matchmate", category: "MatchLocalDataSource")

    init(coreDataStack: CoreDataStackProtocol) {
        self.coreDataStack = coreDataStack
    }

    // MARK: - Read

    func fetchAll() async throws -> [MatchProfile] {
        let context = coreDataStack.viewContext
        return try await context.perform {
            let request = MatchEntity.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "fetchedAt", ascending: true)]
            let entities = try context.fetch(request)
            return entities.compactMap(MatchProfileMapper.map)
        }
    }

    // MARK: - Write

    func save(profiles: [MatchProfile]) async throws {
        guard !profiles.isEmpty else { return }

        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            for profile in profiles {
                let entity = try self.existingEntity(withID: profile.id, in: context)
                    ?? MatchEntity(context: context)

                if entity.id == nil || entity.id?.isEmpty == true {
                    // Newly created entity: populate everything (status from profile).
                    MatchProfileMapper.apply(profile, to: entity)
                } else {
                    // Existing entity: refresh fields but preserve the user's decision.
                    let existingStatus = MatchStatus(rawValue: entity.status ?? "") ?? .none
                    MatchProfileMapper.apply(profile, to: entity)
                    entity.status = existingStatus.rawValue
                }
                entity.fetchedAt = Date()
            }

            if context.hasChanges {
                try context.save()
            }
        }
    }

    func updateStatus(for profileId: String, to status: MatchStatus) async throws {
        let context = coreDataStack.newBackgroundContext()
        try await context.perform {
            guard let entity = try self.existingEntity(withID: profileId, in: context) else {
                self.logger.error("updateStatus: no profile found for id \(profileId, privacy: .public)")
                return
            }
            entity.status = status.rawValue
            if context.hasChanges {
                try context.save()
            }
        }
    }

    // MARK: - Helpers

    /// Fetches the single entity matching `id`, or `nil` when none exists.
    private func existingEntity(withID id: String, in context: NSManagedObjectContext) throws -> MatchEntity? {
        let request = MatchEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}
