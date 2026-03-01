//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct CreationView {
    @State var viewModel: CreationViewModel

    struct CreationInProgress {
        let id: UUID
        let duration: TimeInterval
    }

    struct Model {
        var createdItem: ItemGeneratorService.Result?
        var creationInProgress: CreationInProgress?

        var isCreating: Bool { creationInProgress != nil }

        var warehouse: Warehouse = Warehouse()
        var achievements: Set<Achievement> = []
        var recipes: [Recipe] = []
        
        var recipesAvailable: Bool { achievements.contains(.items10) }
        
        var currentSacrifice: Recipe? {
            return recipes.first { recipe in
                recipe.items.count > 0 &&
                recipe.items.allSatisfy { warehouse.quantity($0) > 0 }
            }
        }
    }

}

// MARK: - Rendering

extension CreationView: View {
    
    var body: some View {
        ZStack {
            maybeCreationAnimation
            itemContainer
            VStack {
                topBar
                Spacer()
                autoToggle
                makeButton
            }
            .padding()
        }
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            if viewModel.model.recipesAvailable {
                sacficesButton
            }
        }
    }
    
    private var sacficesButton: some View {
        Button(action: viewModel.showRecipes) {
            VStack {
                Text("Sacrifices")
                if let recipe = viewModel.model.currentSacrifice {
                    HStack {
                        ForEach(recipe.items) { item in
                            AvatarView(
                                text: item.name,
                                image: item.image,
                                border: item.quality.color,
                                size: .small,
                            )
                        }
                    }
                }
            }
        }
        .buttonStyle(CapsuleButtonStyle())
        .opacity(viewModel.model.recipesAvailable ? 1 : 0)
    }
    
    @ViewBuilder
    private var maybeCreationAnimation: some View {
        if let creation = viewModel.model.creationInProgress {
            ParticleCanvasView(movementDuration: creation.duration)
                .id(creation.id)
        }
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
    private func createdItem(item: ItemGeneratorService.Result) -> some View {
        switch item {
        case let .base(baseItem, count):
            Button(action: { viewModel.showDetails(item: baseItem) }) {
                ItemView(
                    item: baseItem,
                    quantity: count > 1 ? count : nil,
                )
            }
        case let .artifact:
            Text("TODO")
        }
        
    }
    
    private var autoToggle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $viewModel.automateCreation) {
                HStack {
                    Text("Auto")
                    if viewModel.automateCreation, let timer = viewModel.autoTimerProgress {
                        TimerProgressView(model: timer)
                            .frame(width: 32, height: 32)
                    }
                }
            }
        }
    }
    
    private var makeButton: some View {
        Button(action: {
            Task {
                await viewModel.make()
            }
        }) {
            ZStack {
                if viewModel.model.isCreating {
                    ProgressView()
                }
                Text("Create an item")
                    .opacity(viewModel.model.isCreating ? 0 : 1)
            }
        }
        .buttonStyle(CapsuleButtonStyle())
        .disabled(viewModel.model.isCreating)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    CreationView(viewModel: assembler.resolver.creationViewModel())
}
