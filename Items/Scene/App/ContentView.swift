//  Created by Alexander Skorulis on 10/2/2026.

import Knit
import SwiftUI

struct ContentView: View {
    
    @State var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            AnimatedBlobView(color: .blue, size: 220, speed: 0.7, points: 9, jitter: 0.26)
                .padding(.bottom, 16)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Make") {
                viewModel.make()
            }
        }
        .padding()
    }
}

#Preview {
    let assembler = ItemsAssembly.testing()
    ContentView(viewModel: assembler.resolver.contentViewModel())
}

