//
//  TestFixtures.swift
//  MatchMateTests
//
//  Shared factories for building deterministic test data.
//  Kept lightweight so every test reads against identical, predictable input.
//

import Foundation
@testable import MatchMate

// MARK: - Domain Model Factories

/// Builds a fully-populated `MatchProfile` with sensible defaults.
/// Override only the fields relevant to the test under inspection.
func makeProfile(
    id: String = "id-1",
    firstName: String = "Ada",
    lastName: String = "Lovelace",
    age: Int = 30,
    city: String = "London",
    state: String = "England",
    country: String = "United Kingdom",
    thumbnailURL: URL? = URL(string: "https://example.com/thumb.jpg"),
    largeImageURL: URL? = URL(string: "https://example.com/large.jpg"),
    email: String? = nil,
    phone: String = "555-0100",
    status: MatchStatus = .none
) -> MatchProfile {
    MatchProfile(
        id: id,
        firstName: firstName,
        lastName: lastName,
        age: age,
        city: city,
        state: state,
        country: country,
        thumbnailURL: thumbnailURL,
        largeImageURL: largeImageURL,
        // Default to a per-id unique email: the Core Data model enforces a
        // uniqueness constraint on `email`, so shared values would collapse rows.
        email: email ?? "\(id)@example.com",
        phone: phone,
        status: status
    )
}

extension MatchProfile {
    /// Returns a copy of the profile with a different status.
    func with(status newStatus: MatchStatus) -> MatchProfile {
        MatchProfile(
            id: id,
            firstName: firstName,
            lastName: lastName,
            age: age,
            city: city,
            state: state,
            country: country,
            thumbnailURL: thumbnailURL,
            largeImageURL: largeImageURL,
            email: email,
            phone: phone,
            status: newStatus
        )
    }
}

// MARK: - DTO Factories

/// Builds a `RandomUserDTO` with valid defaults. Pass `nil` to any parameter
/// to simulate missing/optional fields from the API.
func makeUserDTO(
    uuid: String? = "uuid-1",
    title: String? = "Ms",
    first: String? = "Ada",
    last: String? = "Lovelace",
    age: Int? = 30,
    city: String? = "London",
    state: String? = "England",
    country: String? = "United Kingdom",
    thumbnail: String? = "https://example.com/thumb.jpg",
    large: String? = "https://example.com/large.jpg",
    email: String? = "ada@example.com",
    phone: String? = "555-0100"
) -> RandomUserDTO {
    RandomUserDTO(
        name: NameDTO(title: title, first: first, last: last),
        location: LocationDTO(city: city, state: state, country: country),
        dob: DobDTO(date: nil, age: age),
        picture: PictureDTO(large: large, medium: nil, thumbnail: thumbnail),
        login: LoginDTO(uuid: uuid),
        email: email,
        phone: phone
    )
}

// MARK: - Errors

/// Generic error used to simulate failures from collaborators.
enum TestError: Error, Equatable {
    case generic
    case profileNotFound
}
