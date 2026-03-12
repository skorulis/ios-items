// Created by Cursor on 3/3/2026.

@testable import Items
import Models
import Knit
import SnapshotTesting
import SwiftUI
import Testing

@MainActor @Suite(.snapshots(record: .failed))
struct ResearchViewSnapshotTests {

    let assembler = ItemsAssembly.testing()
    
    @Test
    func research_empty_state() {
        let viewModel = assembler.resolver.researchViewModel()
        let view = ResearchView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

    @Test
    func research_in_progress_low_level() {
        let mainStore = assembler.resolver.mainStore()
        let researchService = assembler.resolver.researchService()

        // Give the player some apples so they can rush later.
        mainStore.warehouse.add(item: .apple, count: 10)

        // Start research on apple at time 0.
        let start = Date.now.addingTimeInterval(-30)
        researchService.startResearch(to: .apple, now: start)

        // Advance progress part-way through the first level.
        let midway = start.addingTimeInterval(30)
        researchService.updateResearchProgress(now: midway)

        let viewModel = assembler.resolver.researchViewModel()
        let view = ResearchView(viewModel: viewModel)

        assertSnapshot(of: view, as: .image(on: .iPhoneSe))
    }

}

