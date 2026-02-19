//Created by Alexander Skorulis on 16/2/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct AvatarView {
    
    enum Size: Identifiable, CaseIterable {
        case small, medium, large
        var id: Self { self }
    }
    
    private let size: Size
    private let initials: String
    private let image: Image?
    private let border: Color
    
    private let badge: String?
    
    init(
        initials: String,
        image: Image?,
        border: Color,
        badge: String? = nil,
        size: Size = .medium,
    ) {
        self.initials = initials
        self.image = image
        self.border = border
        self.badge = badge
        self.size = size
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
                .fill(ColorHash.color(for: initials))
            
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
            Text(initials)
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

fileprivate extension AvatarView.Size {
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
            return 48
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
                    initials: "AB",
                    image: nil,
                    border: .orange,
                    size: size,
                )
            }
        }
        
        HStack {
            ForEach(AvatarView.Size.allCases) { size in
                AvatarView(
                    initials: "AP",
                    image: Asset.BaseItem.apple.swiftUIImage,
                    border: .orange,
                    size: size,
                )
            }
        }
        
    }
    
    
}

