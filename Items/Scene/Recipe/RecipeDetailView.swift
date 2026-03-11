// Created by Cursor on 4/3/2026.

import Foundation
import Knit
import Models
import SwiftUI

// MARK: - Memory footprint

@MainActor
struct RecipeDetailView {
    @State var viewModel: RecipeDetailViewModel
    
    struct Model {
        let plan: SacrificePlan
        let qualityChances: [(ItemQuality, Double)]
        let essenceBonuses: [(Essence, Double)]
    }
}

// MARK: - Rendering

extension RecipeDetailView: View {
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            qualitySection
            essenceSection
        }
        .padding()
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Creation")
                .font(.title2.weight(.semibold))
            if !viewModel.model.plan.consumedItems.isEmpty {
                Text(recipeDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var recipeDescription: String {
        let names = viewModel.model.plan.consumedItems.map(\.name)
        return names.joined(separator: " + ")
    }
    
    private var qualitySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quality chances")
                .font(.headline)
            
            ForEach(viewModel.model.qualityChances, id: \.0) { quality, chance in
                HStack {
                    Text(quality.name)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .bold()
                        .foregroundStyle(quality.color)
                    Text(formatPercentage(chance))
                        .font(.body.monospacedDigit())
                        .frame(alignment: .trailing)
                }
            }
        }
    }
    
    @ViewBuilder
    private var essenceSection: some View {
        if !viewModel.model.essenceBonuses.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("Essence bonuses")
                    .font(.headline)
                
                ForEach(viewModel.model.essenceBonuses, id: \.0) { essence, boost in
                    HStack {
                        Text(essence.name)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text(formatMultiplier(boost))
                            .font(.body.monospacedDigit())
                            .frame(alignment: .trailing)
                    }
                }
            }
        }
    }
    
    private func formatPercentage(_ value: Double) -> String {
        let percentage = value * 100
        return String(format: "%.0f%%", percentage)
    }
    
    private func formatMultiplier(_ value: Double) -> String {
        // Essence boosts are multiplicative factors starting at 1.
        return String(format: "x%.1f", value)
    }
}
