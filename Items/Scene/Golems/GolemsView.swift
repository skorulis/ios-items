import Foundation
import Knit
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
        var slots: [GolemMissionSlotView.Model] = []
    }

}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemsView(viewModel: assembler.resolver.golemsViewModel())
}
