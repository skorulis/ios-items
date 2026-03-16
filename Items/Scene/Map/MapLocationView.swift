// Created by Cursor on 16/3/2026.
//
// List-based UI for unlocking and selecting map locations.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct MapLocationView {
    @State var viewModel: MapLocationViewModel
}

// MARK: - Rendering

extension MapLocationView: View {

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Locations",
            backAction: { viewModel.pop() },
            leadingStyle: .back
        )
    }

    private var content: some View {
        ForEach(viewModel.allLocations, id: \.self) { location in
            row(for: location)
        }
    }

    private func row(for location: MapLocation) -> some View {
        let unlocked = viewModel.isUnlocked(location)
        let selected = viewModel.isSelected(location)
        let details = location.details

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(location.name)
                    .font(.headline)

                if selected {
                    Text("Selected")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                } else if unlocked {
                    Text("Unlocked")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.15), in: Capsule())
                } else {
                    Text("Locked")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.gray.opacity(0.15), in: Capsule())
                }
            }

            Text(details.description)
                .font(.caption)
                .foregroundStyle(.secondary)

            if !details.cost.isEmpty {
                UpgradeCostRow(
                    cost: details.cost,
                    itemQuantity: { viewModel.warehouse.quantity($0) }
                )
            }

            HStack {
                if unlocked {
                    Button {
                        viewModel.select(location)
                    } label: {
                        Text(selected ? "Current Location" : "Set as Current")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(selected)
                } else {
                    Button {
                        viewModel.purchase(location)
                    } label: {
                        Text("Unlock")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!viewModel.canAfford(location))
                }
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    MapLocationView(viewModel: assembler.resolver.mapLocationViewModel())
}

