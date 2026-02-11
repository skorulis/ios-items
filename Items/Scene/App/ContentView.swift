//  Created by Alexander Skorulis on 10/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ContentView: View {
    
    @Environment(\.resolver) private var resolver
    @State var viewModel: ContentViewModel
    @State var creationCoordinator = Coordinator(root: MainPath.creation)
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            creationTab

            // Floating Action Button for Inventory
            Button(action: {
                viewModel.showingWarehouse = true
            }) {
                Image(systemName: "shippingbox")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(
                        Circle()
                            .fill(Color.accentColor)
                            .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                    )
            }
            .padding(.trailing, 24)
            .padding(.bottom, 24)
            .accessibilityLabel("Inventory")
            .accessibilityAddTraits(.isButton)
        }
        .sheet(isPresented: $viewModel.showingWarehouse) {
            WarehouseView(viewModel: resolver!.warehouseViewModel())
        }
    }
    
    private var creationTab: some View {
        TabView {
            CoordinatorView(coordinator: creationCoordinator)
                .with(renderer: resolver!.mainPathRenderer())
                .tabItem {
                    Label("Creation", systemImage: "hammer")
                }
                .tag(0)
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    ContentView(viewModel: assembler.resolver.contentViewModel())
        .environment(\.resolver, assembler.resolver)
}

