// Created by Alexander Skorulis on 23/3/2026.

import Knit
import Models
import SwiftUI

/// Card overlay to choose which golem type is assigned to a mission slot.
@MainActor
struct GolemMissionGolemPickerView: View {
    let slotIndex: Int
    @State var viewModel: GolemsViewModel
    @Environment(\.dismissCustomOverlay) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose golem")
                .font(.appTitle)
                .padding(.horizontal, 16)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Button {
                        viewModel.setReservedGolem(slotIndex: slotIndex, newType: nil)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, height: 40)
                            Text("None")
                                .font(.appSubheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    ForEach(viewModel.selectableGolemTypes(for: slotIndex), id: \.self) { type in
                        Button {
                            viewModel.setReservedGolem(slotIndex: slotIndex, newType: type)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                if let image = type.image {
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 40, height: 40)
                                }
                                Text(type.name)
                                    .font(.appSubheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 400)
        }
        .padding(.vertical, 16)
    }
}

/// Card overlay to choose the mission destination.
@MainActor
struct GolemMissionLocationPickerView: View {
    let slotIndex: Int
    @State var viewModel: GolemsViewModel
    @Environment(\.dismissCustomOverlay) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose location")
                .font(.appTitle)
                .padding(.horizontal, 16)

            ScrollView {
                LazyVStack(alignment: .leading, spacing: 8) {
                    Button {
                        viewModel.setMissionLocation(slotIndex: slotIndex, location: nil)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "minus.circle")
                                .font(.title2)
                                .foregroundStyle(.secondary)
                                .frame(width: 40, height: 40)
                            Text("None")
                                .font(.appSubheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)

                    ForEach(viewModel.unlockedMissionLocations(), id: \.self) { location in
                        Button {
                            viewModel.setMissionLocation(slotIndex: slotIndex, location: location)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                location.icon
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 40, height: 40)
                                    .symbolRenderingMode(.hierarchical)
                                Text(location.name)
                                    .font(.appSubheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Spacer(minLength: 0)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 8))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(maxHeight: 400)
        }
        .padding(.vertical, 16)
    }
}

#Preview("Golem picker") {
    let assembler = ItemsAssembly.testing()
    GolemMissionGolemPickerView(slotIndex: 0, viewModel: assembler.resolver.golemsViewModel())
}

#Preview("Location picker") {
    let assembler = ItemsAssembly.testing()
    GolemMissionLocationPickerView(slotIndex: 0, viewModel: assembler.resolver.golemsViewModel())
}

/// Confirms golem loss before cancelling an in-progress mission.
@MainActor
struct GolemCancelMissionConfirmView: View {
    let slotIndex: Int
    @State var viewModel: GolemsViewModel
    @Environment(\.dismissCustomOverlay) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cancel mission?")
                .font(.appTitle)

            Text(
                "Cancelling will stop this mission and return the golem to setup."
            )
            .font(.appBody)
            .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 12) {
                Button("Keep mission") {
                    dismiss()
                }
                .buttonStyle(CapsuleButtonStyle())

                Spacer(minLength: 0)

                Button("Cancel mission") {
                    viewModel.confirmCancelMission(slotIndex: slotIndex)
                    dismiss()
                }
                .buttonStyle(CapsuleButtonStyle())
            }
        }
        .padding(16)
    }
}
