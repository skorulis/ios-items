import ASKCoordinator
import Knit
import Models
import SwiftUI

@MainActor
struct EquipmentListView: View {
    @State var viewModel: EquipmentListViewModel
    let contentOnly: Bool
    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

    var body: some View {
        if contentOnly {
            content
        } else {
            PageLayout(
                titleBar: { titleBar },
                content: { content }
            )
        }
    }

    private var titleBar: some View {
        TitleBar(
            title: "Equipment",
            backAction: {
                if let dismissCircularReveal {
                    dismissCircularReveal()
                } else {
                    viewModel.pop()
                }
            },
            leadingStyle: .close
        )
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 16) {
            headerRow

            if viewModel.equipment.isEmpty {
                Text("No equipment crafted yet.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            } else {
                VStack(spacing: 10) {
                    ForEach(viewModel.equipment) { instance in
                        equipmentRow(instance: instance)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var headerRow: some View {
        HStack {
            Text("\(viewModel.equipment.count)/100")
                .font(.appCaption)
                .foregroundStyle(.secondary)
            Spacer(minLength: 0)
        }
    }

    private func equipmentRow(instance: EquipmentInstance) -> some View {
        HStack(spacing: 12) {
            AvatarView(
                text: instance.displayName,
                image: nil,
                border: instance.quality.color,
                size: .small
            )

            VStack(alignment: .leading, spacing: 2) {
                Text(instance.displayName)
                    .font(.appSubheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .truncationMode(.tail)

                Text("\(instance.quality.name) • \(instance.material.nameAdjective) • \(instance.kind.displayName)")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.gray.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(instance.quality.color.opacity(0.35), lineWidth: 1)
        )
        .accessibilityLabel("\(instance.displayName), \(instance.quality.name)")
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    var warehouse = assembler.resolver.mainStore().warehouse
    warehouse.equipment = [
        EquipmentInstance(kind: .dagger, material: .stone, quality: .junk),
        EquipmentInstance(kind: .dagger, material: .silver, quality: .good),
    ]
    assembler.resolver.mainStore().warehouse = warehouse
    return EquipmentListView(
        viewModel: assembler.resolver.equipmentListViewModel(),
        contentOnly: false,
    )
}
