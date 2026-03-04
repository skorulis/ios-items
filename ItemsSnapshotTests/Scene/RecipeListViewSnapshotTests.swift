// Created by Cursor on 4/3/2026.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct RecipeListViewSnapshotTests {
    
    let assembler = ItemsAssembly.testing()
    
    @Test
    func recipeList_empty_state() {
        let mainStore = assembler.resolver.mainStore()
        mainStore.recipes = []
        
        let viewModel = assembler.resolver.recipeListViewModel()
        let view = RecipeListView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
    
    @Test
    func recipeList_with_recipes() {
        let mainStore = assembler.resolver.mainStore()
        
        // Seed some recipes for display
        let recipe1 = Recipe(items: [.apple])
        let recipe2 = Recipe(items: [.gear, .copperFlorin])
        mainStore.recipes = [recipe1, recipe2]
        
        let viewModel = assembler.resolver.recipeListViewModel()
        let view = RecipeListView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}

