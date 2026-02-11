//  Created by Alexander Skorulis on 23/5/2025.

import Foundation
import SwiftUI

public struct TitleBar<TrailingIcon: View>: View {
    
    private let title: String
    private let backAction: (() -> Void)?
    private let trailing: () -> TrailingIcon
    
    public init(
        title: String,
        backAction: (() -> Void)? = nil,
        trailing: @escaping () -> TrailingIcon
    ) {
        self.title = title
        self.backAction = backAction
        self.trailing = trailing
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                maybeBackButton
                    
                Text(title)
                    .font(.title)
                Spacer()
                trailing()
            }
            .frame(minHeight: 44)
            .padding(.horizontal, hasLeadingButton ? 0 : 16)
            .padding(.trailing, hasLeadingButton ? 16 : 0)
            Divider()
        }
    }
    
    @ViewBuilder
    private var maybeBackButton: some View {
        if let backAction {
            Button(action: backAction) {
                Image(systemName: "chevron.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 12)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.black)
            }
        }
    }
    
    private var hasLeadingButton: Bool { backAction != nil }
}

public extension TitleBar where TrailingIcon == EmptyView {
    init(title: String, backAction: (() -> Void)? = nil) {
        self.init(title: title, backAction: backAction, trailing: { EmptyView() })
    }
}

#Preview {
    VStack {
        TitleBar(title: "Test") {
            Image(systemName: "square.and.arrow.down")
                .frame(width: 44, height: 44)
        }
        
        TitleBar(title: "Test", backAction: {}) {
            Image(systemName: "square.and.arrow.down")
                .frame(width: 44, height: 44)
        }
        Spacer()
    }
    
}
