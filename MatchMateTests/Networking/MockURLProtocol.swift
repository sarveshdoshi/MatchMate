//
//  MockURLProtocol.swift
//  MatchMateTests
//
//  URLProtocol subclass that intercepts requests so NetworkService can be
//  tested against canned responses without real network access.
//

import Foundation

/// Intercepts `URLSession` traffic and returns a programmable response/error.
///
/// Configure `requestHandler` before each test. Register it on a custom
/// `URLSessionConfiguration` (`protocolClasses = [MockURLProtocol.self]`).
final class MockURLProtocol: URLProtocol {
    /// Returns the response + body to deliver, or throws to simulate a transport error.
    nonisolated(unsafe) static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data?))?

    static func reset() {
        requestHandler = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
