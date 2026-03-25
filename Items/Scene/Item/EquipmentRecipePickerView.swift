import Knit
import Models
import SwiftUI

@MainActor
struct EquipmentRecipePickerView: View {
    @State var viewModel: EquipmentRecipePickerViewModel
    @Environment(\.dismissCustomOverlay) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose recipe")
                .font(.appTitle)
                .padding(.horizontal, 16)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 8) {
                    if viewModel.discoveredRecipes.isEmpty {
                        Text("No equipment recipes discovered yet.")
                            .font(.appCaption)
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                    } else {
                        ForEach(viewModel.discoveredRecipes.indices, id: \.self) { index in
                            let recipe = viewModel.discoveredRecipes[index]
                            Button {
                                viewModel.selectRecipe(at: index)
                                dismiss()
                            } label: {
                                recipeRow(index: index, recipe: recipe)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(16)
            }
        }
    }

    private func recipeRow(index: Int, recipe: EquipmentRecipe) -> some View {
        return HStack(spacing: 12) {
            AvatarView(
                text: recipe.name,
                icon: recipe.icon,
                border: recipe.quality.color,
                size: .small
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.name)
                    .font(.appSubheadline.weight(.semibold))
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
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
                    recipe.quality.color.opacity(0.25),
                    lineWidth: 2
                )
        )
        .accessibilityLabel("Recipe \(recipe.name)")
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    var warehouse = assembler.resolver.mainStore().warehouse
    warehouse.recipes = Set(EquipmentRecipe.allCases)
    assembler.resolver.mainStore().warehouse = warehouse
    return EquipmentRecipePickerView(
        viewModel: EquipmentRecipePickerViewModel(
            mainStore: assembler.resolver.mainStore(),
            onRecipeSelected: { _ in }
        )
    )
}
