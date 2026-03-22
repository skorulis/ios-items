import ASKCoordinator
import Combine
import Foundation
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
    var golems: Golems = Golems()
    var mapLocations: MapLocations = MapLocations()
    /// Bumped every second so running mission progress updates without mutating store.
    private(set) var now: Date = Date()

    private let mainStore: MainStore
    private let golemService: GolemService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, golemService: GolemService) {
        self.mainStore = mainStore
        self.golemService = golemService
        self.warehouse = mainStore.warehouse
        self.golems = mainStore.golems
        self.mapLocations = mainStore.mapLocations
        mainStore.$warehouse.sink { [weak self] in
            self?.warehouse = $0
        }
        .store(in: &cancellables)
        mainStore.$golems.sink { [weak self] in
            self?.golems = $0
        }
        .store(in: &cancellables)
        mainStore.$mapLocations.sink { [weak self] in
            self?.mapLocations = $0
        }
        .store(in: &cancellables)

        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                guard let self else { return }
                self.now = date
                self.golemService.finalizeCompletedSlots(at: date)
            }
            .store(in: &cancellables)
    }

    func onAppear() {
        golemService.finalizeCompletedSlots(at: Date())
    }
}

extension GolemsViewModel {

    var allGolemTypes: [GolemType] {
        GolemType.allCases.sorted { $0.name < $1.name }
    }

    var missionSlotIndices: Range<Int> {
        0..<Golems.slotCount
    }

    func missionSlot(at index: Int) -> GolemMissionSlot {
        golems.slots[index] ?? .empty()
    }

    func owned(_ type: GolemType) -> Int {
        golems.owned(type)
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

    func openMissionGolemPicker(slotIndex: Int) {
        coordinator?.custom(overlay: .card, MainPath.golemMissionGolemPicker(slotIndex: slotIndex))
    }

    func openMissionLocationPicker(slotIndex: Int) {
        coordinator?.custom(overlay: .card, MainPath.golemMissionLocationPicker(slotIndex: slotIndex))
    }

    func selectableGolemTypes(for slotIndex: Int) -> [GolemType] {
        let reserved = missionSlot(at: slotIndex).golemType
        return GolemType.allCases.filter { type in
            owned(type) > 0 || type == reserved
        }
        .sorted { $0.name < $1.name }
    }

    func unlockedMissionLocations() -> [MapLocation] {
        golemService.unlockedMissionLocations(from: mapLocations)
    }

    func missionProgress(slotIndex: Int) -> Double {
        golemService.missionProgress(slotIndex: slotIndex, at: now)
    }

    func canStartMission(slotIndex: Int) -> Bool {
        let slot = missionSlot(at: slotIndex)
        guard slot.phase == .setup,
              slot.golemType != nil,
              let location = slot.location
        else { return false }
        return mapLocations.isUnlocked(location)
    }

    func setReservedGolem(slotIndex: Int, newType: GolemType?) {
        golemService.setReservedGolem(slotIndex: slotIndex, newType: newType)
    }

    func setMissionLocation(slotIndex: Int, location: MapLocation?) {
        golemService.setMissionLocation(slotIndex: slotIndex, location: location)
    }

    func startMission(slotIndex: Int) {
        golemService.startMission(slotIndex: slotIndex)
    }

    func cancelMission(slotIndex: Int) {
        golemService.cancelMission(slotIndex: slotIndex)
    }
}
