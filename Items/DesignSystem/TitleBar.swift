//  Created by Alexander Skorulis on 23/5/2025.

import Foundation
import SwiftUI

/// How the leading navigation button is drawn when `backAction` is set.
public enum TitleBarLeadingStyle {
    /// Chevron pointing left (stack pop / navigate back).
    case back
    /// X mark (dismiss sheet / close modal).
    case close
    
    var image: Image {
        switch self {
        case .back:
            Image(systemName: "chevron.left")
        case .close:
            Image(systemName: "xmark")
        }
    }
}

public struct TitleBar<TrailingIcon: View>: View {
    
    private let title: String
    private let backAction: (() -> Void)?
    private let leadingStyle: TitleBarLeadingStyle
    private let trailing: () -> TrailingIcon
    
    public init(
        title: String,
        backAction: (() -> Void)? = nil,
        leadingStyle: TitleBarLeadingStyle = .back,
        trailing: @escaping () -> TrailingIcon
    ) {
        self.title = title
        self.backAction = backAction
        self.leadingStyle = leadingStyle
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
                leadingStyle.image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.vertical, 12)
                    .font(.system(size: 17, weight: .semibold))
                    .frame(width: 44, height: 44)
                    .foregroundStyle(Color.black)
            }
        }
    }
    
    private var hasLeadingButton: Bool { backAction != nil }
}

public extension TitleBar where TrailingIcon == EmptyView {
    init(title: String, backAction: (() -> Void)? = nil, leadingStyle: TitleBarLeadingStyle = .back) {
        self.init(title: title, backAction: backAction, leadingStyle: leadingStyle, trailing: { EmptyView() })
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
