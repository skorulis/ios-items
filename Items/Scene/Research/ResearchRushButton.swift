//Created by Cursor on 3/3/2026.

import Foundation
import Models
import SwiftUI

@MainActor
struct ResearchRushButton: View {
    
    let item: BaseItem
    let cost: Int
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: "bolt.fill")
                        .imageScale(.medium)
                    Text("Rush")
                        .font(.headline)
                    
                }
                costView
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(isEnabled ? AccentColors.amethyst : AccentColors.slate.opacity(0.4))
            )
            .foregroundStyle(Color.white)
        }
        .disabled(!isEnabled)
    }
    
    private var costView: some View {
        HStack {
            AvatarView(
                text: item.name,
                image: item.image,
                border: item.quality.color,
                size: .small
            )
            Text("×\(cost)")
                .font(.subheadline)
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ResearchRushButton(item: .apple, cost: 2, isEnabled: true, action: {})
        ResearchRushButton(item: .gear, cost: 5, isEnabled: false, action: {})
    }
    .padding()
    .background(Color.white)
}

