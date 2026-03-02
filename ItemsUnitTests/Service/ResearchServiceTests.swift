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
}

