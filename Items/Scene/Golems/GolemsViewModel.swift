import ASKCoordinator
import Combine
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class GolemsViewModel: CoordinatorViewModel {

    weak var coordinator: ASKCoordinator.Coordinator?

    enum Segment: String, CaseIterable {
        case construction = "Construction"
        case missions = "Missions"
    }

    var segment: Segment = .construction
    var warehouse: Warehouse = Warehouse()
    var golemInventory: GolemInventory = GolemInventory()

    private let mainStore: MainStore
    private let golemService: GolemService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, golemService: GolemService) {
        self.mainStore = mainStore
        self.golemService = golemService
        self.warehouse = mainStore.warehouse
        self.golemInventory = mainStore.golemInventory
        mainStore.$warehouse.sink { [weak self] in
            self?.warehouse = $0
        }
        .store(in: &cancellables)
        mainStore.$golemInventory.sink { [weak self] in
            self?.golemInventory = $0
        }
        .store(in: &cancellables)
    }

    func onAppear() {}
}

extension GolemsViewModel {

    var allGolemTypes: [GolemType] {
        GolemType.allCases.sorted { $0.name < $1.name }
    }

    func owned(_ type: GolemType) -> Int {
        golemInventory.owned(type)
    }

    func canPurchase(_ type: GolemType) -> Bool {
        golemService.canPurchase(type)
    }

    func purchase(_ type: GolemType) {
        golemService.purchase(type)
    }

    func showGolemInfo(_ type: GolemType) {
        coordinator?.custom(overlay: .card, MainPath.dialog(type.detailedExplanation))
    }
}
