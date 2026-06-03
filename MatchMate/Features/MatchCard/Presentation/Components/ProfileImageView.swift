//
//  ProfileImageView.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SDWebImageSwiftUI
import SwiftUI

/// Loads and displays a remote profile image with placeholder and failure handling.
///
/// Wraps SDWebImageSwiftUI's `WebImage` so caching, transitions, and offline
/// disk-cache behaviour are centralised in one place.
struct ProfileImageView: View {
    let url: URL?
    let height: CGFloat

    init(url: URL?, height: CGFloat = 280) {
        self.url = url
        self.height = height
    }

    var body: some View {
        WebImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            placeholder
        }
        .transition(.fade(duration: 0.3))
        .frame(maxWidth: .infinity)
        .frame(height: height)
        .clipped()
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .overlay {
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.square")
                        .font(.system(size: 44))
                        .foregroundStyle(.secondary)
                    ProgressView()
                }
            }
    }
}

#Preview {
    ProfileImageView(url: nil)
        .frame(height: 280)
}
