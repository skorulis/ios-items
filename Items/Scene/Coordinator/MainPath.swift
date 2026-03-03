//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Foundation
import Knit
import SwiftUI

enum MainPath: CoordinatorPath {
    
    // Root content
    case content
    
    case creation
    case warehouse
    case recipeList
    case research
    case achievements
    case encyclopediaEntry(EncyclopediaEntry)
    
    case itemDetails(BaseItem)
    case artifactDetails(ArtifactInstance)
    case achievementDetails(Achievement)
    case recipeDetail(Recipe)
    
    // Present a block of text
    case dialog(String)
    
    // Toast at the bottom of the screen
    case toast(String)
    
    public var id: String {
        String(describing: self)
    }
}

struct MainPathRenderer: CoordinatorPathRenderer {
    
    let resolver: BaseResolver
    
    @ViewBuilder
    func render(path: MainPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .content:
            ContentView(viewModel: resolver.contentViewModel())
                .environment(\.resolver, resolver)
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
        case let .encyclopediaEntry(entry):
            EncyclopediaView(
                viewModel: coordinator.apply(resolver.encyclopediaViewModel(entry: entry))
            )
        case let .itemDetails(item):
            ItemDetailsView(viewModel: resolver.itemDetailsViewModel(item: item))
        case let .artifactDetails(instance):
            ArtifactDetailView(viewModel: resolver.artifactDetailViewModel(artifact: instance))
        case let .achievementDetails(achievement):
            AchievementDetailsView(viewModel: resolver.achievementDetailsViewModel(achievement: achievement))
        case let .recipeDetail(recipe):
            RecipeDetailView(viewModel: resolver.recipeDetailViewModel(recipe: recipe))
        case let .dialog(text):
            Text(text)
                .padding(16)
        case let .toast(text):
            Text(text)
                .padding(16)
        }
    }
}
