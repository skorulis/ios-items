//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Foundation
import Knit
import SwiftUI

enum MainPath: CoordinatorPath {
    
    case creation
    case warehouse
    case recipeList
    case research
    
    case itemDetails(BaseItem)
    
    public var id: String {
        String(describing: self)
    }
}

struct MainPathRenderer: CoordinatorPathRenderer {
    
    let resolver: BaseResolver
    
    @ViewBuilder
    func render(path: MainPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .creation:
            CreationView(viewModel: coordinator.apply(resolver.creationViewModel()))
        case .warehouse:
            WarehouseView(viewModel: coordinator.apply(resolver.warehouseViewModel()))
        case .recipeList:
            RecipeListView(viewModel: coordinator.apply(resolver.recipeListViewModel()))
        case .research:
            ResearchView(viewModel: coordinator.apply(resolver.researchViewModel()))
        case let .itemDetails(item):
            ItemDetailsView(
                item: item,
                level: resolver.mainStore().lab.currentLevel(item: item),
            )
        }
    }
}

extension CustomOverlay.Name {
    // A card in the center of the screen
    static let card = CustomOverlay.Name("card")
}
