//Created by Alexander Skorulis on 6/3/2026.

import ASKCoordinator
import Knit
import Foundation
import SwiftUI

struct CircularAnimationPath: CoordinatorPath {
    let sourceRect: CGRect
    let mainPath: MainPath
    
    public var id: String {
        mainPath.id
    }
    
}


struct CircularPathRenderer: CoordinatorPathRenderer {
 
    let mainPathRenderer: MainPathRenderer
    
    @ViewBuilder
    func render(path: CircularAnimationPath, in coordinator: Coordinator) -> some View {
        mainPathRenderer.render(path: path.mainPath, in: coordinator)
    }
}
