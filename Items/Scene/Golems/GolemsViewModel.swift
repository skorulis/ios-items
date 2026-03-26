import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import Models
import SwiftUI

@Observable final class GolemsViewModel: CoordinatorViewModel {

    weak var coordinator: ASKCoordinator.Coordinator?

    var model: GolemsView.Model = .init()
    var mapLocations: MapLocations = MapLocations()

    private let mainStore: MainStore
    private let golemService: GolemService
    private var cancellables: Set<AnyCancellable> = []

    @Resolvable<BaseResolver>
    init(mainStore: MainStore, golemService: GolemService) {
        self.mainStore = mainStore
        self.golemService = golemService
        self.mapLocations = mainStore.mapLocations
        mainStore.$warehouse.sink { [unowned self] in
            self.model.warehouse = $0
        }
        .store(in: &cancellables)
        mainStore.$golems.sink { [unowned self] golems in
            self.model.golems = golems
        }
        .store(in: &cancellables)
        mainStore.$mapLocations.sink { [weak self] in
            self?.mapLocations = $0
        }
        .store(in: &cancellables)
        mainStore.$portalUpgrades.sink { [unowned self] in
            self.model.portalUpgrades = $0
        }
        .store(in: &cancellables)
    }
}

extension PortalUpgrade {
    var grantsGolemMission: Bool {
        switch self {
        case .golems,
             .golemMissionSlotsLevel2,
             .golemMissionSlotsLevel3,
             .golemMissionSlotsLevel4,
             .golemMissionSlotsLevel5:
            return true
        default:
            return false
        }
    }
}

extension GolemsViewModel {

    private func missionSlot(at index: Int) -> GolemMissionSlot {
        model.golems.slots[index] ?? .empty()
    }

    func openMissionLocationPicker(slotIndex: Int) {
        let slot = model.golems.slots[slotIndex] ?? .empty()
        guard slot.phase != .running else { return }
        coordinator?.custom(
            overlay: .card,
            MainPath.golemMissionLocationPicker(slotIndex: slotIndex),
        )
    }

    func unlockedMissionLocations() -> [MapLocation] {
        golemService.unlockedMissionLocations(from: mapLocations)
    }

    func missionHealthRemainingFraction(slotIndex: Int) -> Double {
        golemService.missionHealthRemainingFraction(slotIndex: slotIndex)
    }

    func setMissionLocation(slotIndex: Int, location: MapLocation) {
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

    func canRestartCompletedMission(slotIndex: Int) -> Bool {
        golemService.canRestartCompletedMission(slotIndex: slotIndex)
    }

    func restartCompletedMission(slotIndex: Int) {
        golemService.restartCompletedMission(slotIndex: slotIndex)
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
