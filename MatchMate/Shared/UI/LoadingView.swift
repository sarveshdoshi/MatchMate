//
//  LoadingView.swift
//  MatchMate
//
//  Shared — UI
//

import SwiftUI

/// A centered, reusable loading indicator with an optional message.
struct LoadingView: View {
    let message: String

    init(message: String = "Loading matches…") {
        self.message = message
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.3)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(message))
    }
}

#Preview {
    LoadingView()
}
