import Models
import Knit
import SwiftUI

@MainActor
struct EquipmentDetailView: View {
    @State var viewModel: EquipmentDetailViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                AvatarView(
                    text: viewModel.equipment.displayName,
                    image: nil,
                    border: viewModel.equipment.quality.color,
                    size: .medium
                )
                Text(viewModel.equipment.displayName)
                    .font(.appTitle)
                    .lineLimit(2)
                    .truncationMode(.tail)
                Spacer()

                Button(action: viewModel.trash) {
                    Image(systemName: "trash")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundStyle(.red)
                        .padding(8)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove equipment from warehouse")
            }

            VStack(alignment: .leading, spacing: 8) {
                detailRow(
                    title: "Quality",
                    value: viewModel.equipment.quality.name,
                    color: viewModel.equipment.quality.color
                )
                detailRow(
                    title: "Material",
                    value: viewModel.equipment.material.nameAdjective,
                    color: .black,
                )
                detailRow(title: "Type", value: viewModel.equipment.kind.displayName, color: .black)
                if viewModel.equipment.stats.attack != 0 {
                    detailRow(
                        title: "Attack",
                        value: statString(viewModel.equipment.stats.attack),
                        color: .black
                    )
                }
                if viewModel.equipment.stats.defence != 0 {
                    detailRow(
                        title: "Defence",
                        value: statString(viewModel.equipment.stats.defence),
                        color: .black
                    )
                }
            }
        }
        .padding(16)
    }

    private func detailRow(title: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text("\(title):")
                .font(.appSubheadline)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.appSubheadline.weight(.semibold))
                .foregroundStyle(color)
            Spacer()
        }
    }
    
    private func statString(_ value: Double) -> String {
        if value.rounded() == value {
            return String(Int(value))
        } else {
            return String(format: "%.1f", value)
        }
    }
}

#Preview {
    let instance = EquipmentInstance(kind: .dagger, material: .stone, quality: .junk)
    let assembler = ItemsAssembly.testing()
    EquipmentDetailView(
        viewModel: assembler.resolver.equipmentDetailViewModel(equipment: instance)
    )
}
