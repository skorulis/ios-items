import Foundation
import Knit
import SwiftUI

@MainActor
struct GolemsView: View {
    @State var viewModel: GolemsViewModel

    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { EmptyView() }
        )
        .onAppear {
            viewModel.onAppear()
        }
    }

    private var titleBar: some View {
        TitleBar(title: "Golems", backAction: nil)
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    GolemsView(viewModel: assembler.resolver.golemsViewModel())
}
