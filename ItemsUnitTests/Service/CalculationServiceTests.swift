//Created by Alexander Skorulis on 2/3/2026.

@testable import Items
import Knit
import Testing

@MainActor
struct CalculationServiceTests {

    let assembly = ItemsAssembly.testing()
    var calculationService: CalculationsService { assembly.resolver.calculationsService() }
    var mainStore: MainStore { assembly.resolver.mainStore() }

    @Test
    func artifactChance_doublesPerResearchLevel() {
        // Junk base chance = 0.1 * 1 = 0.1
        #expect(calculationService.artifactChance(quality: .junk, researchLevel: 0).fraction == 0.1)
        #expect(calculationService.artifactChance(quality: .junk, researchLevel: 1).fraction == 0.2)
        #expect(calculationService.artifactChance(quality: .junk, researchLevel: 2).fraction == 0.4)
        #expect(calculationService.artifactChance(quality: .junk, researchLevel: 3).fraction == 0.8)
        #expect(calculationService.artifactChance(quality: .junk, researchLevel: 4).fraction == 1.0) // capped
        
        #expect(calculationService.artifactChance(quality: .exceptional, researchLevel: 10).fraction == 0.1024)
    }

    @Test
    func artifactChance_respectsQualityMultiplier() {
        expectApproximate(calculationService.artifactChance(quality: .common, researchLevel: 0).fraction,  0.02)  // 0.1 * 0.2
        expectApproximate(calculationService.artifactChance(quality: .good, researchLevel: 0).fraction, 0.005)   // 0.1 * 0.05
        expectApproximate(calculationService.artifactChance(quality: .exceptional, researchLevel: 0).fraction, 0.0001) // 0.1 * 0.001
    }

    @Test
    func artifactChance_qualityAndLevelCombine() {
        // Common base 0.02, level 2 = 4x -> 0.08
        expectApproximate(calculationService.artifactChance(quality: .common, researchLevel: 2).fraction, 0.08)
    }
}

