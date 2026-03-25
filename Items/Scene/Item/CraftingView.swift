import ASKCoordinator
import Knit
import Models
import SwiftUI

private enum CraftingViewMetrics {
    static let outputSlotSize: CGFloat = 168
}

@MainActor
struct CraftingView: View {
    @State var viewModel: CraftingViewModel
    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(
            title: "Crafting",
            backAction: {
                if let dismissCircularReveal {
                    dismissCircularReveal()
                } else {
                    viewModel.coordinator?.pop()
                }
            },
            leadingStyle: .close
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            recipeSelectButton

            if let recipe = viewModel.selectedRecipe {
                selectedRecipeSection(recipe: recipe)
            }

            Spacer(minLength: 0)

            craftSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var recipeSelectButton: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recipes")
                .font(.appSectionTitle)

            Button(action: { viewModel.showRecipePicker() }) {
                HStack(spacing: 10) {
                    Image(systemName: "hammer")
                        .foregroundStyle(Color.black)
                    Text(viewModel.discoveredRecipes.isEmpty ? "No recipes discovered" : "Select recipe")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.forward")
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            viewModel.discoveredRecipes.isEmpty
                                ? Color.gray.opacity(0.25)
                                : Color.accentColor.opacity(0.6), lineWidth: 1
                        )
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.discoveredRecipes.isEmpty || viewModel.isCrafting)
        }
    }

    private func selectedRecipeSection(recipe: EquipmentRecipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.productName)
                .font(.appSectionTitle)

            recipeOutputSlot(recipe: recipe)

            Text("Materials required")
                .font(.appSubheadline.weight(.semibold))

            UpgradeCostRow(cost: recipe.cost, itemQuantity: { viewModel.warehouse.quantity($0) })
        }
    }

    private func craftingParticleColors(for recipe: EquipmentRecipe) -> [Color] {
        let fromMaterials = recipe.cost.flatMap(\.item.essences).map(\.color)
        if fromMaterials.isEmpty {
            return Essence.allCases.map(\.color)
        }
        return fromMaterials
    }

    private func recipeOutputSlot(recipe: EquipmentRecipe) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.08))
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.accentColor.opacity(0.4), lineWidth: 1.5)

            if let progress = viewModel.craftingInProgress, progress.recipe == recipe {
                ParticleCanvasView(
                    movementDuration: progress.duration,
                    colors: craftingParticleColors(for: recipe),
                )
                .id(progress.id)
                .allowsHitTesting(false)
            } else if let crafted = viewModel.lastCraftedEquipment {
                Button {
                    viewModel.showEquipmentDetails(for: crafted)
                } label: {
                    AvatarView(
                        text: crafted.fullName,
                        icon: crafted.image,
                        border: crafted.quality.color,
                        size: .medium,
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(crafted.displayName), \(crafted.quality.name)")
            } else {
                VStack(spacing: 8) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 36))
                        .foregroundStyle(.tertiary)
                    Text("Output")
                        .font(.appCaption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: CraftingViewMetrics.outputSlotSize, height: CraftingViewMetrics.outputSlotSize)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var craftSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let reason = viewModel.craftDisabledReason {
                Text(reason)
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
            }

            Button(action: {
                viewModel.craft()
            }) {
                ZStack {
                    if viewModel.isCrafting {
                        ProgressView()
                    }
                    Text("Craft")
                        .opacity(viewModel.isCrafting ? 0 : 1)
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.canCraft)
        }
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    return CraftingView(viewModel: assembler.resolver.craftingViewModel())
}
