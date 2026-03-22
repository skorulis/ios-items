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
    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

    enum Segment: String, CaseIterable {
        case purchased = "Purchased"
        case available = "Available"
    }
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
            backAction: {
                if let dismissCircularReveal {
                    dismissCircularReveal()
                } else {
                    viewModel.pop()
                }
            },
            leadingStyle: .close
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 12) {
            Picker("Mode", selection: $viewModel.segment) {
                ForEach(Segment.allCases, id: \.self) { segment in
                    Text(segment.rawValue).tag(segment)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)

            switch viewModel.segment {
            case .purchased:
                purchasedLocationsList
            case .available:
                availableLocationsList
            }
        }
    }

    private var purchasedLocations: [MapLocation] {
        viewModel.allLocations.filter { viewModel.isUnlocked($0) }
    }

    private var availableLocations: [MapLocation] {
        viewModel.allLocations.filter { !viewModel.isUnlocked($0) }
    }

    private var purchasedLocationsList: some View {
        LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(purchasedLocations, id: \.self) { location in
                purchasedLocationCell(for: location)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var availableLocationsList: some View {
        LazyVStack(alignment: .leading, spacing: 4) {
            ForEach(availableLocations, id: \.self) { location in
                availableLocationCell(for: location)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func purchasedLocationCell(for location: MapLocation) -> some View {
        let selected = viewModel.isSelected(location)
        let details = location.details

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                location.icon
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .center)

                Text(location.name)
                    .font(.appTitle)

                if selected {
                    Text("Selected")
                        .font(.appCaption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.accentColor.opacity(0.15), in: Capsule())
                }
                Spacer()
                Button {
                    viewModel.showBonuses(for: location)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }

            Text(details.description)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            Button {
                viewModel.select(location)
            } label: {
                Text(selected ? "Current Location" : "Set as Current")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(selected)
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color.gray.opacity(0.05), in: RoundedRectangle(cornerRadius: 8))
    }

    private func availableLocationCell(for location: MapLocation) -> some View {
        let details = location.details

        return VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 10) {
                location.icon
                    .font(.title2)
                    .foregroundStyle(.secondary)
                    .frame(width: 28, alignment: .center)

                Text(location.name)
                    .font(.appTitle)
                Spacer()
                Button {
                    viewModel.showBonuses(for: location)
                } label: {
                    Image(systemName: "info.circle")
                }
                .buttonStyle(.borderless)
            }

            Text(details.description)
                .font(.appCaption)
                .foregroundStyle(.secondary)

            if !details.cost.isEmpty {
                UpgradeCostRow(
                    cost: details.cost,
                    itemQuantity: { viewModel.warehouse.quantity($0) }
                )
            }

            Button {
                viewModel.purchase(location)
            } label: {
                Text("Unlock")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canAfford(location))
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
