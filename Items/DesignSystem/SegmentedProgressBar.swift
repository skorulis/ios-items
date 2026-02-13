import SwiftUI

struct SegmentedProgressBar: View {
    let totalSteps: Int
    let currentStep: Int
    var height: CGFloat = 8
    var backgroundColor: Color = Color.gray.opacity(0.3)
    var progressColor: Color = Color.accentColor
    var spacing: CGFloat = 4
    
    private var clampedTotalSteps: Int {
        max(totalSteps, 1)
    }
    
    private var clampedCurrentStep: Int {
        min(max(currentStep, 0), clampedTotalSteps)
    }
    
    public init(totalSteps: Int,
                currentStep: Int,
                height: CGFloat = 8,
                backgroundColor: Color = Color.gray.opacity(0.3),
                progressColor: Color = Color.accentColor,
                spacing: CGFloat = 4) {
        self.totalSteps = totalSteps
        self.currentStep = currentStep
        self.height = height
        self.backgroundColor = backgroundColor
        self.progressColor = progressColor
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<clampedTotalSteps, id: \.self) { index in
                RoundedRectangle(cornerRadius: height / 2)
                    .fill(index < clampedCurrentStep ? progressColor : backgroundColor)
                    .frame(height: height)
                    .animation(.easeInOut(duration: 0.3), value: clampedCurrentStep)
            }
        }
    }
}

struct SegmentedProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SegmentedProgressBar(totalSteps: 5, currentStep: 2)

            SegmentedProgressBar(totalSteps: 10, currentStep: 7, height: 12, backgroundColor: .blue.opacity(0.2), progressColor: .blue)

            SegmentedProgressBar(totalSteps: 6, currentStep: 6, height: 6, backgroundColor: .gray.opacity(0.1), progressColor: .green)

            SegmentedProgressBar(totalSteps: 4, currentStep: 0, height: 10, backgroundColor: .red.opacity(0.2), progressColor: .red)
            
            SegmentedProgressBar(totalSteps: 8, currentStep: 9, height: 10, backgroundColor: .purple.opacity(0.2), progressColor: .purple)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
