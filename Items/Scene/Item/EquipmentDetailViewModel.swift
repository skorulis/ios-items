import ASKCoordinator
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable
final class EquipmentDetailViewModel: CoordinatorViewModel {
    weak var coordinator: ASKCoordinator.Coordinator?

    let equipment: EquipmentInstance

    private let warehouseService: WarehouseService

    @Resolvable<BaseResolver>
    init(
        @Argument equipment: EquipmentInstance,
        warehouseService: WarehouseService
    ) {
        self.equipment = equipment
        self.warehouseService = warehouseService
    }
}

extension EquipmentDetailViewModel {
    func trash() {
        warehouseService.remove(equipment: equipment)
        // TODO: Fix pop issue
        coordinator?.pop()
    }
}
