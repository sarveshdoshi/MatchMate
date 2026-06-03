//
//  MatchProfile.swift
//  MatchMate
//
//  Domain Layer — pure business model.
//  Foundation is imported only for the URL type.
//

import Foundation

/// Domain model representing a single match profile.
struct MatchProfile: Identifiable, Equatable {
    let id: String
    let firstName: String
    let lastName: String
    let age: Int
    let city: String
    let state: String
    let country: String
    let thumbnailURL: URL?
    let largeImageURL: URL?
    let email: String
    let phone: String
    let status: MatchStatus

    init(
        id: String,
        firstName: String,
        lastName: String,
        age: Int,
        city: String,
        state: String,
        country: String,
        thumbnailURL: URL?,
        largeImageURL: URL?,
        email: String,
        phone: String,
        status: MatchStatus
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self.city = city
        self.state = state
        self.country = country
        self.thumbnailURL = thumbnailURL
        self.largeImageURL = largeImageURL
        self.email = email
        self.phone = phone
        self.status = status
    }
}
