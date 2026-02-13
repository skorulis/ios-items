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
            Button("Create an item") {
                viewModel.make()
            }
            .buttonStyle(CapsuleButtonStyle())
        }
        .padding()
    }
    
    private var topBar: some View {
        HStack {
            Spacer()
            Button("Recipes") {
                viewModel.make()
            }
            .buttonStyle(CapsuleButtonStyle())
            .opacity(viewModel.recipesAvailable ? 1 : 0)
        }
    }
    
    private var itemContainer: some View {
        ZStack {
            AnimatedBlobView(color: .blue, size: 220, speed: 0.7, points: 9, jitter: 0.26)
                .padding(.bottom, 16)
            
            if let item = viewModel.createdItem {
                ItemView(item: item)
            }
        }
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    CreationView(viewModel: assembler.resolver.creationViewModel())
}
