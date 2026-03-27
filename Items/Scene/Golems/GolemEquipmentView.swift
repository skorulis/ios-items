// Created by Alexander Skorulis on 27/3/2026.

import Knit
import Models
import SwiftUI

/// Card overlay to assign cosmetic equipment to a golem; items move between warehouse and the golem loadout.
@MainActor
struct GolemEquipmentView: View {

    let slotIndex: Int
    @State var viewModel: GolemsViewModel

    @State private var pickingSlot: EquipmentSlot?
    @Environment(\.dismissCustomOverlay) private var dismiss

    private static let slotSize: CGFloat = 56
    private static let slotStrokeWidth: CGFloat = 2
    private static let figureHeight: CGFloat = 300

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center) {
                Text("Golem \(slotIndex + 1) — Equipment")
                    .font(.appTitle)
                Spacer(minLength: 0)
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(CapsuleButtonStyle())
            }
            .padding(.horizontal, 16)

            humanoidSection

            if let pickingSlot {
                pickerSection(for: pickingSlot)
            }
        }
        .padding(.vertical, 16)
    }

    private var humanoidSection: some View {
        ZStack {
            GeometryReader { geo in
                let size = geo.size
                ZStack(alignment: .topLeading) {
                    Image(systemName: "figure.stand")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundStyle(.secondary.opacity(0.4))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.horizontal, 36)
                        .accessibilityHidden(true)

                    ForEach(EquipmentSlot.allCases, id: \.self) { slot in
                        slotButton(slot: slot)
                            .position(anchor(for: slot, in: size))
                    }
                }
            }
            .frame(height: Self.figureHeight)
        }
        .padding(.horizontal, 16)
    }

    private func slotButton(slot: EquipmentSlot) -> some View {
        let equipped = viewModel.golemEquipmentLoadout(slotIndex: slotIndex)[slot]
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                if pickingSlot == slot {
                    pickingSlot = nil
                } else {
                    pickingSlot = slot
                }
            }
        } label: {
            slotSquare {
                if let equipped {
                    AvatarView(
                        text: equipped.displayName,
                        icon: equipped.image,
                        border: equipped.quality.color,
                        size: .small,
                    )
                } else {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(slot.displayTitle) equipment slot")
        .accessibilityValue(equipped?.displayName ?? "Empty")
    }

    private func pickerSection(for slot: EquipmentSlot) -> some View {
        let equipped = viewModel.golemEquipmentLoadout(slotIndex: slotIndex)[slot]
        let candidates = viewModel.warehouseEquipmentMatching(slot: slot)

        return VStack(alignment: .leading, spacing: 10) {
            Text(slot.displayTitle)
                .font(.appSubheadline.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 16)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    if let equipped {
                        Button {
                            viewModel.unequipGolem(slotIndex: slotIndex, slot: slot)
                            pickingSlot = nil
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(
                                    text: equipped.displayName,
                                    icon: equipped.image,
                                    border: equipped.quality.color,
                                    size: .medium,
                                )
                                Text("Remove from golem")
                                    .font(.appSubheadline.weight(.semibold))
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }

                    if candidates.isEmpty, equipped == nil {
                        Text("No compatible gear in the warehouse.")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                    }

                    ForEach(candidates) { instance in
                        Button {
                            viewModel.equipGolem(slotIndex: slotIndex, instance: instance, to: slot)
                            pickingSlot = nil
                        } label: {
                            HStack(spacing: 12) {
                                AvatarView(
                                    text: instance.displayName,
                                    icon: instance.image,
                                    border: instance.quality.color,
                                    size: .medium,
                                )
                                Text(instance.fullName)
                                    .font(.appSubheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 280)
        }
    }

    private func slotSquare(@ViewBuilder content: () -> some View) -> some View {
        ZStack {
            Color(.systemBackground)
            content()
        }
        .frame(width: Self.slotSize, height: Self.slotSize)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.55), lineWidth: Self.slotStrokeWidth)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func anchor(for slot: EquipmentSlot, in size: CGSize) -> CGPoint {
        let half = Self.slotSize / 2
        switch slot {
        case .head:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.13 + half * 0.2)
        case .body:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.42)
        case .mainHand:
            return CGPoint(x: size.width * 0.78, y: size.height * 0.44)
        case .offHand:
            return CGPoint(x: size.width * 0.22, y: size.height * 0.44)
        case .feet:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.86)
        }
    }
}

private extension EquipmentSlot {

    var displayTitle: String {
        switch self {
        case .head: return "Head"
        case .body: return "Body"
        case .mainHand: return "Main hand"
        case .offHand: return "Off hand"
        case .feet: return "Feet"
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemEquipmentView(
        slotIndex: 0,
        viewModel: assembler.resolver.golemsViewModel(),
    )
}
