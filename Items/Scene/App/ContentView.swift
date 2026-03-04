//  Created by Alexander Skorulis on 10/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

struct ContentView: View {
    
    @Environment(\.resolver) private var resolver
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel: ContentViewModel
    @State var creationCoordinator = Coordinator(root: MainPath.creation)
    @State var warehouseCoordinator = Coordinator(root: MainPath.warehouse)
    @State var researchCoordinator = Coordinator(root: MainPath.research)
    @State var achievementsCoordinator = Coordinator(root: MainPath.achievements)
    @State var tab5Coordinator = Coordinator(root: MainPath.encyclopediaEntry(.root))
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            creationTab
            warehouseTab
            
            if viewModel.showingResearch {
                researchTab
            }
            
            if viewModel.showingAchievements {
                achievementsTab
            }
            
            encyclopediaTab
        }
        .onAppear { viewModel.resumeResearchProgressIfNeeded() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.resumeResearchProgressIfNeeded()
            }
        }
    }
    
    private var creationTab: some View {
        CoordinatorView(coordinator: creationCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Creation", systemImage: "hammer")
            }
            .tag(0)
    }
    
    private var warehouseTab: some View {
        CoordinatorView(coordinator: warehouseCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Warehouse", systemImage: "shippingbox")
            }
            .tag(1)
            .badge(viewModel.warehouseNewCount > 0 ? "\(viewModel.warehouseNewCount)" : nil)
    }
    
    private var achievementsTab: some View {
        CoordinatorView(coordinator: achievementsCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Achievements", systemImage: "fireworks")
            }
            .tag(2)
            .badge(viewModel.achievementsNewCount > 0 ? "\(viewModel.achievementsNewCount)" : nil)
    }
    
    private var researchTab: some View {
        CoordinatorView(coordinator: researchCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Research", systemImage: "flask.fill")
            }
            .tag(3)
            .badge(viewModel.hasNewResearchLevel ? "1" : nil)
    }
    
    private var encyclopediaTab: some View {
        CoordinatorView(coordinator: tab5Coordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Encyclopedia", systemImage: "books.vertical")
            }
            .tag(4)
    }
    
}

#Preview {
    let assembler = ItemsAssembly.testing()
    ContentView(viewModel: assembler.resolver.contentViewModel())
        .environment(\.resolver, assembler.resolver)
}

