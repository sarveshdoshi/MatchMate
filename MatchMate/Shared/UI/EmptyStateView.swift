//
//  EmptyStateView.swift
//  MatchMate
//
//  Shared — UI
//

import SwiftUI

/// A reusable empty-state view shown when there is no content to display.
struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String

    init(
        title: String = "No Matches Yet",
        message: String = "Pull down to refresh and find new matches.",
        systemImage: String = "heart.slash"
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
    }

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(title). \(message)"))
    }
}

#Preview {
    EmptyStateView()
}
