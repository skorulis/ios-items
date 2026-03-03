// Created by Cursor on 4/3/2026.

@testable import Items
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor
struct RecipeDetailViewSnapshotTests {
    
    let assembler = ItemsAssembly.testing()
    
    @Test
    func recipeDetail_simple_recipe() {
        let recipe = Recipe(items: [.apple])
        let viewModel = assembler.resolver.recipeDetailViewModel(recipe: recipe)
        let view = RecipeDetailView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
    
    @Test
    func recipeDetail_complex_recipe() {
        let recipe = Recipe(items: [.apple, .gear, .copperFlorin, .silverFlorin])
        let viewModel = assembler.resolver.recipeDetailViewModel(recipe: recipe)
        let view = RecipeDetailView(viewModel: viewModel)
        
        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }
}

