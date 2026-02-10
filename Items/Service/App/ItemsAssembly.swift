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
        
    }
    
    @MainActor
    private func registerStores(container: Container<TargetResolver>) {
        
    }
    
    @MainActor
    private func registerViewModels(container: Container<TargetResolver>) {
        
    }
    
}
