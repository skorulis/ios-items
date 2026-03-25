import ASKCoordinator
import Knit
import Models
import SwiftUI

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
            .disabled(viewModel.discoveredRecipes.isEmpty)
        }
    }

    private func selectedRecipeSection(recipe: EquipmentRecipe) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(recipe.productName)
                .font(.appSectionTitle)

            Text("Materials required")
                .font(.appSubheadline.weight(.semibold))

            UpgradeCostRow(cost: recipe.cost, itemQuantity: { viewModel.warehouse.quantity($0) })
        }
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
                Text("Craft")
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
