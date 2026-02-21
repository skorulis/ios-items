//Created by Alexander Skorulis on 21/2/2026.

import Foundation
import Knit
import SwiftUI

// MARK: - Memory footprint

@MainActor struct EncyclopediaView {
    @State var viewModel: EncyclopediaViewModel
}

// MARK: - Rendering

extension EncyclopediaView: View {
    
    var body: some View {
        PageLayout(
            titleBar: { titleBar },
            content: { content }
        )
    }
    
    private var content: some View {
        VStack {
            Text(viewModel.entry.body)
            children
        }
        .padding(.horizontal, 16)
    }
    
    private var children: some View {
        ForEach(viewModel.entry.childItems, id: \.title) { entry in
            cell(entry: entry)
        }
    }
    
    private func cell(entry: EncyclopediaEntry) -> some View {
        ChevronRow(title: entry.title) {
            viewModel.showChild(entry: entry)
        }
    }
    
    private var titleBar: some View {
        TitleBar(
            title: viewModel.entry.title,
            backAction: viewModel.backAction,
        )
    }
}

// MARK: - Previews

#Preview {
    let assembler = ItemsAssembly.testing()
    EncyclopediaView(viewModel: assembler.resolver.encyclopediaViewModel(entry: .root))
}

