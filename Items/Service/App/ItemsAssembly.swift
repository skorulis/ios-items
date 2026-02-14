//  Created by Alexander Skorulis on 10/2/2026.

import ASKCore
import Foundation
import Knit
import SwiftUI

final class ItemsAssembly: AutoInitModuleAssembly {
    static var dependencies: [any Knit.ModuleAssembly.Type] = []
    typealias TargetResolver = BaseResolver
    
    private let purpose: IOCPurpose
    
    init() {
        self.purpose = .testing
    }
    
    init(purpose: IOCPurpose ) {
        self.purpose = purpose
    }
    
    @MainActor func assemble(container: Container<TargetResolver>) {
        ASKCoreAssembly(purpose: purpose).assemble(container: container)
        if purpose == .normal {
            // @knit ignore
            container.register(PKeyValueStore.self) { _ in
                FileSystemKeyValueStore(folderName: "items")
            }
            .inObjectScope(.container)
        }
        
        registerServices(container: container)
        registerStores(container: container)
        registerViewModels(container: container)
    }
    
    @MainActor
    private func registerServices(container: Container<TargetResolver>) {
        container.register(ItemGeneratorService.self) { _ in ItemGeneratorService() }
            .inObjectScope(.container)
        
        container.register(RecipeService.self) { RecipeService.make(resolver: $0) }
        container.register(ResearchService.self) { ResearchService.make(resolver: $0) }
    }
    
    @MainActor
    private func registerStores(container: Container<TargetResolver>) {
        container.register(MainStore.self) { MainStore.make(resolver: $0) }
            .inObjectScope(.container)
    }
    
    @MainActor
    private func registerViewModels(container: Container<TargetResolver>) {
        container.register(ContentViewModel.self) { ContentViewModel.make(resolver: $0) }
        container.register(CreationViewModel.self) { CreationViewModel.make(resolver: $0) }
        container.register(WarehouseViewModel.self) { WarehouseViewModel.make(resolver: $0) }
        container.register(RecipeListViewModel.self) { RecipeListViewModel.make(resolver: $0)}
        container.register(ResearchViewModel.self) { ResearchViewModel.make(resolver: $0)}
        
        container.register(MainPathRenderer.self) { MainPathRenderer(resolver: $0) }
    }
    
}

extension ItemsAssembly {
    @MainActor static func testing() -> ScopedModuleAssembler<BaseResolver> {
        ScopedModuleAssembler<BaseResolver>([ItemsAssembly()])
    }
}

public extension EnvironmentValues {
    @Entry var resolver: BaseResolver?
}
