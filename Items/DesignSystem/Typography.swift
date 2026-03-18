import SwiftUI

struct Typography {

    static let largeTitle: Font = FontName.bold.font(30)
    static let title: Font = FontName.semibold.font(24)
    static let subheadline: Font = FontName.regular.font(15)
    static let body: Font = FontName.regular.font(16)
    static let caption: Font = FontName.regular.font(12)
    static let button: Font = FontName.semibold.font(17)
    static let monospaceBadge: Font = FontName.semibold.font(12)
}

extension Font {
    static var appLargeTitle: Font { Typography.largeTitle }
    static var appTitle: Font { Typography.title }
    static var appSubheadline: Font { Typography.subheadline }
    static var appBody: Font { Typography.body }
    static var appCaption: Font { Typography.caption }
    static var appButton: Font { Typography.button }
    static var appMonospaceBadge: Font { Typography.monospaceBadge }
}

public enum FontName: String, CaseIterable {

    case regular = "Rubik-Regular"
    case semibold = "Rubik-SemiBold"
    case bold = "Rubik-Bold"

    public func font(_ size: CGFloat) -> Font {
        _ = FontName.registerFontsOnce
        return Font.custom(rawValue, size: size)
    }

    var ext: String {
        return "ttf"
    }

    var name: String { rawValue }

}

private extension FontName {

    private static let registerFontsOnce: () = {
#if canImport(UIKit)
        _ = UIFont.familyNames
#endif

        for font in allCases {
            Bundle.main.registerFont(name: font.rawValue, ext: font.ext)
        }
    }()

}

public extension Bundle {

    static var fontFullNames: [String: String] = [:]

    func registerFont(name: String, ext: String) {
        guard let url = url(forResource: name, withExtension: ext) else {
            fatalError("Could not load font file \(name).\(ext)")
        }
        guard let data = try? Data(contentsOf: url),
              let dataRef = CGDataProvider(data: data as CFData),
              let font = CGFont(dataRef) else {
            fatalError("Could not create font for \(name).\(ext)")
        }
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            print(error!.takeUnretainedValue())
        }

        guard let full = font.fullName as? String else { return }
        Self.fontFullNames[name] = full

    }

}
