import SwiftUI

/// Renders the dimensional portal background image.
struct PortalGraphic: View {
    var body: some View {
        Asset.Creation.dimensionalPortal.swiftUIImage
            .resizable()
            .scaledToFit()
            .frame(maxWidth: 280, maxHeight: 280)
    }
}

#Preview {
    PortalGraphic()
}
