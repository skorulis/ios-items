//Created by Alexander Skorulis on 13/2/2026.

import ASKCoordinator
import Combine
import Foundation
import Knit
import KnitMacros
import SwiftUI

@Observable final class ResearchViewModel: CoordinatorViewModel {
    var coordinator: ASKCoordinator.Coordinator?
    
    private(set) var warehouse: Warehouse
    private(set) var lab: Laboratory
    var showingPicker: Bool = false
    
    /// Updated by timer for smooth progress bar; used when computing progress.
    var now: Date = Date()
    
    private let researchService: ResearchService
    private var cancellables: Set<AnyCancellable> = []
    private var timer: Timer?
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore, researchService: ResearchService) {
        self.researchService = researchService
        
        self.warehouse = mainStore.warehouse
        self.lab = mainStore.lab
        
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

// MARK: - Logic

extension ResearchViewModel {
    
    func selectAndBeginResearch(item: BaseItem) {
        researchService.startResearch(to: item, now: Date())
    }
    
    func viewItemDetails() {
        guard let selectedItem = lab.currentResearch?.item else { return }
        coordinator?.custom(overlay: .card, MainPath.itemDetails(selectedItem))
    }
    
    var currentLevel: Int {
        guard let selectedItem = lab.currentResearch?.item else { return 0 }
        return lab.currentLevel(item: selectedItem)
    }
    
    var totalSeconds: TimeInterval {
        guard let selectedItem = lab.currentResearch?.item else { return 0 }
        return researchService.progressFor(item: selectedItem, now: now).total
    }
    
    var completedSeconds: TimeInterval {
        guard let selectedItem = lab.currentResearch?.item else { return 0 }
        return researchService.progressFor(item: selectedItem, now: now).completed
    }
    
    func startTimer() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            Task { @MainActor in
                self.now = Date()
                self.researchService.updateResearchProgress(now: self.now)
            }
        }
        RunLoop.main.add(timer!, forMode: .common)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
