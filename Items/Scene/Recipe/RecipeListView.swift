//Created by Alexander Skorulis on 12/2/2026.

import ASKCoordinator
import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct RecipeListView {
    @State var viewModel: RecipeListViewModel
}

// MARK: - Rendering

extension RecipeListView: View {

    var body: some View {
        VStack {
            titleBar
            content
        }
        .overlay(alignment: .bottomTrailing) {
            fab
        }
        .sheet(item: $viewModel.editingRecipe) { recipe in
            ItemPicker(
                predicate: {
                    !recipe.items.contains($0) && viewModel.warehouse.hasDiscovered($0)
                },
                onSelect: { item in
                    viewModel.addItem(recipe: recipe, item: item)
                    viewModel.editingRecipe = nil
                }
            )
        }
    }
    
    private var content: some View {
        List {
            ForEach(viewModel.recipes) { recipe in
                RecipeCell(recipe: recipe, warehouse: viewModel.warehouse) {
                    viewModel.addItem(to: recipe)
                }
                .listRowSeparator(.hidden)
            }
            .onDelete { indexSet in
                viewModel.delete(indexSet: indexSet)
            }
            .onMove { indices, newOffset in
                viewModel.recipes.move(fromOffsets: indices, toOffset: newOffset)
            }
        }
        .listStyle(.plain)
    }
    
    private var titleBar: some View {
        TitleBar(
            title: "Recipes",
            backAction: { viewModel.coordinator?.pop() }
        )
    }

    private var fab: some View {
        Button(action: viewModel.addRecipe) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(Color.accentColor, in: Circle())
                .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .padding(24)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    RecipeListView(viewModel: assembler.resolver.recipeListViewModel())
}

