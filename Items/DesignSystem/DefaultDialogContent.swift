// Created by Alexander Skorulis on 17/3/2026.

import SwiftUI

struct DefaultDialogContent: View {

    struct Model {
        var bodyText: String
        var title: String?

        init(bodyText: String, title: String? = nil) {
            self.bodyText = bodyText
            self.title = title
        }
    }

    let model: Model

    init(model: Model) {
        self.model = model
    }

    init(bodyText: String, title: String? = nil) {
        self.model = Model(bodyText: bodyText, title: title)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title = model.title {
                Text(title)
                    .font(.appTitle)
            }
            Text(model.bodyText)
                .font(.appBody)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
    }
}

#Preview {
    DefaultDialogContent(
        bodyText: "This is the body text of the dialog. It can span multiple lines and will wrap as needed.",
        title: "Dialog Title"
    )
}

#Preview("No title") {
    DefaultDialogContent(bodyText: "Body only, no title.")
}

#Preview("From model") {
    DefaultDialogContent(model: .init(
        bodyText: "Content from model.",
        title: "Model Title"
    ))
}
