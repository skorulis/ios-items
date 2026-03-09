// Created by Cursor on 3/3/2026.

@testable import Items
import Knit
import Testing
import Foundation

@MainActor
struct ResearchServiceTests {
    
    // MARK: - Helpers
    
    private func makeAssembly() -> ScopedModuleAssembler<BaseResolver> {
        ItemsAssembly.testing()
    }
    
    // MARK: - Tests
    
    @Test
    func startResearch_setsCurrentResearch() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 1_000)
        
        researchService.startResearch(to: item, now: start)
        
        let lab = mainStore.lab
        #expect(lab.currentLevel(item: item) == 0)
        #expect(lab.currentResearch?.item == item)
        #expect(lab.currentResearch?.startDate == start)
    }
    
    @Test
    func updateProgress_accumulatesWithoutLevelUp() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 2_000)
        
        researchService.startResearch(to: item, now: start)
        
        // Half the required time (60s of 120s) should not level up.
        let halfway = start.addingTimeInterval(60)
        researchService.updateResearchProgress(now: halfway)
        
        let lab = mainStore.lab
        #expect(lab.currentLevel(item: item) == 0)
        expectApproximate(lab.accumulatedSeconds(for: item), 60)
        
        let progress = researchService.progressFor(item: item, now: halfway)
        expectApproximate(progress.completed, 60)
        #expect(progress.total == 120)
    }
    
    @Test
    func updateProgress_levelsUpAndCarriesRemainder() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 3_000)
        
        researchService.startResearch(to: item, now: start)
        
        // First apply a partial update so there is stored accumulated time.
        let t1 = start.addingTimeInterval(60)
        researchService.updateResearchProgress(now: t1)
        
        // Now advance far enough that one full level completes (120s) plus 80s extra.
        let t2 = start.addingTimeInterval(200)
        researchService.updateResearchProgress(now: t2)
        
        let lab = mainStore.lab
        #expect(lab.currentLevel(item: item) == 1)
        expectApproximate(lab.accumulatedSeconds(for: item), 80)
        
        // Progress should now be toward level 2, which takes 240 seconds.
        let progress = researchService.progressFor(item: item, now: t2)
        #expect(progress.total == 240)
        expectApproximate(progress.completed, 80)
        
        // Essences unlocked up to the new level should be present in concepts.
        let expectedEssences = item.availableResearch.unlockedEssences(level: 1)
        for essence in expectedEssences {
            #expect(mainStore.concepts.essences.contains(essence))
        }
    }
    
    // MARK: - Rush cost
    
    @Test
    func rushCost_fullDuration_returnsItemsPerMinute() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 5_000)
        
        researchService.startResearch(to: item, now: start)
        
        // Level 0 = 120s = 2 minutes → cost 2 items
        let cost = researchService.rushCost(for: item, now: start)
        #expect(cost == 2)
    }
    
    @Test
    func rushCost_afterPartialProgress_reducesCost() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 6_000)
        
        researchService.startResearch(to: item, now: start)
        
        // After 60s: 60s remaining = 1 minute → cost 1 item
        let afterMinute = start.addingTimeInterval(60)
        let cost = researchService.rushCost(for: item, now: afterMinute)
        #expect(cost == 1)
    }
    
    @Test
    func rushCost_partialMinuteRemaining_roundsUp() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 7_000)
        
        researchService.startResearch(to: item, now: start)
        
        // After 59s: 61s remaining → ceil(61/60) = 2 items
        let after59 = start.addingTimeInterval(59)
        let cost = researchService.rushCost(for: item, now: after59)
        #expect(cost == 2)
    }
    
    @Test
    func rushCost_whenNoRemaining_returnsZero() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 8_000)
        
        researchService.startResearch(to: item, now: start)
        
        // At exactly 120s completed, remaining is 0 (level would complete on next tick)
        let atComplete = start.addingTimeInterval(120)
        let cost = researchService.rushCost(for: item, now: atComplete)
        #expect(cost == 0)
    }
    
    @Test
    func rushCost_noCurrentResearchForItem_usesStoredProgress() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 9_000)
        
        researchService.startResearch(to: item, now: start)
        let afterMinute = start.addingTimeInterval(60)
        researchService.updateResearchProgress(now: afterMinute)
        
        // Switch to another item so apple is not current; progress is stored (60s at level 0).
        researchService.startResearch(to: .rock, now: afterMinute)
        
        // Rush cost for apple: total 120, accumulated 60 (stored), no live elapsed → 60s remaining → 1
        let cost = researchService.rushCost(for: item, now: afterMinute)
        #expect(cost == 1)
    }
    
    // MARK: - Rush research
    
    @Test
    func rushResearch_consumesItemsAndLevelsUp() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 10_000)
        
        mainStore.warehouse.add(item: item, count: 5)
        researchService.startResearch(to: item, now: start)
        
        researchService.rushResearch(to: item, useBooks: false, now: start)
        
        #expect(mainStore.lab.currentLevel(item: item) == 1)
        #expect(mainStore.lab.accumulatedSeconds(for: item) == 0)
        #expect(mainStore.warehouse.quantity(item) == 3) // 5 - 2
    }
    
    @Test
    func rushResearch_resetsProgressToZero() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 11_000)
        
        mainStore.warehouse.add(item: item, count: 5)
        researchService.startResearch(to: item, now: start)
        let halfway = start.addingTimeInterval(60)
        researchService.updateResearchProgress(now: halfway)
        
        researchService.rushResearch(to: item, useBooks: false, now: halfway)
        
        #expect(mainStore.lab.currentLevel(item: item) == 1)
        expectApproximate(mainStore.lab.accumulatedSeconds(for: item), 0)
    }
    
    @Test
    func rushResearch_whenInsufficientItems_doesNothing() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 12_000)
        
        mainStore.warehouse.add(item: item, count: 1) // need 2 to rush level 0
        researchService.startResearch(to: item, now: start)
        
        researchService.rushResearch(to: item, useBooks: false, now: start)
        
        #expect(mainStore.lab.currentLevel(item: item) == 0)
        #expect(mainStore.warehouse.quantity(item) == 1)
    }
    
    @Test
    func rushResearch_appliesUnlocks() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 13_000)
        
        mainStore.warehouse.add(item: item, count: 5)
        researchService.startResearch(to: item, now: start)
        
        researchService.rushResearch(to: item, useBooks: false, now: start)
        
        let expectedEssences = item.availableResearch.unlockedEssences(level: 1)
        for essence in expectedEssences {
            #expect(mainStore.concepts.essences.contains(essence))
        }
    }
    
    @Test
    func rushResearch_chargesReducedCostAfterPartialProgress() {
        let assembly = makeAssembly()
        let researchService = assembly.resolver.researchService()
        let mainStore = assembly.resolver.mainStore()
        let item: BaseItem = .apple
        let start = Date(timeIntervalSince1970: 14_000)
        
        mainStore.warehouse.add(item: item, count: 3)
        researchService.startResearch(to: item, now: start)
        let afterMinute = start.addingTimeInterval(60)
        researchService.updateResearchProgress(now: afterMinute)
        
        researchService.rushResearch(to: item, useBooks: false, now: afterMinute)
        
        // Cost should be 1 (60s remaining), so 3 - 1 = 2 left
        #expect(mainStore.lab.currentLevel(item: item) == 1)
        #expect(mainStore.warehouse.quantity(item) == 2)
    }
}

