// swiftlint:disable all
// swiftformat:disable all

import XCTest
import SwiftUI
import Prefire
import SnapshotTesting
#if canImport(AccessibilitySnapshot)
    import AccessibilitySnapshot
#endif

@MainActor class PreviewTests: XCTestCase, Sendable {
    private var simulatorDevice: String?
    private var requiredOSVersion: Int?
    private let snapshotDevices: [String] = []
#if os(iOS)
    private let deviceConfig: DeviceConfig = ViewImageConfig.iPhoneX.deviceConfig
#elseif os(tvOS)
    private let deviceConfig: DeviceConfig = ViewImageConfig.tv.deviceConfig
#endif



    @MainActor override func setUp() async throws {
        try await super.setUp()

        checkEnvironments()
        UIView.setAnimationsEnabled(false)
    }

    // MARK: - PreviewProvider

    // MARK: - Macros

    func test_WarehouseView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            assembler.resolver.mainStore().warehouse.add(item: .apple)
            return WarehouseView(viewModel: assembler.resolver.warehouseViewModel())
            },
            name: "WarehouseView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_Toast_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    Toast(text: "Test123")
                }
                .frame(maxHeight: .infinity)
                .background(Color.black)
            },
            name: "Toast_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ToastPathWrapper_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                ToastPathWrapper(
                    isVisible: true,
                    content: { Text("Toast") },
                )
            },
            name: "ToastPathWrapper_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_TitleBar_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    TitleBar(title: "Test") {
                        Image(systemName: "square.and.arrow.down")
                            .frame(width: 44, height: 44)
                    }
                    TitleBar(title: "Test", backAction: {}) {
                        Image(systemName: "square.and.arrow.down")
                            .frame(width: 44, height: 44)
                    }
                    Spacer()
                }
            },
            name: "TitleBar_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_TimerProgressView_0_Preview() {        
        struct PreviewWrapperTimerProgressView_0: SwiftUI.View {
            @State var timerId = UUID()
            var body: some View {
                return VStack(spacing: 16) {
                    TimerProgressView(timerId: timerId, duration: 3)
                        .frame(width: 64, height: 64)
                    Button("Restart animation") {
                        timerId = UUID()
                    }
                }
                .padding()
            }
        }
        let prefireSnapshot = PrefireSnapshot(
            {
                PreviewWrapperTimerProgressView_0()
            },
            name: "TimerProgressView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_SegmentedResearchBar_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    SegmentedResearchBar(
                        research: BaseItem.apple.availableResearch, level: 0
                    )
                    SegmentedResearchBar(
                        research: BaseItem.apple.availableResearch, level: 2
                    )
                }
                .padding(16)
            },
            name: "SegmentedResearchBar_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ResearchView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            assembler.resolver.mainStore().warehouse.add(item: .apple)
            return ResearchView(viewModel: assembler.resolver.researchViewModel())
            },
            name: "ResearchView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ResearchRushButton_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack(spacing: 16) {
                    ResearchRushButton(item: .apple, cost: 2, isEnabled: true, action: {})
                    ResearchRushButton(item: .gear, cost: 5, isEnabled: false, action: {})
                }
                .padding()
                .background(Color.white)
            },
            name: "ResearchRushButton_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ResearchBarView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack(spacing: 16) {
                    ResearchBarView(totalSeconds: 45, completedSeconds: 10)
                    ResearchBarView(totalSeconds: 5 * 60, completedSeconds: 75)
                    ResearchBarView(totalSeconds: 90 * 60, completedSeconds: 30 * 60)
                    ResearchBarView(totalSeconds: 3 * 86_400, completedSeconds: 86_400 + 3600 + 30)
                }
                .padding()
            },
            name: "ResearchBarView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ParticleCanvasView_0_Preview() {        
        struct PreviewWrapperParticleCanvasView_0: SwiftUI.View {
            @State var animationID = UUID()
            var body: some View {
                ZStack(alignment: .bottom) {
                    ParticleCanvasView()
                        .id(animationID)
                        .border(Color.red)
                    Button("Restart") {
                        animationID = UUID()
                    }
                }
            }
        }
        let prefireSnapshot = PrefireSnapshot(
            {
                PreviewWrapperParticleCanvasView_0()
            },
            name: "ParticleCanvasView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ItemView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                HStack(spacing: 8) {
                    ItemView(item: .gear)
                    ItemView(item: .silverFlorin)
                    ItemView(item: .goldFlorin)
                }
            },
            name: "ItemView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ItemPicker_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                ItemPicker(onSelect: { _ in })
            },
            name: "ItemPicker_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ItemGridCell_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    ItemGridCell(item: .apple, quantity: nil)
                    ItemGridCell(item: .apple, quantity: 10)
                    ItemGridCell(item: .potionFlask, quantity: 10, showNewBadge: true)
                }
                .background(Color.black)
            },
            name: "ItemGridCell_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ItemDetailsView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            ItemDetailsView(
                    viewModel: assembler.resolver.itemDetailsViewModel(item: BaseItem.gear),
                )
            },
            name: "ItemDetailsView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_GoalProgressBar_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack(spacing: 16) {
                    GoalProgressBar(value: 0, total: 100)
                    GoalProgressBar(value: 50, total: 100)
                    GoalProgressBar(value: 1000, total: 100)
                    GoalProgressBar(value: 1, total: 1000)
                    GoalProgressBar(value: 10, total: 1000)
                }
                .padding(16)
            },
            name: "GoalProgressBar_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_EssenceView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                HStack {
                    EssenceView(essence: .dark)
                    EssenceView(essence: .light)
                }
            },
            name: "EssenceView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_EncyclopediaView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            EncyclopediaView(viewModel: assembler.resolver.encyclopediaViewModel(entry: .root))
            },
            name: "EncyclopediaView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_CreationView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            CreationView(viewModel: assembler.resolver.creationViewModel())
            },
            name: "CreationView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ContentView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            ContentView(viewModel: assembler.resolver.contentViewModel())
                    .environment(\.resolver, assembler.resolver)
            },
            name: "ContentView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_CardBackground_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                CardBackground()
                    .padding(16)
            },
            name: "CardBackground_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_CapsuleButtonStyle_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack(spacing: 16) {
                    Button("Primary") {}
                        .buttonStyle(CapsuleButtonStyle())
                    Button("Custom") {}
                        .buttonStyle(CapsuleButtonStyle(foreground: .black, background: .yellow, pressedBackground: .orange))
                }
                .padding()
            },
            name: "Capsule Button Style",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_AvatarView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    HStack {
                        ForEach(AvatarView.Size.allCases) { size in
                            AvatarView(
                                text: "AB",
                                image: nil,
                                border: .orange,
                                size: size,
                            )
                        }
                    }
                    HStack {
                        ForEach(AvatarView.Size.allCases) { size in
                            AvatarView(
                                text: "AP",
                                image: Asset.BaseItem.apple.swiftUIImage,
                                border: .orange,
                                size: size,
                            )
                        }
                    }
                    AvatarView(
                        text: "New",
                        image: nil,
                        border: .green,
                        showNewBadge: true,
                        size: .medium,
                    )
                }
            },
            name: "AvatarView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_AvatarStack_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                VStack {
                    AvatarStack(
                        avatars: [
                            AvatarView(text: "AB", image: nil, border: .orange, size: .small),
                            AvatarView(text: "CD", image: nil, border: .blue, size: .small),
                            AvatarView(text: "EF", image: nil, border: .green, size: .small),
                        ],
                        size: .small,
                    )
                    AvatarStack(
                        avatars: [
                            AvatarView(text: "AB", image: nil, border: .orange, size: .large),
                            AvatarView(text: "CD", image: nil, border: .blue, size: .large),
                        ],
                        size: .large,
                    )
                }
            },
            name: "AvatarStack_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_Artifacts_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                HStack(spacing: 8) {
                    ArtifactView(
                        artifact: .init(type: .frictionlessGear, quality: .junk)
                    )
                    ArtifactView(
                        artifact: .init(type: .frictionlessGear, quality: .exceptional)
                    )
                }
            },
            name: "Artifacts",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_ArtifactDetail_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            ArtifactDetailView(
                    viewModel: assembler.resolver.artifactDetailViewModel(artifact: .init(type: .frictionlessGear, quality: .good))
                )
            },
            name: "Artifact Detail",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_AchievementsView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            AchievementsView(viewModel: assembler.resolver.achievementsViewModel())
            },
            name: "AchievementsView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }

    func test_AchievementDetailsView_0_Preview() {        
        let prefireSnapshot = PrefireSnapshot(
            {
                let assembler = ItemsAssembly.testing()
            VStack {
                    AchievementDetailsView(
                        viewModel: assembler.resolver.achievementDetailsViewModel(achievement: .items10)
                    )
                    .background(CardBackground())
                    AchievementDetailsView(
                        viewModel: assembler.resolver.achievementDetailsViewModel(achievement: .items100)
                    )
                    .background(CardBackground())
                }
                .padding(16)
            },
            name: "AchievementDetailsView_0",
            isScreen: true,
            device: deviceConfig
        )

        if let failure = assertSnapshots(for: prefireSnapshot) {
            XCTFail(failure)
        }
    }
    // MARK: Private

    private func assertSnapshots<Content: SwiftUI.View>(for prefireSnapshot: PrefireSnapshot<Content>) -> String? {
        guard !snapshotDevices.isEmpty else {
            return assertSnapshot(for: prefireSnapshot)
        }

        for deviceName in snapshotDevices {
            var snapshot = prefireSnapshot
            guard let device: DeviceConfig = PreviewDevice(rawValue: deviceName).snapshotDevice() else {
                fatalError("Unknown device name from configuration file: \(deviceName)")
            }

            snapshot.name = "\(prefireSnapshot.name)-\(deviceName)"
            snapshot.device = device

            // Ignore specific device safe area
            snapshot.device.safeArea = .zero

            // Ignore specific device display scale
            snapshot.traits = UITraitCollection(displayScale: 2.0)

            if let failure = assertSnapshot(for: snapshot) {
                XCTFail(failure)
            }
        }

        return nil
    }

    private func assertSnapshot<Content: SwiftUI.View>(for prefireSnapshot: PrefireSnapshot<Content>) -> String? {
        let (previewView, preferences) = prefireSnapshot.loadViewWithPreferences()

        let failure = verifySnapshot(
            of: previewView,
            as: .wait(
                for: preferences.delay,
                on: .image(
                    precision: preferences.precision,
                    perceptualPrecision: preferences.perceptualPrecision,
                    layout: prefireSnapshot.isScreen ? .device(config: prefireSnapshot.device.imageConfig) : .sizeThatFits,
                    traits: prefireSnapshot.traits
                )
            ),
            record: preferences.record,
            testName: prefireSnapshot.name
        )

        #if canImport(AccessibilitySnapshot)
            let vc = UIHostingController(rootView: previewView)
            vc.view.frame = UIScreen.main.bounds

            SnapshotTesting.assertSnapshot(
                matching: vc,
                as: .wait(for: preferences.delay, on: .accessibilityImage(showActivationPoints: .always)),
                testName: prefireSnapshot.name + ".accessibility"
            )
        #endif
        return failure
    }

    /// Check environments to avoid problems with snapshots on different devices or OS.
    private func checkEnvironments() {
        if let simulatorDevice, let deviceModel = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            guard deviceModel.contains(simulatorDevice) else {
                fatalError("Switch to using \(simulatorDevice) for these tests. (You are using \(deviceModel))")
            }
        }

        if let requiredOSVersion {
            let osVersion = ProcessInfo().operatingSystemVersion
            guard osVersion.majorVersion == requiredOSVersion else {
                fatalError("Switch to iOS \(requiredOSVersion) for these tests. (You are using \(osVersion))")
            }
        }
    }
}

