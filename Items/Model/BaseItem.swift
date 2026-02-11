//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Simple items that only have quantity
enum BaseItem: Hashable, Equatable, CaseIterable, Identifiable {
    case apple
    case goldCoin
    case woodenChair
    case rubberDuck
    case lavaLamp
    case typewriter
    case cactus
    case vinylRecord
    case snowGlobe
    case umbrella
    case telescope
    case toaster
    case bowlingBall
    case hourglass
    case compass
    
    var id: Self { self }
    
    var acronym: String {
        switch self {
        case .apple: return "AP"
        case .goldCoin: return "GC"
        case .woodenChair: return "WC"
        case .rubberDuck: return "RD"
        case .lavaLamp: return "LL"
        case .typewriter: return "TW"
        case .cactus: return "CA"
        case .vinylRecord: return "VR"
        case .snowGlobe: return "SG"
        case .umbrella: return "UM"
        case .telescope: return "TS"
        case .toaster: return "TO"
        case .bowlingBall: return "BB"
        case .hourglass: return "HG"
        case .compass: return "CP"
        }
    }
}
