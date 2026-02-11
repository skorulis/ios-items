//  Created by Alexander Skorulis on 10/2/2026.

import Knit
import SwiftUI

@main
struct ItemsApp: App {
    
    private let assembler: ScopedModuleAssembler<BaseResolver> = {
        let assembler = ScopedModuleAssembler<BaseResolver>(
            [
                ItemsAssembly(),
            ]
        )
        return assembler
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: assembler.resolver.contentViewModel())
        }
        .environment(\.resolver, assembler.resolver)
    }
}
