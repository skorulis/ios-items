//Created by Alexander Skorulis on 12/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct RecipeCell {
    let recipe: Recipe
    let warehouse: Warehouse
    let addPressed: () -> Void
}

// MARK: - Rendering

extension RecipeCell: View {
    
    var body: some View {
        HStack {
            ForEach(recipe.items) { item in
                itemCell(item: item)
            }
            
            addButton
            
            Spacer()
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor, lineWidth: 2)
        )
    }
    
    private func itemCell(item: BaseItem) -> some View {
        let borderColor: Color = warehouse.quantity(item) > 0 ? .green: .gray
        return ItemView(item: item)
            .padding(4)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
    
    private var addButton: some View {
        Button(action: addPressed) {
            Image(systemName: "plus")
                .font(.title2.weight(.semibold))
                .foregroundStyle(.gray)
                .frame(width: 48, height: 48)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, lineWidth: 1)
                )
        }
    }
    
    private var borderColor: Color {
        let valid = recipe.items.allSatisfy { item in
            return warehouse.quantity(item) > 0
        }
        
        return valid ? .green : .gray
    }
}

// MARK: - Previews

#Preview {
    VStack {
        // Empty Recipe
        RecipeCell(
            recipe: .init(items: []),
            warehouse: .init(),
            addPressed: {},
        )
        .padding(8)
        
        RecipeCell(
            recipe: .init(items: [.apple]),
            warehouse: .init(),
            addPressed: {}
        )
        .padding(8)
        
        RecipeCell(
            recipe: .init(items: [.toaster, .bowlingBall]),
            warehouse: .init(),
            addPressed: {}
        )
        .padding(8)
        
    }
    
}

