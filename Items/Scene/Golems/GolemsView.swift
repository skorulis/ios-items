import Foundation
import Knit
import Models
import SwiftUI

@MainActor
struct GolemsView: View {
    @State var viewModel: GolemsViewModel

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }

    private var titleBar: some View {
        TitleBar(title: "Golems", backAction: nil)
    }

    private var content: some View {
        missionsList
    }

    private var missionsList: some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.model.slots) {
                GolemMissionSlotView(model: $0, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

}

extension GolemsView {
    struct Model {
        var golems: Golems = .init()
        var portalUpgrades: PortalUpgrades = PortalUpgrades()
        var warehouse: Warehouse = Warehouse()

        var golemCount: Int {
            PortalUpgrade.allCases.filter {
                $0.grantsGolemMission && portalUpgrades.purchased.contains($0)
            }
            .count
        }

        var slots: [GolemMissionSlotView.Model] {
            (0..<golems.slots.count).map {
                let slot = golems.slots[$0]!
                return GolemMissionSlotView.Model(
                    index: $0,
                    slot: slot,
                    canStart: warehouse.quantity(.portalShard) > 0 && slot.phase != .running,
                )
            }
        }
    }

}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemsView(viewModel: assembler.resolver.golemsViewModel())
}
