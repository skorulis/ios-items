import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models

@Observable
final class EquipmentListViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    private let mainStore: MainStore
    private var cancellables: Set<AnyCancellable> = []

    private(set) var warehouse: Warehouse

    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
        self.warehouse = mainStore.warehouse

        mainStore.$warehouse
            .sink { [unowned self] in
                self.warehouse = $0
            }
            .store(in: &cancellables)
    }

    var equipment: [EquipmentInstance] {
        warehouse.equipment
    }

    func showDetails(for instance: EquipmentInstance) {
        coordinator?.custom(overlay: .card, MainPath.equipmentDetails(instance))
    }

    func pop() {
        coordinator?.pop()
    }
}

