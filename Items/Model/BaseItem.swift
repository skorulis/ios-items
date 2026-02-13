//Created by Alexander Skorulis on 10/2/2026.

import Foundation

/// Simple items that only have quantity
enum BaseItem: Hashable, Equatable, CaseIterable, Identifiable {
    case apple
    case rock
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
        case .apple:
            <#code#>
        case .rock:
            <#code#>
        case .goldCoin:
            <#code#>
        case .woodenChair:
            <#code#>
        case .rubberDuck:
            <#code#>
        case .lavaLamp:
            <#code#>
        case .typewriter:
            <#code#>
        case .cactus:
            <#code#>
        case .vinylRecord:
            <#code#>
        case .snowGlobe:
            <#code#>
        case .umbrella:
            <#code#>
        case .telescope:
            <#code#>
        case .toaster:
            <#code#>
        case .bowlingBall:
            <#code#>
        case .hourglass:
            <#code#>
        case .compass:
            <#code#>
        }
        return .junk
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
