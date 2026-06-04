//
//  NetworkServiceTests.swift
//  MatchMateTests
//
//  Verifies NetworkService request/decoding/error handling via MockURLProtocol.
//

import XCTest
@testable import MatchMate

final class NetworkServiceTests: XCTestCase {
    private var session: URLSession!
    private var sut: NetworkService!

    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        sut = NetworkService(session: session)
    }

    override func tearDown() {
        MockURLProtocol.reset()
        session = nil
        sut = nil
        super.tearDown()
    }

    private func makeHTTPResponse(statusCode: Int, url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    private func makeEndpoint() -> Endpoint {
        Endpoint(queryItems: [URLQueryItem(name: "results", value: "1")])
    }

    // MARK: - Success

    func test_request_withValidResponse_shouldReturnDecodedData() async throws {
        let json = """
        { "results": [ { "login": { "uuid": "uuid-1" }, "name": { "first": "Ada", "last": "Lovelace" } } ] }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = self.makeHTTPResponse(statusCode: 200, url: request.url!)
            return (response, json)
        }

        let result: RandomUserResponseDTO = try await sut.request(endpoint: makeEndpoint())

        XCTAssertEqual(result.results.count, 1)
        XCTAssertEqual(result.results.first?.login?.uuid, "uuid-1")
        XCTAssertEqual(result.results.first?.name?.first, "Ada")
    }

    // MARK: - Server Errors

    func test_request_with404_shouldReturnServerError() async {
        MockURLProtocol.requestHandler = { request in
            (self.makeHTTPResponse(statusCode: 404, url: request.url!), Data("{}".utf8))
        }

        await assertThrowsNetworkError(.serverError(404))
    }

    func test_request_with500_shouldReturnServerError() async {
        MockURLProtocol.requestHandler = { request in
            (self.makeHTTPResponse(statusCode: 500, url: request.url!), Data("{}".utf8))
        }

        await assertThrowsNetworkError(.serverError(500))
    }

    // MARK: - Decoding

    func test_request_withInvalidJSON_shouldReturnDecodingError() async {
        MockURLProtocol.requestHandler = { request in
            (self.makeHTTPResponse(statusCode: 200, url: request.url!), Data("not json".utf8))
        }

        await assertThrowsNetworkError(.decodingError)
    }

    // MARK: - Empty Body

    func test_request_withEmptyData_shouldReturnNoData() async {
        MockURLProtocol.requestHandler = { request in
            (self.makeHTTPResponse(statusCode: 200, url: request.url!), Data())
        }

        await assertThrowsNetworkError(.noData)
    }

    // MARK: - Connectivity

    func test_request_whenNotConnectedToInternet_shouldReturnNoInternet() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.notConnectedToInternet)
        }

        await assertThrowsNetworkError(.noInternet)
    }

    func test_request_whenConnectionLost_shouldReturnNoInternet() async {
        MockURLProtocol.requestHandler = { _ in
            throw URLError(.networkConnectionLost)
        }

        await assertThrowsNetworkError(.noInternet)
    }

    // MARK: - Helpers

    private func assertThrowsNetworkError(
        _ expected: NetworkError,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            let _: RandomUserResponseDTO = try await sut.request(endpoint: makeEndpoint())
            XCTFail("Expected to throw \(expected)", file: file, line: line)
        } catch let error as NetworkError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Expected NetworkError.\(expected) but got \(error)", file: file, line: line)
        }
    }
}
