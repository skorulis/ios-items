import Models
import SwiftUI

@MainActor
struct EquipmentDetailView: View {
    let equipment: EquipmentInstance

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                AvatarView(
                    text: equipment.displayName,
                    image: nil,
                    border: equipment.quality.color,
                    size: .medium
                )
                Text(equipment.displayName)
                    .font(.appTitle)
                    .lineLimit(2)
                    .truncationMode(.tail)
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                detailRow(
                    title: "Quality",
                    value: equipment.quality.name,
                    color: equipment.quality.color
                )
                detailRow(
                    title: "Material",
                    value: equipment.material.nameAdjective,
                    color: .black,
                )
                detailRow(title: "Type", value: equipment.kind.displayName, color: .black)
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
}

#Preview {
    let instance = EquipmentInstance(kind: .dagger, material: .stone, quality: .junk)
    EquipmentDetailView(equipment: instance)
}
