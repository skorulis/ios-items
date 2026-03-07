// Created by Alexander Skorulis on 7/3/2026.

import SwiftUI

// MARK: - Memory footprint

@MainActor struct ArtifactSlotView {
    /// One entry per slot; nil = empty circle, non-nil = artifact in that slot.
    let slots: [ArtifactInstance?]
    let size: Size
    /// Called when a slot is pressed; receives the slot index.
    let onSlotPressed: (Int) -> Void

    enum Size {
        case small
        case large
    }

    init(
        slots: [ArtifactInstance?],
        size: Size = .large,
        onSlotPressed: @escaping (Int) -> Void = { _ in }
    ) {
        self.slots = slots
        self.size = size
        self.onSlotPressed = onSlotPressed
    }
}

// MARK: - Avatar size

private extension ArtifactSlotView.Size {
    var avatarSize: AvatarView.Size {
        switch self {
        case .small: return .small
        case .large: return .large
        }
    }
}

// MARK: - Ring layout

private extension ArtifactSlotView {
    var slotCount: Int {
        max(1, slots.count)
    }

    /// Radius of the ring (center to slot center). Single slot is not on a ring.
    func ringRadius(avatarDiameter: CGFloat) -> CGFloat {
        return avatarDiameter * (0.8)
    }

    /// Angle in radians for slot at index (0 = top, clockwise).
    func angle(for index: Int) -> CGFloat {
        guard slotCount >= 2 else { return 0 }
        let step = (2 * .pi) / CGFloat(slotCount)
        return -(.pi / 2) + step * CGFloat(index)
    }
}

// MARK: - View

extension ArtifactSlotView: View {
    var body: some View {
        GeometryReader { geo in
            let avatarSize = size.avatarSize
            let diameter = avatarSize.diameter
            let radius = ringRadius(avatarDiameter: diameter)
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ZStack {
                Circle()
                    .stroke(.secondary, lineWidth: 2)
                    .frame(width: radius * 2, height: radius * 2)
                    .position(x: center.x, y: center.y)
                if slotCount == 1 {
                    slotView(at: 0, avatarSize: avatarSize)
                } else {
                    ForEach(0..<slotCount, id: \.self) { index in
                        let angle = angle(for: index)
                        let x = center.x + radius * cos(angle) * 0.9
                        let y = center.y + radius * sin(angle) * 0.9
                        slotView(at: index, avatarSize: avatarSize)
                            .position(x: x, y: y)
                    }
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    @ViewBuilder
    private func slotView(at index: Int, avatarSize: AvatarView.Size) -> some View {
        let content: some View = Group {
            if index < slots.count, let instance = slots[index] {
                ArtifactView(artifact: instance, size: avatarSize)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white)
                    
                    Circle()
                        .stroke(.secondary, lineWidth: 2)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: avatarSize.diameter * 0.5,
                            height: avatarSize.diameter * 0.5
                        )
                }
                .frame(width: avatarSize.diameter, height: avatarSize.diameter)
            }
        }
        Button(action: { onSlotPressed(index) }) {
            content
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("1 slot - empty") {
    ArtifactSlotView(slots: [nil], size: .large)
        .frame(width: 160, height: 160)
}

#Preview("1 slot - filled") {
    ArtifactSlotView(
        slots: [ArtifactInstance(type: .frictionlessGear, quality: .good)],
        size: .large
    )
    .frame(width: 160, height: 160)
}

#Preview("2 slots - mixed") {
    ArtifactSlotView(
        slots: [
            ArtifactInstance(type: .luckyCoin, quality: .common),
            nil,
        ],
        size: .large
    )
    .frame(width: 200, height: 200)
}

#Preview("3 slots - ring") {
    ArtifactSlotView(
        slots: [
            ArtifactInstance(type: .frictionlessGear, quality: .good),
            ArtifactInstance(type: .perfectLens, quality: .rare),
            nil,
        ],
        size: .small
    )
    .frame(width: 140, height: 140)
}
