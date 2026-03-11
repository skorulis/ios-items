//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor struct CreationView {
    @State var viewModel: CreationViewModel
    @State private var sacrificesButtonFrame: CGRect = .zero

    struct CreationInProgress {
        let id: UUID
        let duration: TimeInterval
        let sacrificedItems: [BaseItem]
        
        var creationColors: [Color] {
            let fromSacrfice = sacrificedItems
                .flatMap { $0.essences }
                .map { $0.color }
            
            if fromSacrfice.isEmpty {
                return Essence.allCases.map { $0.color }
            } else {
               return fromSacrfice
            }
        }
    }

    struct Model {
        var createdItem: MakeItemResult?
        var creationInProgress: CreationInProgress?

        var isCreating: Bool { creationInProgress != nil }

        var warehouse: Warehouse = Warehouse()
        var achievements: Achievements = Achievements()
        
        var recipesAvailable: Bool { achievements.unlocked.contains(.items10) }
        var upgradesAvailable: Bool { achievements.unlocked.contains(.items10) }
        var firstItem: Bool { !achievements.unlocked.contains(.items1) }
        var automationUnlocked: Bool = false
        var sacrificesUnlocked: Bool = false
        var showingResearch: Bool = false
        var researchBadgeCount: Int = 0
        var upgradesBadgeCount: Int = 0
        
        var maxArtifacts: Int = 0
        var artifactSlots: [ArtifactInstance?] {
            warehouse.equippedSlotsContents(upToSlotCount: maxArtifacts)
        }
    }

}

// MARK: - Rendering

extension CreationView: View {
    
    var body: some View {
        ZStack {
            PortalView(
                upgradesButton: viewModel.model.upgradesAvailable
                    ? .init(
                        action: viewModel.showPortalUpgrades,
                        badge: viewModel.model.upgradesBadgeCount,
                        frameBinding: $viewModel.upgradeButtonFrame,
                    )
                    : nil,
                researchButton: viewModel.model.showingResearch
                    ? .init(
                        action: viewModel.showResearch,
                        badge: viewModel.model.researchBadgeCount,
                        frameBinding: $viewModel.researchButtonFrame,
                    )
                    : nil,
                artifactButton: artifactSlotView,
            )
            maybeCreationAnimation
            sacrificeAvatarsOverlay
            itemContainer
            VStack {
                topBar
                Spacer()
                makeButtonRow
            }
            .padding()
            
        }
        .coordinateSpace(name: "creation")
    }
    
    private var artifactSlotView: ArtifactSlotView? {
        guard viewModel.model.artifactSlots.count > 0 else { return nil }
        return ArtifactSlotView(
            slots: viewModel.model.artifactSlots,
            size: .small,
            onSlotPressed: { viewModel.artifactSlotPressed(index: $0) }
        )
    }
    
    private var dimensionalPortalBackground: some View {
        Asset.Creation.dimensionalPortal.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 280, maxHeight: 280)
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            if viewModel.model.sacrificesUnlocked {
                sacficesButton
            }
        }
    }

    private var sacficesButton: some View {
        Button(action: viewModel.showRecipes) {
            HStack {
                Text("Sacrifices")
            }
        }
        .buttonStyle(CapsuleButtonStyle())
        .readFrame(frame: $sacrificesButtonFrame)
    }
    
    @ViewBuilder
    private var maybeCreationAnimation: some View {
        if let creation = viewModel.model.creationInProgress {
            ParticleCanvasView(
                movementDuration: creation.duration,
                colors: creation.creationColors,
            )
            .id(creation.id)
        }
    }

    @ViewBuilder
    private var sacrificeAvatarsOverlay: some View {
        GeometryReader { geo in
            if let creation = viewModel.model.creationInProgress, !creation.sacrificedItems.isEmpty {
                let startPosition = CGPoint(
                    x: sacrificesButtonFrame.maxX - 20,
                    y: sacrificesButtonFrame.midY,
                )
                let endPosition = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                SacrificeAnimationView(
                    items: creation.sacrificedItems,
                    startPosition: startPosition,
                    endPosition: endPosition,
                    duration: creation.duration,
                    animationId: creation.id
                )
            }
        }
        .allowsHitTesting(false)
    }

    @ViewBuilder
    private var itemContainer: some View {
        if let item = viewModel.model.createdItem {
            createdItem(item: item)
        } else {
            EmptyView()
        }
    }
    
    @ViewBuilder
    private func createdItem(item: MakeItemResult) -> some View {
        switch item {
        case let .base(baseItem, count):
            Button(action: { viewModel.showDetails(item: baseItem) }) {
                ItemView(
                    item: baseItem,
                    quantity: count > 1 ? count : nil,
                )
            }
        case let .artifact(instance):
            ArtifactView(artifact: instance)
        }
    }
    
    private var makeButtonRow: some View {
        HStack(spacing: 12) {
            autoCreationButton
            createButton
            
            Button(action: viewModel.showCurrentRecipeDetail) {
                Image(systemName: "info.circle")
                    .font(.title2)
            }
            .buttonStyle(.plain)
        }
    }

    private var autoCreationButton: some View {
        Button {
            viewModel.automateCreation.toggle()
        } label: {
            Image(systemName: "gearshape.arrow.trianglehead.2.clockwise.rotate.90")
                .font(.title2)
                .foregroundStyle(viewModel.automateCreation ? Color.green : Color.primary)
        }
        .buttonStyle(.plain)
        .opacity(viewModel.model.automationUnlocked ? 1 : 0)
    }
    
    private var createButton: some View {
        CreateButtonWithTimerBorder(
            timer: viewModel.model.automationUnlocked && viewModel.automateCreation
                ? viewModel.autoTimerProgress
                : nil,
            action: viewModel.make
        ) {
            ZStack {
                if viewModel.model.isCreating {
                    ProgressView()
                }
                Text(viewModel.model.firstItem ? "Unlock the portal" : "Create an item")
                    .opacity(viewModel.model.isCreating ? 0 : 1)
            }
        }
        .disabled(viewModel.model.isCreating)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    CreationView(viewModel: assembler.resolver.creationViewModel())
}

