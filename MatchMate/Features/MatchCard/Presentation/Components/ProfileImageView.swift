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
/// disk-cache behaviour are centralised in one place. The image fills whatever
/// frame the caller applies, so the parent owns sizing and shape (rectangle,
/// circle, etc.).
struct ProfileImageView: View {
    let url: URL?

    var body: some View {
        WebImage(url: url) { image in
            image
                .resizable()
                .scaledToFill()
        } placeholder: {
            placeholder
        }
        .transition(.fade(duration: 0.3))
        .accessibilityHidden(true)
    }

    private var placeholder: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.15))
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(.secondary)
            }
    }
}

#Preview {
    ProfileImageView(url: nil)
        .frame(width: 100, height: 100)
        .clipShape(Circle())
}
