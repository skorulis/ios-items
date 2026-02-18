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
    case achievements
    
    case itemDetails(BaseItem)
    case artifactDetails(ArtifactInstance)
    case achievementDetails(Achievement)
    
    // Present a block of text
    case dialog(String)
    
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
        case .achievements:
            AchievementsView(viewModel: coordinator.apply(resolver.achievementsViewModel()))
        case let .itemDetails(item):
            ItemDetailsView(viewModel: resolver.itemDetailsViewModel(item: item))
        case let .artifactDetails(instance):
            ArtifactDetailView(artifact: instance)
        case let .achievementDetails(achievement):
            AchievementDetailsView(achievement: achievement)
        case let .dialog(text):
            Text(text)
                .padding(16)
        }
    }
}
