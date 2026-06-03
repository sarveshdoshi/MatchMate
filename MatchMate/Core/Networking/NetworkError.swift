//
//  NetworkError.swift
//  MatchMate
//
//  Core Infrastructure — Networking
//

import Foundation

/// Typed error surface for all networking failures.
enum NetworkError: Error, Equatable {
    case invalidURL
    case noData
    case decodingError
    case serverError(Int)
    case noInternet
    case unknown(Error)

    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.invalidURL, .invalidURL),
             (.noData, .noData),
             (.decodingError, .decodingError),
             (.noInternet, .noInternet):
            return true
        case let (.serverError(lhsCode), .serverError(rhsCode)):
            return lhsCode == rhsCode
        case let (.unknown(lhsError), .unknown(rhsError)):
            return (lhsError as NSError) == (rhsError as NSError)
        default:
            return false
        }
    }
}

// MARK: - LocalizedError

extension NetworkError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .noData:
            return "No data was returned from the server."
        case .decodingError:
            return "The server response could not be decoded."
        case let .serverError(code):
            return "The server responded with an error (status code \(code))."
        case .noInternet:
            return "No internet connection is available."
        case let .unknown(error):
            return error.localizedDescription
        }
    }
}
