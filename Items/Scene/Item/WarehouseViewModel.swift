//Created by Alexander Skorulis on 11/2/2026.

import ASKCoordinator
import Combine
import Knit
import KnitMacros
import SwiftUI

@Observable final class WarehouseViewModel: CoordinatorViewModel {
    
    var coordinator: Coordinator?
    
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var page: Page = .items
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        warehouse = mainStore.warehouse
        lab = mainStore.lab
        
        mainStore.$warehouse.sink { [unowned self] in
            self.warehouse = $0
        }
        .store(in: &cancellables)
        
        mainStore.$lab.sink { [unowned self] in
            self.lab = $0
        }
        .store(in: &cancellables)
    }
}

// MARK: - Inner Types

extension WarehouseViewModel {
    enum Page {
        case items, artifacts
    }

    enum Strings {
        static let helpText = """
        The Warehouse is your inventory of discovered items and artifacts.
        Items are grouped by quality. Tap an item or artifact to view its details.
        New discoveries are marked until you view them. Items here can be used in sacrifices and other activities.
        """
    }
}

// MARK: - Logic

extension WarehouseViewModel {

    func showInfo() {
        coordinator?.custom(overlay: .card, MainPath.dialog(Strings.helpText))
    }

    func pressed(artifact: ArtifactInstance) {
        coordinator?.custom(overlay: .card, MainPath.artifactDetails(artifact))
    }
    
    func pressed(item: BaseItem) {        
        coordinator?.custom(overlay: .card, MainPath.itemDetails(item))
    }
}
