// App-specific: maps BaseItem to Asset images.

import Foundation
import Models
import SwiftUI

extension BaseItem {
    public var image: Image? {
        switch self {
        case .apple:
            return Asset.BaseItem.apple.swiftUIImage
        case .rock:
            return Asset.BaseItem.rock.swiftUIImage
        case .gear:
            return Asset.BaseItem.gear.swiftUIImage
        case .potionFlask:
            return Asset.BaseItem.flask.swiftUIImage
        case .copperFlorin:
            return Asset.BaseItem.copperCoin.swiftUIImage
        case .hourglass:
            return Asset.BaseItem.hourglass.swiftUIImage
        case .silverFlorin:
            return Asset.BaseItem.silverCoin.swiftUIImage
        case .goldFlorin:
            return Asset.BaseItem.goldCoin.swiftUIImage
        case .lens:
            return Asset.BaseItem.lens.swiftUIImage
        case .humanSkull:
            return Asset.BaseItem.humanSkull.swiftUIImage
        case .quartzCrystal:
            return Asset.BaseItem.quartzCrystal.swiftUIImage
        case .steelArrowhead:
            return Asset.BaseItem.steelArrowhead.swiftUIImage
        case .book:
            return Asset.BaseItem.book.swiftUIImage
        case .jadeFigurine:
            return Asset.BaseItem.jadeFiguring.swiftUIImage
        case .merchantSigil:
            return Asset.BaseItem.merchantSigil.swiftUIImage
        case .giantThorn:
            return nil
        case .portalShard:
            return Asset.BaseItem.portalShard.swiftUIImage
        case .whetstone:
            return Asset.BaseItem.whetstone.swiftUIImage
        case .embuedChalk:
            return Asset.BaseItem.embuedChalk.swiftUIImage
        case .metalBloom:
            return nil
        case .soulEmber:
            return nil
        case .anchorStone:
            return nil
        case .waxSeal:
            return nil
        case .memorySeed:
            return nil
        case .nullLantern:
            return nil
        case .heartgear:
            return nil
        case .nullWeaveCloak:
            return nil
        case .axisHeart:
            return nil
        case .oathforgedChain:
            return nil
        case .sunwellPhial:
            return nil
        }
    }
}
