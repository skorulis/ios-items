import Models
import SwiftUI

@MainActor struct CreatedItemView: View {
    let items: [MakeItemResult]
    let onDetailsTap: (MakeItemResult) -> Void

    var body: some View {
        if items.isEmpty {
            EmptyView()
        } else if items.count == 1 {
            createdItem(item: items[0])
        } else {
            ringView(items: items)
        }
    }

    // MARK: - Single Item Rendering

    @ViewBuilder
    private func createdItem(item: MakeItemResult) -> some View {
        Button(
            action: { onDetailsTap(item) },
            label: {
                content(item: item)
            }
        )
    }

    private var avatarSize: AvatarView.Size {
        if items.count > 1 { return .small }
        return .medium
    }

    @ViewBuilder
    private func content(item: MakeItemResult) -> some View {
        switch item {
        case let .base(baseItem, count):
            ItemView(
                item: baseItem,
                quantity: count > 1 ? count : nil,
                size: avatarSize,
            )
        case let .artifact(instance):
            ArtifactView(artifact: instance, size: avatarSize)
        }
    }

    // MARK: - Circular Layout (multiple items)

    private func ringView(items: [MakeItemResult]) -> some View {
        let avatarSize = AvatarView.Size.small
        let ringRadius = avatarSize.diameter * 0.8

        return GeometryReader { geo in
            ringItems(geo: geo)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(width: ringRadius * 2, height: ringRadius * 2)
    }

    private func ringItems(geo: GeometryProxy) -> some View {
        let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
        let ringRadius = avatarSize.diameter * 0.8

        return ZStack {
            ForEach(0..<items.count, id: \.self) { index in
                let angle = angle(for: index, slotCount: items.count)
                let x = center.x + ringRadius * cos(angle) * 0.9
                let y = center.y + ringRadius * sin(angle) * 0.9

                createdItem(item: items[index])
                    .position(x: x, y: y)
            }
        }
        .frame(width: geo.size.width, height: geo.size.height)
    }

    private func angle(for index: Int, slotCount: Int) -> CGFloat {
        guard slotCount >= 2 else { return 0 }
        let step = (2 * .pi) / CGFloat(slotCount)
        // 0 = top, clockwise.
        return -(.pi / 2) + step * CGFloat(index)
    }
}

// MARK: - Previews

#Preview("Single base") {
    CreatedItemView(
        items: [.base(.gear, 1)],
        onDetailsTap: { _ in }
    )
}

#Preview("Single artifact") {
    CreatedItemView(
        items: [
            .artifact(.init(type: .frictionlessGear, quality: .junk))
        ],
        onDetailsTap: { _ in }
    )
}

#Preview("Ring multiple") {
    CreatedItemView(
        items: [
            .base(.gear, 1),
            .base(.silverFlorin, 2),
            .artifact(.init(type: .frictionlessGear, quality: .good)),
            .base(.apple, 1),
        ],
        onDetailsTap: { _ in }
    )
}
