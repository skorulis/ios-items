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
    @State var golemsCoordinator = Coordinator(root: MainPath.golems)
    @State var warehouseCoordinator = Coordinator(root: MainPath.warehouse)
    @State var tab5Coordinator = Coordinator(root: MainPath.encyclopediaEntry(.root))
    @State private var selectedTab: Int = 0

    var model: Model { viewModel.model }
}

// MARK: - Inner Types

extension ContentView {
    struct Model {
        var showingWarehouse: Bool = false
        var showingEncyclopedia: Bool = false
        var showingGolems: Bool = false
        var notifications: Notifications = Notifications()
    }
}

// MARK: - Rendering

extension ContentView: View {

    var body: some View {
        tabs
        .onAppear { viewModel.onAppear() }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                viewModel.onAppear()
            } else if newPhase == .background {
                viewModel.recordBackgrounded()
            }
        }
    }

    private var tabs: some View {
        TabView(selection: $selectedTab) {
            creationTab

            if viewModel.model.showingWarehouse {
                warehouseTab
            }
            if viewModel.model.showingGolems {
                golemsTab
            }

            if viewModel.model.showingEncyclopedia {
                encyclopediaTab
            }

#if DEBUG
            debugTab
#endif

        }
    }

    private var creationTab: some View {
        CoordinatorView(coordinator: creationCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Portal", systemImage: "camera.aperture")
            }
            .tag(0)
    }

    private var golemsTab: some View {
        CoordinatorView(coordinator: golemsCoordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Golems", systemImage: "gearshape.2")
            }
            .tag(2)
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

    private var encyclopediaTab: some View {
        CoordinatorView(coordinator: tab5Coordinator)
            .withRenderers(resolver: resolver!)
            .tabItem {
                Label("Encyclopedia", systemImage: "books.vertical")
            }
            .tag(4)
            .badge(model.notifications.achievementsNewCount > 0 ? "\(model.notifications.achievementsNewCount)" : nil)
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
