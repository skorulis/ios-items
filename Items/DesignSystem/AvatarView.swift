//Created by Alexander Skorulis on 16/2/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct AvatarView {
    
    enum Size: Identifiable, CaseIterable {
        case small, medium, large
        var id: Self { self }
    }
    
    private let size: Size
    private let text: String
    private let image: Image?
    private let border: Color
    
    private let badge: String?
    
    init(
        text: String,
        image: Image?,
        border: Color,
        badge: String? = nil,
        size: Size = .medium,
    ) {
        self.text = text
        self.image = image
        self.border = border
        self.badge = badge
        self.size = size
    }

    /// Reusable empty/undiscovered state (e.g. for BaseItem or artifact slots).
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
    }
    
    private var mainCircle: some View {
        ZStack {
            Circle()
                .fill(ColorHash.gradient(for: text))
            
            Circle()
                .stroke(border, lineWidth: 2)
            
            content
            
        }
        .frame(width: size.diameter, height: size.diameter)
    }
    
    @ViewBuilder
    private var content: some View {
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(Color.white)
                .frame(width: size.imageSize, height: size.imageSize)
        } else {
            Text(text.acronym())
                .font(size.font)
                .bold()
                .foregroundStyle(Color.white)
        }
    }
    
    @ViewBuilder
    private var maybeBadge: some View {
        if let badge {
            Text(badge)
                .monospaced()
                .bold()
                .font(.subheadline)
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
            return .body
        case .medium:
            return .title
        case .large:
            return .largeTitle
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
        
    }
    
    
}

