//
//  RandomUserResponseDTO.swift
//  MatchMate
//
//  Data Layer — Codable models mirroring the randomuser.me API response.
//  These are transport types only; they never escape the Data layer.
//

import Foundation

// MARK: - Top-Level Response

/// Top-level decodable wrapper for the `https://randomuser.me/api/` response.
struct RandomUserResponseDTO: Decodable {
    let results: [RandomUserDTO]
}

// MARK: - User

/// A single user record returned by the API.
struct RandomUserDTO: Decodable {
    let name: NameDTO?
    let location: LocationDTO?
    let dob: DobDTO?
    let picture: PictureDTO?
    let login: LoginDTO?
    let email: String?
    let phone: String?
}

// MARK: - Nested Models

/// The user's name components.
struct NameDTO: Decodable {
    let title: String?
    let first: String?
    let last: String?
}

/// The user's location.
struct LocationDTO: Decodable {
    let city: String?
    let state: String?
    let country: String?
}

/// The user's date of birth and derived age.
struct DobDTO: Decodable {
    let date: String?
    let age: Int?
}

/// The user's profile picture URLs.
struct PictureDTO: Decodable {
    let large: String?
    let medium: String?
    let thumbnail: String?
}

/// Login metadata; `uuid` is used as the stable profile identifier.
struct LoginDTO: Decodable {
    let uuid: String?
}
