//Created by Alexander Skorulis on 9/3/2026.

import Knit
import KnitMacros
import Foundation
import Models

final class ClientRequestHandler {
    
    private let mainStore: MainStore
    
    @Resolvable<BaseResolver>
    init(mainStore: MainStore) {
        self.mainStore = mainStore
    }
    
    @MainActor
    func handle(request: ClientRequest) -> ClientResponse {
        switch request {
        case .getItems:
            let itemsWithCount = BaseItem.allCases.reduce(into: [BaseItem: Int]()) { dict, item in
                let quantity = mainStore.warehouse.quantity(item)
                if quantity > 0 {
                    dict[item] = quantity
                }
            }
            return .items(itemsWithCount)
        }
    }
}
