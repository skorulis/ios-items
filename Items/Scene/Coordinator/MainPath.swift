// Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Foundation
import Knit
import Models
import SwiftUI

enum MainPath: CoordinatorPath {

    // Root content
    case content

    case creation
    case warehouse
    case sacrifices
    case research
    case achievements
    case portalUpgrades
    case essenceBreakdown
    case encyclopediaEntry(EncyclopediaEntry)
    case gameStatistics
    case mapLocations

    case itemDetails(BaseItem)
    case artifactDetails(ArtifactInstance)
    case artifactPicker(slot: Int)
    case achievementDetails(Achievement)
    case currentRecipeDetail

    case tradingPost

    // Present a block of text
    case dialog(String)

    // Present a dialog with full DefaultDialogContent model (title + body)
    case fullDialog(DefaultDialogContent.Model)

    // Toast at the bottom of the screen
    case toast(AnyView?, String, UUID)

    public var id: String {
        switch self {
        case let .toast(_, _, toastID):
            return toastID.uuidString
        default:
            return String(describing: self)
        }
    }
}

struct MainPathRenderer: CoordinatorPathRenderer {

    let resolver: BaseResolver

    // swiftlint:disable:next cyclomatic_complexity
    @ViewBuilder func render(path: MainPath, in coordinator: Coordinator) -> some View {
        switch path {
        case .content:
            ContentView(viewModel: resolver.contentViewModel())
                .environment(\.resolver, resolver)
        case .creation:
            CreationView(viewModel: coordinator.apply(resolver.creationViewModel()))
        case .warehouse:
            WarehouseView(viewModel: coordinator.apply(resolver.warehouseViewModel()))
        case .sacrifices:
            SacrificeView(viewModel: coordinator.apply(resolver.sacrificeViewModel()))
        case .research:
            ResearchView(viewModel: coordinator.apply(resolver.researchViewModel()))
        case .achievements:
            AchievementsView(viewModel: coordinator.apply(resolver.achievementsViewModel()))
        case .portalUpgrades:
            PortalUpgradesView(viewModel: coordinator.apply(resolver.portalUpgradesViewModel()))
        case .mapLocations:
            MapLocationView(viewModel: coordinator.apply(resolver.mapLocationViewModel()))
        case .essenceBreakdown:
            EssenceBreakdownView(viewModel: coordinator.apply(resolver.essenceBreakdownViewModel()))
        case let .encyclopediaEntry(entry):
            EncyclopediaView(
                viewModel: coordinator.apply(resolver.encyclopediaViewModel(entry: entry))
            )
        case .gameStatistics:
            GameStatisticsView(viewModel: coordinator.apply(resolver.gameStatisticsViewModel()))
        case let .itemDetails(item):
            ItemDetailsView(viewModel: coordinator.apply(resolver.itemDetailsViewModel(item: item)))
        case let .artifactDetails(instance):
            ArtifactDetailView(viewModel: resolver.artifactDetailViewModel(artifact: instance))
        case let .artifactPicker(slot):
            ArtifactPickerView(viewModel: resolver.artifactPickerViewModel(slot: slot))
        case let .achievementDetails(achievement):
            AchievementDetailsView(viewModel: resolver.achievementDetailsViewModel(achievement: achievement))
        case .currentRecipeDetail:
            RecipeDetailView(viewModel: resolver.currentRecipeDetailViewModel())
        case .tradingPost:
            TradingPostView(viewModel: coordinator.apply(resolver.tradingPostViewModel()))
        case let .dialog(text):
            DefaultDialogContent(model: .init(bodyText: text))
        case let .fullDialog(model):
            DefaultDialogContent(model: model)
        case let .toast(icon, text, _):
            DefaultToastContent(icon: icon, text: text)
        }
    }
}
