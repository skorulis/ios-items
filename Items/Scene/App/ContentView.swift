//  Created by Alexander Skorulis on 10/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ContentView: View {
    
    @Environment(\.resolver) private var resolver
    @State var viewModel: ContentViewModel
    @State var creationCoordinator = Coordinator(root: MainPath.creation)
    @State var warehouseCoordinator = Coordinator(root: MainPath.warehouse)
    @State var researchCoordinator = Coordinator(root: MainPath.research)
    @State var achievementsCoordinator = Coordinator(root: MainPath.achievements)
    
    var body: some View {
        TabView {
            creationTab
            warehouseTab
            
            if viewModel.showingAchievements {
                achievementsTab
            }
            
            if viewModel.showingResearch {
                researchTab
            }
        }
        
    }
    
    private var creationTab: some View {
        CoordinatorView(coordinator: creationCoordinator)
            .with(renderer: resolver!.mainPathRenderer())
            .tabItem {
                Label("Creation", systemImage: "hammer")
            }
            .tag(0)
    }
    
    private var warehouseTab: some View {
        CoordinatorView(coordinator: warehouseCoordinator)
            .with(renderer: resolver!.mainPathRenderer())
            .with(overlay: .card) { view in
                AnyView(CardPathWrapper { view })
            }
            .tabItem {
                Label("Warehouse", systemImage: "shippingbox")
            }
            .tag(1)
    }
    
    private var achievementsTab: some View {
        CoordinatorView(coordinator: achievementsCoordinator)
            .with(renderer: resolver!.mainPathRenderer())
            .with(overlay: .card) { view in
                AnyView(CardPathWrapper { view })
            }
            .tabItem {
                Label("Achievements", systemImage: "fireworks")
            }
            .tag(2)
    }
    
    private var researchTab: some View {
        CoordinatorView(coordinator: researchCoordinator)
            .with(renderer: resolver!.mainPathRenderer())
            .tabItem {
                Label("Research", systemImage: "flask.fill")
            }
            .tag(3)
    }
    
}

#Preview {
    let assembler = ItemsAssembly.testing()
    ContentView(viewModel: assembler.resolver.contentViewModel())
        .environment(\.resolver, assembler.resolver)
}

