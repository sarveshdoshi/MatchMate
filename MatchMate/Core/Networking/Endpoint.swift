//
//  Endpoint.swift
//  MatchMate
//
//  Core Infrastructure — Networking
//

import Foundation

/// Type-safe builder for API endpoints.
///
/// Composes a request against the RandomUser base URL (`https://randomuser.me/api/`)
/// from a path, query items, HTTP method, headers, and an optional body.
struct Endpoint {
    /// Base URL shared by all endpoints.
    static let baseURLString = "https://randomuser.me/api/"

    let path: String
    let method: HTTPMethod
    let queryItems: [URLQueryItem]
    let headers: [String: String]
    let body: Data?

    init(
        path: String = "",
        method: HTTPMethod = .get,
        queryItems: [URLQueryItem] = [],
        headers: [String: String] = [:],
        body: Data? = nil
    ) {
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }

    /// Builds the fully-qualified `URL` for this endpoint, or `nil` if it cannot be constructed.
    var url: URL? {
        guard var components = URLComponents(string: Endpoint.baseURLString) else {
            return nil
        }

        if !path.isEmpty {
            components.path = (components.path as NSString).appendingPathComponent(path)
        }

        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        return components.url
    }

    /// Builds a configured `URLRequest`, or throws `NetworkError.invalidURL` when the URL is invalid.
    func makeURLRequest() throws -> URLRequest {
        guard let url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.httpBody = body

        for (field, value) in headers {
            request.setValue(value, forHTTPHeaderField: field)
        }

        return request
    }
}
