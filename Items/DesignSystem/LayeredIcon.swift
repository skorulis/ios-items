// Created by Cursor on 24/3/2026.

import SwiftUI

/// Stacks a primary image with a smaller overlay pinned to the bottom-right corner.
public struct LayeredIcon: View {

    private let main: Image
    private let tintColor: Color?
    private let overlay: Image?
    private let diameter: CGFloat

    /// - Parameters:
    ///   - main: Full-area image, centered in the icon.
    ///   - overlay: Smaller badge in the bottom-right.
    ///   - diameter: Overall square size for layout.
    public init(
        main: Image,
        tintColor: Color? = nil,
        overlay: Image? = nil,
        diameter: CGFloat = 40
    ) {
        self.main = main
        self.tintColor = tintColor
        self.overlay = overlay
        self.diameter = diameter
    }

    func size(_ diameter: CGFloat) -> Self {
        .init(main: main, overlay: overlay, diameter: diameter)
    }

    private var overlayDiameter: CGFloat { diameter * 0.3 }

    public var body: some View {
        ZStack(alignment: .topTrailing) {
            if let tintColor {
                mainImage
                    .colorMultiply(tintColor)
            } else {
                mainImage
            }

            if let overlay {
                overlay
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: overlayDiameter, height: overlayDiameter)
            }
        }
        .frame(width: diameter, height: diameter)
    }

    private var mainImage: some View {
        main
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: diameter * 0.70, height: diameter * 0.70)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}

#Preview("LayeredIcon examples") {
    VStack(alignment: .leading, spacing: 20) {
        HStack(spacing: 16) {
            LayeredIcon(main: Image(systemName: "flask.fill"), overlay: Image(systemName: "2.circle.fill"))
            LayeredIcon(main: Image(systemName: "flame.fill"), overlay: Image(systemName: "3.circle.fill"))
            LayeredIcon(main: Image(systemName: "map.fill"), overlay: Image(systemName: "mappin.circle.fill"))
        }
        HStack(spacing: 24) {
            LayeredIcon(
                main: Image(systemName: "book.fill"),
                overlay: Image(systemName: "1.circle.fill"),
                diameter: 40
            )
            LayeredIcon(
                main: Image(systemName: "person.3.fill"),
                overlay: Image(systemName: "5.circle.fill"),
                diameter: 40
            )
        }
        HStack {
            LayeredIcon(
                main: Asset.Equipment.dagger.swiftUIImage,
                tintColor: Color.orange,
                diameter: 60
            )
        }
    }
    .padding()
    .foregroundStyle(.primary)
}
