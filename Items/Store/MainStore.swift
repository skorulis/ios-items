//Created by Alexander Skorulis on 10/2/2026.

import Combine
import Foundation

final class MainStore: ObservableObject {
    @Published var warehouse = Warehouse()
    @Published var statistics = Statistics()
}
