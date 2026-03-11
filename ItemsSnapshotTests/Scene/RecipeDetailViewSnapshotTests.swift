// Created by Cursor on 4/3/2026.

@testable import Items
import Models
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct RecipeDetailViewSnapshotTests {
    
    let assembler = ItemsAssembly.testing()
    
    @Test
    func recipeDetail_simple_recipe() {
        let mainStore = assembler.resolver.mainStore()
        mainStore.recipes.sacrificeConfig = .init(
            slots: [0: .apple],
        )
        mainStore.warehouse.add(item: .apple)
        
        let viewModel = assembler.resolver.currentRecipeDetailViewModel()
        let view = RecipeDetailView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
    
    @Test
    func recipeDetail_complex_recipe() {
        let mainStore = assembler.resolver.mainStore()
        
        mainStore.recipes.sacrificeConfig = .init(
            slots: [0: .apple, 1: .gear, 2: .copperFlorin, 3: .silverFlorin],
        )
        
        mainStore.warehouse.add(item: .apple)
        mainStore.warehouse.add(item: .gear)
        mainStore.warehouse.add(item: .copperFlorin)
        mainStore.warehouse.add(item: .silverFlorin)
        
        let viewModel = assembler.resolver.currentRecipeDetailViewModel()
        let view = RecipeDetailView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}

