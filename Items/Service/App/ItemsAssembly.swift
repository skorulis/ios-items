//  Created by Alexander Skorulis on 10/2/2026.

import Foundation
import Knit

final class ItemsAssembly: AutoInitModuleAssembly {
    static var dependencies: [any Knit.ModuleAssembly.Type] = []
    
    typealias TargetResolver = BaseResolver
    
    init() {}
    
    @MainActor func assemble(container: Container<TargetResolver>) {
        registerServices(container: container)
        registerStores(container: container)
        registerViewModels(container: container)
    }
    
    @MainActor
    private func registerServices(container: Container<TargetResolver>) {
        container.register(ItemGeneratorService.self) { _ in ItemGeneratorService() }
            .inObjectScope(.container)
    }
    
    @MainActor
    private func registerStores(container: Container<TargetResolver>) {
        container.register(MainStore.self) { _ in MainStore() }
            .inObjectScope(.container)
    }
    
    @MainActor
    private func registerViewModels(container: Container<TargetResolver>) {
        container.register(ContentViewModel.self) { ContentViewModel.make(resolver: $0) }
    }
    
}

extension ItemsAssembly {
    @MainActor static func testing() -> ScopedModuleAssembler<BaseResolver> {
        ScopedModuleAssembler<BaseResolver>([ItemsAssembly()])
    }
}
