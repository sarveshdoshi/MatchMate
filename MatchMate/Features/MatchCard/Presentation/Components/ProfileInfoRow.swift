//
//  ProfileInfoRow.swift
//  MatchMate
//
//  Presentation Layer — Component
//

import SwiftUI

/// A single detail row on a match card: a soft-tinted icon chip followed by text.
///
/// Used for the location and region lines beneath a profile's name.
struct ProfileInfoRow: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 28, height: 28)
                .background(RoundedRectangle(cornerRadius: 8, style: .continuous).fill(Theme.primarySoft))

            Text(text)
                .font(.system(size: 15))
                .foregroundStyle(Theme.textSecondary)
                .lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(text))
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 12) {
        ProfileInfoRow(systemImage: "mappin.and.ellipse", text: "43, Keswick, Yukon")
        ProfileInfoRow(systemImage: "building.2.fill", text: "Canada")
    }
    .padding()
}
