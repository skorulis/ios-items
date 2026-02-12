//Created by Alexander Skorulis on 12/2/2026.

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
        EmptyView()
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    RecipeListView(viewModel: assembler.resolver.recipeListViewModel())
}

