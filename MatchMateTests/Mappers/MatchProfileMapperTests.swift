//
//  MatchProfileMapperTests.swift
//  MatchMateTests
//
//  Verifies DTO → Domain mapping: valid data, defensive nil handling,
//  default values for missing optionals, and batch mapping.
//

import XCTest
@testable import MatchMate

final class MatchProfileMapperTests: XCTestCase {
    // MARK: - Valid Data

    func test_mapDTO_withValidData_shouldReturnProfile() {
        let dto = makeUserDTO(
            uuid: "uuid-42",
            first: "Grace",
            last: "Hopper",
            age: 85,
            city: "New York",
            state: "New York",
            country: "United States",
            thumbnail: "https://example.com/thumb.jpg",
            large: "https://example.com/large.jpg",
            email: "grace@example.com",
            phone: "555-0199"
        )

        let profile = MatchProfileMapper.map(dto)

        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.id, "uuid-42")
        XCTAssertEqual(profile?.firstName, "Grace")
        XCTAssertEqual(profile?.lastName, "Hopper")
        XCTAssertEqual(profile?.age, 85)
        XCTAssertEqual(profile?.city, "New York")
        XCTAssertEqual(profile?.state, "New York")
        XCTAssertEqual(profile?.country, "United States")
        XCTAssertEqual(profile?.thumbnailURL, URL(string: "https://example.com/thumb.jpg"))
        XCTAssertEqual(profile?.largeImageURL, URL(string: "https://example.com/large.jpg"))
        XCTAssertEqual(profile?.email, "grace@example.com")
        XCTAssertEqual(profile?.phone, "555-0199")
        // New profiles always start with no decision.
        XCTAssertEqual(profile?.status, MatchStatus.none)
    }

    // MARK: - Missing Critical Fields

    func test_mapDTO_withMissingUUID_shouldReturnNil() {
        let dto = makeUserDTO(uuid: nil)

        XCTAssertNil(MatchProfileMapper.map(dto))
    }

    func test_mapDTO_withEmptyUUID_shouldReturnNil() {
        let dto = makeUserDTO(uuid: "")

        XCTAssertNil(MatchProfileMapper.map(dto))
    }

    func test_mapDTO_withMissingName_shouldReturnNil() {
        // Both first and last name absent → not enough to identify a person.
        let dto = makeUserDTO(first: nil, last: nil)

        XCTAssertNil(MatchProfileMapper.map(dto))
    }

    func test_mapDTO_withOnlyFirstName_shouldReturnProfile() {
        let dto = makeUserDTO(first: "Margaret", last: nil)

        let profile = MatchProfileMapper.map(dto)

        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.firstName, "Margaret")
        XCTAssertEqual(profile?.lastName, "")
    }

    // MARK: - Missing Optionals → Defaults

    func test_mapDTO_withMissingOptionalFields_shouldUseDefaults() {
        let dto = makeUserDTO(
            age: nil,
            city: nil,
            state: nil,
            country: nil,
            email: nil,
            phone: nil
        )

        let profile = MatchProfileMapper.map(dto)

        XCTAssertNotNil(profile)
        XCTAssertEqual(profile?.age, 0)
        XCTAssertEqual(profile?.city, "")
        XCTAssertEqual(profile?.state, "")
        XCTAssertEqual(profile?.country, "")
        XCTAssertEqual(profile?.email, "")
        XCTAssertEqual(profile?.phone, "")
    }

    func test_mapDTO_withInvalidImageURL_shouldHandleGracefully() {
        // Empty image strings should map to nil URLs rather than crash.
        let dto = makeUserDTO(thumbnail: "", large: nil)

        let profile = MatchProfileMapper.map(dto)

        XCTAssertNotNil(profile)
        XCTAssertNil(profile?.thumbnailURL)
        XCTAssertNil(profile?.largeImageURL)
    }

    // MARK: - Batch Mapping

    func test_mapMultipleDTOs_shouldReturnAllValid() {
        let valid1 = makeUserDTO(uuid: "a", first: "Ada")
        let valid2 = makeUserDTO(uuid: "b", first: "Grace")
        let invalid = makeUserDTO(uuid: nil) // dropped

        let profiles = MatchProfileMapper.map([valid1, invalid, valid2])

        XCTAssertEqual(profiles.count, 2)
        XCTAssertEqual(profiles.map(\.id), ["a", "b"])
    }

    func test_mapMultipleDTOs_withEmptyInput_shouldReturnEmpty() {
        XCTAssertTrue(MatchProfileMapper.map([RandomUserDTO]()).isEmpty)
    }
}
