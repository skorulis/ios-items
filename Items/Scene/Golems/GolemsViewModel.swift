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
    private(set) var portalUpgrades: PortalUpgrades = PortalUpgrades()

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
        self.portalUpgrades = mainStore.portalUpgrades
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
        mainStore.$portalUpgrades.sink { [weak self] in
            self?.portalUpgrades = $0
        }
        .store(in: &cancellables)
    }
}

extension GolemsViewModel {

    var allGolemTypes: [GolemType] {
        GolemType.allCases.sorted { $0.name < $1.name }
    }

    var missionSlotCount: Int {
        Golems.baseMissionSlotCount + portalUpgrades.bonuses.golemMissionSlots
    }

    var missionSlotIndices: Range<Int> {
        0..<missionSlotCount
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

    func missionHealthRemainingFraction(slotIndex: Int) -> Double {
        golemService.missionHealthRemainingFraction(slotIndex: slotIndex)
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

    func presentCancelMissionConfirmation(slotIndex: Int) {
        coordinator?.custom(overlay: .card, MainPath.golemCancelMissionConfirm(slotIndex: slotIndex))
    }

    func confirmCancelMission(slotIndex: Int) {
        golemService.cancelMission(slotIndex: slotIndex)
    }

    func clearCompletedMission(slotIndex: Int) {
        golemService.clearCompletedMission(slotIndex: slotIndex)
    }

    func showMissionGainedItems(slotIndex: Int) {
        let gained = missionSlot(at: slotIndex).gainedItems
        guard !gained.isEmpty else {
            coordinator?.custom(overlay: .card, MainPath.dialog("No items gained yet."))
            return
        }
        let lines = gained
            .sorted { $0.key.name < $1.key.name }
            .map { "• \($0.key.name): \($0.value)" }
            .joined(separator: "\n")
        let text = "Items gained on this mission:\n\n" + lines
        coordinator?.custom(overlay: .card, MainPath.dialog(text))
    }

    func showMissionActivityLog(slotIndex: Int) {
        let slot = missionSlot(at: slotIndex)
        let entries = slot.activityLog
        guard !entries.isEmpty else {
            coordinator?.custom(overlay: .card, MainPath.dialog("No activity recorded yet."))
            return
        }
        let missionStart = slot.startedAt
        let lines = entries.map { entry in
            let elapsed = entry.date.timeIntervalSince(missionStart)
            let stamp = CompactDurationFormat.string(fromInterval: elapsed, roundingRule: .towardZero)
            return "\(stamp): \(entry.message)"
        }
        .joined(separator: "\n")
        coordinator?.custom(overlay: .card, MainPath.dialog("Mission log\n\n\(lines)"))
    }
}
