//
//  ErrorView.swift
//  MatchMate
//
//  Shared — UI
//

import SwiftUI

/// A reusable error state view that surfaces a message and a retry action.
struct ErrorView: View {
    let message: String
    let retryTitle: String
    let onRetry: () -> Void

    init(
        message: String,
        retryTitle: String = "Try Again",
        onRetry: @escaping () -> Void
    ) {
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 44))
                .foregroundStyle(.orange)
                .accessibilityHidden(true)

            Text("Something went wrong")
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(action: onRetry) {
                Label(retryTitle, systemImage: "arrow.clockwise")
                    .font(.body.weight(.semibold))
            }
            .buttonStyle(.borderedProminent)
            .accessibilityLabel(Text(retryTitle))
            .accessibilityHint(Text("Reloads the list of matches"))
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(message: "We couldn't reach the server. Check your connection and try again.") {}
}
