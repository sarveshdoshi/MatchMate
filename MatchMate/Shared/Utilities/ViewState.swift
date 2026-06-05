//
//  ViewState.swift
//  MatchMate
//
//  Shared — Utilities
//

import Foundation

/// Unified screen state used by all ViewModels for reactive UI rendering.
enum ViewState<T> {
    case idle
    case loading
    case loaded(T)
    case error(String)
}

// MARK: - Convenience Accessors

extension ViewState {
    var value: T? {
        if case let .loaded(value) = self {
            return value
        }
        return nil
    }

    var isLoading: Bool {
        if case .loading = self {
            return true
        }
        return false
    }

    var errorMessage: String? {
        if case let .error(message) = self {
            return message
        }
        return nil
    }
}

// MARK: - Equatable

extension ViewState: Equatable where T: Equatable {
    static func == (lhs: ViewState<T>, rhs: ViewState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case let (.loaded(lhsValue), .loaded(rhsValue)):
            return lhsValue == rhsValue
        case let (.error(lhsMessage), .error(rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
