//  Created by Alexander Skorulis on 10/2/2026.

import ASKCore
import ASKCoordinator
import Knit
import SwiftUI

@main
struct ItemsApp: App {

    private let assembler: ScopedModuleAssembler<BaseResolver> = {
        let assembler = ScopedModuleAssembler<BaseResolver>(
            [
                ItemsAssembly(purpose: .normal)
            ]
        )
        return assembler
    }()

    @State var mainCoordinator = Coordinator(root: MainPath.content)

    var body: some Scene {
        WindowGroup {
            content
                .font(.appBody)
        }
    }

    @ViewBuilder
    private var content: some View {
        if ProcessInfo.isRunningTests {
            Color.white
        } else {
            CoordinatorView(coordinator: mainCoordinator, useNavigationStack: false)
                .withRenderers(resolver: assembler.resolver)
                .onAppear {
                    assembler.resolver.toastService().coordinator = mainCoordinator
                }
        }
    }

}
