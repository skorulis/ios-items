//Created by Alexander Skorulis on 20/2/2026.

import Foundation
import SwiftUI

// MARK: - Memory footprint

@MainActor struct GoalProgressBar {
    let value: Int64
    let total: Int64
    @State private var size: CGSize = .zero
    
    init(value: Int64, total: Int64) {
        self.value = min(value, total)
        self.total = total
    }
}

// MARK: - Rendering

extension GoalProgressBar: View {
    
    var body: some View {
        ZStack(alignment: .center) {
            bar
            Text(stringValue)
                .foregroundStyle(Color.white)
        }
        .readSize(size: $size)
    }
    
    private var stringValue: String {
        return "\(value)/\(total)"
    }
    
    private var bar: some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(AccentColors.slate)
                
            overlay
            
        }
        .frame(height: 20)
    }
    
    private var overlay: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(AccentColors.amethyst)
                .frame(width: size.width * progressFraction)
            Spacer(minLength: 0)
        }
        .clipShape(Capsule())
    }
    
    private var progressFraction: CGFloat {
        return min(CGFloat(value) / CGFloat(total), 1)
    }
}

// MARK: - Previews

#Preview {
    VStack(spacing: 16) {
        GoalProgressBar(value: 0, total: 100)
        GoalProgressBar(value: 50, total: 100)
        GoalProgressBar(value: 1000, total: 100)
        GoalProgressBar(value: 1, total: 1000)
        GoalProgressBar(value: 10, total: 1000)
    }
    .padding(16)
    
}

