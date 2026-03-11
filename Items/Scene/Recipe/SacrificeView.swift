//Created by Alexander Skorulis on 11/3/2026.

import ASKCoordinator
import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct SacrificeView {
    @State var viewModel: SacrificeViewModel

    /// Snapshot of everything needed to render the screen (updated by the view model).
    struct Model {
        var sacrificesEnabled: Bool
        var warehouse: Warehouse
        var slotItems: [Int: BaseItem] = [:]
        var consumptionPlan: SacrificePlan = SacrificePlan(slotsByIndex: [:])
    }
}

// MARK: - Rendering

extension SacrificeView: View {

    var body: some View {
        VStack {
            titleBar
            pentagramContent
        }
        .sheet(item: $viewModel.editingSlot) { slot in
            ItemPicker(
                predicate: { item in
                    viewModel.model.warehouse.hasDiscovered(item)
                },
                onSelect: { item in
                    viewModel.assignItem(at: slot.index, item: item)
                }
            )
        }
        .navigationBarHidden(true)
    }

    private var titleBar: some View {
        TitleBar(
            title: "Sacrifices",
            backAction: { viewModel.coordinator?.pop() },
            trailing: {
                Toggle("", isOn: Binding(
                    get: { viewModel.model.sacrificesEnabled },
                    set: { viewModel.setSacrificesEnabled($0) }
                ))
                .labelsHidden()
            }
        )
    }

    private var pentagramContent: some View {
        GeometryReader { geo in
            let rect = CGRect(origin: .zero, size: geo.size)
            let center = PentagramLayout.center(in: rect)
            let radius = PentagramLayout.radius(in: rect)

            ZStack {
                PentagramCircumcircleShape()
                    .stroke(Color.red, lineWidth: 8)
                PentagramShape()
                    .stroke(Color.red, lineWidth: 8)

                ForEach(0..<SacrificeConfig.slotCount, id: \.self) { index in
                    slotView(index: index)
                        .position(PentagramLayout.vertexPoint(index: index, center: center, radius: radius))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding()
    }

    /// Diameter for every slot circle (empty button and ItemView container match).
    private static let slotDiameter: CGFloat = 64
    private static let slotStrokeWidth: CGFloat = 4

    @ViewBuilder
    private func slotView(index: Int) -> some View {
        let model = viewModel.model
        let item = model.slotItems[index]
        let isReady = model.consumptionPlan.isSatisfied(at: index)
        let borderColor: Color = {
            return isReady ? .green : .gray
        }()

        let diameter = Self.slotDiameter
        let innerPadding: CGFloat = 6

        if let item {
            ZStack(alignment: .topTrailing) {
                // Item clipped to circle; same outer size as empty slot
                ZStack {
                    Circle()
                        .fill(Color(.white))
                    ItemView(item: item)
                        .frame(width: diameter - innerPadding * 2, height: diameter - innerPadding * 2)
                        .clipShape(Circle())
                }
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle()
                        .stroke(borderColor, lineWidth: Self.slotStrokeWidth)
                }

                Button(action: { viewModel.clearSlot(index: index) }) {
                    Image(systemName: "minus.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.red)
                }
                .buttonStyle(.borderless)
                .offset(x: 4, y: -4)
            }
            .frame(width: diameter, height: diameter)
        } else {
            Button(action: { viewModel.openPicker(forSlot: index) }) {
                ZStack {
                    Image(systemName: "plus")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.gray)
                }
                .frame(width: diameter, height: diameter)
                .overlay {
                    Circle()
                        .stroke(borderColor, lineWidth: Self.slotStrokeWidth)
                }
            }
            .buttonStyle(.plain)
            .background(Circle().fill(Color(.white)))
        }
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    assembler.resolver.warehouseService().add(item: .apple)
    return SacrificeView(viewModel: assembler.resolver.sacrificeViewModel())
}
