// Created by Alexander Skorulis on 16/2/2026.

import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct AvatarView {

    enum Size: Identifiable, CaseIterable {
        case small, medium, large
        var id: Self { self }
    }

    enum ImageType {
        case image(Image)
        case icon(LayeredIcon)
    }

    private let size: Size
    private let text: String
    private let image: ImageType?
    private let border: Color

    private let badge: String?
    private let showNewBadge: Bool

    init(
        text: String,
        image: Image?,
        border: Color,
        badge: String? = nil,
        showNewBadge: Bool = false,
        size: Size = .medium,
    ) {
        self.text = text
        self.image = image.map { .image($0) }
        self.border = border
        self.badge = badge
        self.showNewBadge = showNewBadge
        self.size = size
    }

    init(
        text: String,
        icon: LayeredIcon?,
        border: Color,
        badge: String? = nil,
        showNewBadge: Bool = false,
        size: Size = .medium,
    ) {
        self.text = text
        self.image = icon.map { .icon($0) }
        self.border = border
        self.badge = badge
        self.showNewBadge = showNewBadge
        self.size = size
    }

    /// Reusable empty/undiscovered state (e.g. for Ingredient or artifact slots).
    static func emptyState(size: Size = .medium) -> AvatarView {
        AvatarView(
            text: "",
            image: Image(systemName: "questionmark"),
            border: .black,
            size: size
        )
    }
}

// MARK: - Rendering

extension AvatarView: View {

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            mainCircle
            maybeBadge
        }
        .overlay(alignment: .topTrailing) {
            if showNewBadge {
                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
                    .padding(4)
            }
        }
    }

    private var mainCircle: some View {
        ZStack {
            Circle()
                .fill(ColorHash.gradient(for: text))

            Circle()
                .stroke(border, lineWidth: 2)
                .padding(1)

            content

        }
        .frame(width: size.diameter, height: size.diameter)
    }

    @ViewBuilder
    private var content: some View {
        if let image {
            imageContent(image)
        } else {
            Text(text.acronym())
                .font(size.font)
                .bold()
                .foregroundStyle(Color.white)
        }
    }

    @ViewBuilder
    private func imageContent(_ image: ImageType) -> some View {
        switch image {
        case let .image(image):
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.white)
                .frame(width: size.imageSize, height: size.imageSize)
        case let .icon(layeredIcon):
            layeredIcon.size(size.imageSize)
        }
    }

    @ViewBuilder
    private var maybeBadge: some View {
        if let badge {
            Text(badge)
                .font(.appMonospaceBadge)
                .foregroundStyle(Color.white)
                .padding(2)
                .background(Capsule())
                .padding(2)
        }
    }
}

extension AvatarView.Size {
     var diameter: CGFloat {
        switch self {
        case .small:
            return 32
        case .medium:
            return 60
        case .large:
            return 80
        }
    }

    var imageSize: CGFloat {
        switch self {
        case .small:
            return 24
        case .medium:
            return 44
        case .large:
            return 60
        }
    }

    var font: Font {
        switch self {
        case .small:
            return .appBody
        case .medium:
            return .appTitle
        case .large:
            return .appLargeTitle
        }
    }
}

// MARK: - Previews

#Preview {
    VStack {
        HStack {
            ForEach(AvatarView.Size.allCases) { size in
                AvatarView(
                    text: "AB",
                    image: nil,
                    border: .orange,
                    size: size,
                )
            }
        }

        HStack {
            ForEach(AvatarView.Size.allCases) { size in
                AvatarView(
                    text: "AP",
                    image: Asset.BaseItem.apple.swiftUIImage,
                    border: .orange,
                    size: size,
                )
            }
        }

        AvatarView(
            text: "New",
            image: nil,
            border: .green,
            showNewBadge: true,
            size: .medium,
        )
    }

}
