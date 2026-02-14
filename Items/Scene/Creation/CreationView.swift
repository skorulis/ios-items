//Created by Alexander Skorulis on 11/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct CreationView {
    @State var viewModel: CreationViewModel
}

// MARK: - Rendering

extension CreationView: View {
    
    var body: some View {
        VStack {
            topBar
            Spacer()
            itemContainer
            Spacer()
            makeButton
        }
        .padding()
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            Button("Recipes") {
                viewModel.showRecipes()
            }
            .buttonStyle(CapsuleButtonStyle())
            .opacity(viewModel.recipesAvailable ? 1 : 0)
        }
    }
    
    private var itemContainer: some View {
        ZStack {
            AnimatedBlobView(color: .blue, size: 220, speed: 0.7, points: 9, jitter: 0.26)
                .padding(.bottom, 16)
            
            if viewModel.isCreating {
                ProgressView()
            } else if let item = viewModel.createdItem {
                ItemView(item: item)
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
                if viewModel.isCreating {
                    ProgressView()
                }
                Text("Create an item")
                    .opacity(viewModel.isCreating ? 0 : 1)
            }
        }
        .buttonStyle(CapsuleButtonStyle())
        .disabled(viewModel.isCreating)
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    CreationView(viewModel: assembler.resolver.creationViewModel())
}
