//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Simple items that only have quantity
enum BaseItem: Hashable, Equatable, CaseIterable, Identifiable, Codable {
    
    // Junk
    case apple
    case rock
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
    
    // Common
    case goldCoin
    
    var id: Self { self }
    
    var name: String {
        return String(describing: self)
    }
    
    var acronym: String {
        switch self {
        case .apple: return "AP"
        case .rock: return "RK"
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
    
    var quality: ItemQuality {
        switch self {
        case .apple, .rock, .woodenChair, .rubberDuck, .lavaLamp, .typewriter, .cactus, .vinylRecord, .snowGlobe, .umbrella, .telescope, .toaster, .bowlingBall, .hourglass, .compass:
            return .junk
        case .goldCoin:
            return .common
        }
    }
    
    var essences: [Essence] {
        switch self {
        case .apple:
            return [.organic]
        case .rock:
            return []
        case .goldCoin:
            return []
        case .woodenChair:
            return [.organic]
        case .rubberDuck:
            return [.organic]
        case .lavaLamp:
            return [.technology]
        case .typewriter:
            return [.technology]
        case .cactus:
            return []
        case .vinylRecord:
            return [.technology]
        case .snowGlobe:
            return []
        case .umbrella:
            return []
        case .telescope:
            return [.technology]
        case .toaster:
            return [.technology]
        case .bowlingBall:
            return []
        case .hourglass:
            return []
        case .compass:
            return []
        }
    }
    
    var lore: [String] {
        switch self {
        case .apple:
            return ["Tastes good and keeps doctors away"]
        case .rock:
            return ["A stupid rock which may or may not repel tigers"]
        default:
            return []
        }
    }
}