// MARK: - SnapshotTesting + Extensions

private extension DeviceConfig {
    var imageConfig: ViewImageConfig { ViewImageConfig(safeArea: safeArea, size: size, traits: traits) }
}

private extension ViewImageConfig {
    var deviceConfig: DeviceConfig { DeviceConfig(safeArea: safeArea, size: size, traits: traits) }
}

private extension PreviewDevice {
    func snapshotDevice() -> ViewImageConfig? {
        switch rawValue {
        #if os(iOS)
        case "iPhone 16 Pro Max", "iPhone 15 Pro Max", "iPhone 14 Pro Max", "iPhone 13 Pro Max", "iPhone 12 Pro Max":
            return .iPhone13ProMax
        case "iPhone 16 Pro", "iPhone 15 Pro", "iPhone 14 Pro", "iPhone 13 Pro", "iPhone 12 Pro":
            return .iPhone13Pro
        case "iPhone 16", "iPhone 15", "iPhone 14", "iPhone 13", "iPhone 12", "iPhone 11", "iPhone 10", "iPhone X":
            return .iPhoneX
        case "iPhone 6", "iPhone 6s", "iPhone 7", "iPhone 8", "iPhone SE (2nd generation)", "iPhone SE (3rd generation)":
            return .iPhone8
        case "iPhone 6 Plus", "iPhone 6s Plus", "iPhone 8 Plus":
            return .iPhone8Plus
        case "iPhone SE (1st generation)":
            return .iPhoneSe
        case "iPad":
            return .iPad10_2
        case "iPad Mini":
            return .iPadMini
        case "iPad Pro 11":
            return .iPadPro11
        case "iPad Pro 12.9":
            return .iPadPro12_9
        #elseif os(tvOS)
        case "Apple TV":
            return .tv
        #endif
        default: return nil
        }
    }

    func snapshotDevice() -> DeviceConfig? {
        (self.snapshotDevice())?.deviceConfig
    }
}