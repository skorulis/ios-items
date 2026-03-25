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
        let selected = viewModel.selectedRecipeIndex == index
        return HStack(spacing: 12) {
            AvatarView(
                text: recipe.material.nameAdjective,
                image: nil,
                border: recipe.quality.color,
                size: .small
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.kind.displayName)
                    .font(.appSubheadline.weight(.semibold))

                Text("\(recipe.material.nameAdjective) • Base \(recipe.quality.name)")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 0)

            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.accentColor)
            } else {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(selected ? Color.accentColor.opacity(0.12) : Color.gray.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(
                    selected ? Color.accentColor : recipe.quality.color.opacity(0.25),
                    lineWidth: selected ? 2 : 1
                )
        )
        .accessibilityLabel("Recipe \(recipe.name)")
    }
}
