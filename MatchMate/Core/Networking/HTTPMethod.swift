//
//  HTTPMethod.swift
//  MatchMate
//
//  Core Infrastructure — Networking
//

import Foundation

/// Type-safe representation of supported HTTP verbs.
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
