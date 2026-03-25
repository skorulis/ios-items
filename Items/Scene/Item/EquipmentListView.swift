import ASKCoordinator
import Knit
import Models
import SwiftUI

@MainActor
struct EquipmentListView: View {
    @State var viewModel: EquipmentListViewModel
    let contentOnly: Bool
    @Environment(\.dismissCircularReveal) private var dismissCircularReveal

    enum SortOption: String, CaseIterable, Identifiable {
        case name
        case quality

        var id: String { rawValue }
    }

    @State private var sortOption: SortOption = .quality

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
            sortPickerRow

            if viewModel.equipment.isEmpty {
                Text("No equipment crafted yet.")
                    .font(.appCaption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 12)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 80))],
                    spacing: 12
                ) {
                    ForEach(displayedEquipment) { instance in
                        Button {
                            viewModel.showDetails(for: instance)
                        } label: {
                            AvatarView(
                                text: instance.fullName,
                                icon: instance.image,
                                border: instance.quality.color,
                                size: .medium
                            )
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(instance.displayName), \(instance.quality.name)")
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

    private var sortPickerRow: some View {
        HStack {
            Text("Sort: ")
            Picker("Sort", selection: $sortOption) {
                Text("Name").tag(SortOption.name)
                Text("Quality").tag(SortOption.quality)
            }
            .pickerStyle(.menu)
        }
    }

    private var displayedEquipment: [EquipmentInstance] {
        switch sortOption {
        case .name:
            return viewModel.equipment
                .sorted { $0.displayName.localizedStandardCompare($1.displayName) == .orderedAscending }
        case .quality:
            return viewModel.equipment
                .sorted { lhs, rhs in
                    if lhs.quality != rhs.quality {
                        return lhs.quality > rhs.quality
                    }
                    return lhs.displayName.localizedStandardCompare(rhs.displayName) == .orderedAscending
                }
        }
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
