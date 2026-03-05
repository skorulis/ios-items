//  Created by Alexander Skorulis on 10/2/2026.

import ASKCoordinator
import Knit
import SwiftUI

// MARK: - Memory footprint

struct ContentView {
    @Environment(\.resolver) private var resolver
    @Environment(\.scenePhase) private var scenePhase
    @State var viewModel: ContentViewModel
    @State var creationCoordinator = Coordinator(root: MainPath.creation)
    @State var warehouseCoordinator = Coordinator(root: MainPath.warehouse)
    @State var achievementsCoordinator = Coordinator(root: MainPath.achievements)
    @State var tab5Coordinator = Coordinator(root: MainPath.encyclopediaEntry(.root))
    @State private var selectedTab: Int = 0
    
    var model: Model { viewModel.model }
}

// MARK: - Inner Types

extension ContentView {
    struct Model {
        var showingWarehouse: Bool = false
        var showingAchievements: Bool = false
        var showingEncyclopedia: Bool = false
        var notifications: Notifications = Notifications()

        var tabBarHidden: Bool {
            !showingWarehouse && !showingAchievements && !showingEncyclopedia
        }
    }
}

// MARK: - Rendering

extension ContentView: View {
    
    var body: some View {
        TabView(selection: $selectedTab) {
            creationTab
                .toolbar(model.tabBarHidden ? .hidden : .visible, for: .tabBar)
                .animation(.default, value: model.tabBarHidden)
            
            if viewModel.model.showingWarehouse {
                warehouseTab
            }

            if viewModel.model.showingAchievements {
                achievementsTab
            }
            
            if viewModel.model.showingEncyclopedia {
                encyclopediaTab
            }

#if DEBUG
            debugTab
#endif
            
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
            .badge(model.notifications.warehouseNewCount > 0 ? "\(model.notifications.warehouseNewCount)" : nil)
    }
    
    private var achievementsTab: some View {
        CoordinatorView(coordinator: achievementsCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Achievements", systemImage: "fireworks")
            }
            .tag(2)
            .badge(model.notifications.achievementsNewCount > 0 ? "\(model.notifications.achievementsNewCount)" : nil)
    }

    private var encyclopediaTab: some View {
        CoordinatorView(coordinator: tab5Coordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Encyclopedia", systemImage: "books.vertical")
            }
            .tag(4)
    }

#if DEBUG
    private var debugTab: some View {
        DebugView(viewModel: resolver!.debugViewModel())
            .tabItem {
                Label("Debug", systemImage: "ladybug")
            }
            .tag(5)
    }
#endif
    
}

#Preview {
    let assembler = ItemsAssembly.testing()
    ContentView(viewModel: assembler.resolver.contentViewModel())
        .environment(\.resolver, assembler.resolver)
}

