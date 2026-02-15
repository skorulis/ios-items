//Created by Alexander Skorulis on 15/2/2026.

import Foundation

import SwiftUI

// MARK: - Memory footprint

@MainActor struct CardBackground {
    
}

// MARK: - Rendering

extension CardBackground: View {
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
            
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 2)
        }
        
    }
}

// MARK: - Previews

#Preview {
    CardBackground()
        .padding(16)
}

