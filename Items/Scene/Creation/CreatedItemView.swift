import Models
import SwiftUI

@MainActor struct CreatedItemView: View {
    let item: MakeItemResult?
    let onDetailsTap: (MakeItemResult) -> Void

    var body: some View {
        Group {
            if let item {
                createdItem(item: item)
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder
    private func createdItem(item: MakeItemResult) -> some View {
        Button(
            action: { onDetailsTap(item) },
            label: {
                content(item: item)
            }
        )
    }
    
    @ViewBuilder
    private func content(item: MakeItemResult) -> some View {
        switch item {
        case let .base(baseItem, count):
            ItemView(
                item: baseItem,
                quantity: count > 1 ? count : nil
            )
        case let .artifact(instance):
            ArtifactView(artifact: instance)
        }
    }
}
