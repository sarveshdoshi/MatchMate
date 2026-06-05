//
//  MatchProfileMapper.swift
//  MatchMate
//
//  Data Layer — converts between transport/persistence types and the domain model.
//  DTO → Domain, Entity → Domain, Domain → Entity.
//

import CoreData
import Foundation

/// Stateless converter between the Data layer's transport (`RandomUserDTO`) and
/// persistence (`MatchEntity`) types and the Domain's `MatchProfile`.
///
/// Mapping is defensive: when a critical field is missing the conversion fails
/// gracefully by returning `nil` rather than fabricating data or force-unwrapping.
enum MatchProfileMapper {
    // MARK: - DTO → Domain

    /// Maps an API DTO into a domain `MatchProfile`.
    ///
    /// Critical fields are the stable identifier (`login.uuid`) and at least one
    /// name component. Missing optional fields default to empty/zero values.
    /// - Parameter dto: The decoded API user.
    /// - Returns: A `MatchProfile`, or `nil` when critical fields are absent.
    static func map(_ dto: RandomUserDTO) -> MatchProfile? {
        guard let id = dto.login?.uuid, !id.isEmpty else {
            return nil
        }

        let firstName = dto.name?.first ?? ""
        let lastName = dto.name?.last ?? ""

        guard !firstName.isEmpty || !lastName.isEmpty else {
            return nil
        }

        return MatchProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            age: dto.dob?.age ?? 0,
            city: dto.location?.city ?? "",
            state: dto.location?.state ?? "",
            country: dto.location?.country ?? "",
            thumbnailURL: url(from: dto.picture?.thumbnail),
            largeImageURL: url(from: dto.picture?.large),
            email: dto.email ?? "",
            phone: dto.phone ?? "",
            status: .none
        )
    }

    /// Maps a collection of DTOs, discarding any that fail conversion.
    /// - Parameter dtos: The decoded API users.
    /// - Returns: The successfully mapped profiles.
    static func map(_ dtos: [RandomUserDTO]) -> [MatchProfile] {
        dtos.compactMap(map)
    }

    // MARK: - Entity → Domain

    /// Maps a Core Data `MatchEntity` into a domain `MatchProfile`.
    /// - Parameter entity: The persisted entity.
    /// - Returns: A `MatchProfile`, or `nil` when the identifier is missing.
    static func map(_ entity: MatchEntity) -> MatchProfile? {
        guard let id = entity.id, !id.isEmpty else {
            return nil
        }

        let status = MatchStatus(rawValue: entity.status ?? MatchStatus.none.rawValue) ?? .none

        return MatchProfile(
            id: id,
            firstName: entity.firstName ?? "",
            lastName: entity.lastName ?? "",
            age: Int(entity.age),
            city: entity.city ?? "",
            state: entity.state ?? "",
            country: entity.country ?? "",
            thumbnailURL: url(from: entity.thumbnailURL),
            largeImageURL: url(from: entity.largeImageURL),
            email: entity.email ?? "",
            phone: entity.phone ?? "",
            status: status
        )
    }

    // MARK: - Domain → Entity

    /// Populates a Core Data `MatchEntity` from a domain `MatchProfile`.
    ///
    /// Creates a fresh entity in the supplied context and copies all fields. The
    /// caller is responsible for upsert/dedup decisions and saving the context.
    /// - Parameters:
    ///   - profile: The domain profile to persist.
    ///   - context: The managed object context to insert into.
    /// - Returns: The populated (unsaved) managed object.
    @discardableResult
    static func mapToEntity(_ profile: MatchProfile, context: NSManagedObjectContext) -> MatchEntity {
        let entity = MatchEntity(context: context)
        apply(profile, to: entity)
        entity.fetchedAt = Date()
        return entity
    }

    /// Copies the fields of `profile` onto an existing entity, preserving identity.
    ///
    /// Used by the local data source's upsert path so an existing row is updated
    /// in place rather than duplicated.
    /// - Parameters:
    ///   - profile: The domain profile providing the values.
    ///   - entity: The entity to mutate.
    static func apply(_ profile: MatchProfile, to entity: MatchEntity) {
        entity.id = profile.id
        entity.firstName = profile.firstName
        entity.lastName = profile.lastName
        entity.age = Int16(clamping: profile.age)
        entity.city = profile.city
        entity.state = profile.state
        entity.country = profile.country
        entity.thumbnailURL = profile.thumbnailURL?.absoluteString ?? ""
        entity.largeImageURL = profile.largeImageURL?.absoluteString ?? ""
        entity.email = profile.email
        entity.phone = profile.phone
        entity.status = profile.status.rawValue
    }

    // MARK: - Helpers

    /// Builds a `URL` from an optional string, returning `nil` for empty/invalid input.
    private static func url(from string: String?) -> URL? {
        guard let string, !string.isEmpty else {
            return nil
        }
        return URL(string: string)
    }
}
