//
//  CoreDataStack.swift
//  MatchMate
//
//  Core Infrastructure — Persistence
//

import CoreData
import Foundation
import os

/// Abstraction over the Core Data stack so the persistence layer can be mocked in tests.
protocol CoreDataStackProtocol: AnyObject {
    /// Main-queue context used for UI reads.
    var viewContext: NSManagedObjectContext { get }

    /// Creates a new private-queue context for background writes.
    func newBackgroundContext() -> NSManagedObjectContext
}

/// Manages the `NSPersistentContainer` for the app.
///
/// Supports an in-memory store (`inMemory: true`) so tests run against a disposable
/// store with no on-disk side effects.
final class CoreDataStack: CoreDataStackProtocol {
    static let modelName = "MatchMate"

    private let container: NSPersistentContainer
    private let logger = Logger(subsystem: "com.matchmate", category: "CoreDataStack")

    var viewContext: NSManagedObjectContext {
        container.viewContext
    }

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: CoreDataStack.modelName)

        if inMemory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { [logger] _, error in
            if let error {
                logger.error("Failed to load persistent store: \(error.localizedDescription, privacy: .public)")
            }
        }

        // Upsert support: merge incoming changes over existing objects by property.
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
}
