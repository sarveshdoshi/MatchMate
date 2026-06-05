//
//  NetworkService.swift
//  MatchMate
//
//  Core Infrastructure — Networking
//

import Foundation

/// Minimal abstraction over `URLSession` to allow injecting a mock transport in tests.
protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

extension URLSession: URLSessionProtocol {}

/// `URLSession`-backed implementation of `NetworkServiceProtocol` using async/await.
final class NetworkService: NetworkServiceProtocol {
    private let session: URLSessionProtocol
    private let decoder: JSONDecoder

    init(
        session: URLSessionProtocol = URLSession.shared,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.session = session
        self.decoder = decoder
    }

    func request<T: Decodable>(endpoint: Endpoint) async throws -> T {
        let urlRequest = try endpoint.makeURLRequest()

        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let error as URLError where error.code == .notConnectedToInternet {
            throw NetworkError.noInternet
        } catch let error as URLError where error.code == .networkConnectionLost {
            throw NetworkError.noInternet
        } catch {
            throw NetworkError.unknown(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        guard (200 ... 299).contains(httpResponse.statusCode) else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw NetworkError.noData
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError
        }
    }
}
