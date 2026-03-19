// Created by Alexander Skorulis on 2/3/2026.

import Foundation

// swiftlint:disable line_length
enum HelpStrings {

    static let warehouse = """
    The Warehouse is your inventory of discovered items and artifacts.
    Items are grouped by quality. Tap an item or artifact to view its details.
    New discoveries are marked until you view them. Items here can be used in sacrifices and other activities.
    """

    /// Help text for the Sacrifices feature (in-app help button and Encyclopedia).
    static let sacrifices = """
    Nothing from this dimension can go into the portal, but you can send discovered items back. This changes the frequency of the portal so different items are returned.

    Place items on the pentagram slots and turn "Sacrifices enabled" on. When you create an item, it will consume any available items set in the pentagram. Unlock more slots in the pentagram by upgrading the sacrifices feature.
    """

    static let recipeList = sacrifices

    static let research = """
    Research unlocks knowledge about items over time. Select an item from your warehouse to start researching it.

    Each research level takes exponentially longer, starting at 2 minutes for the first level.

    Only one item can be researched at a time, but resuming research will continue from where it left off. Higher research levels unlock essences and improve item discovery and artifact chances.
    """

    static let artifacts = """
    Artifacts are unique items that give special bonuses when equipped in the warehouse.
    """

    static let tradingPost = """
    The Trading Post lets you exchange items of the same quality tier for other items.
    Trade options will be randomly available and can be refreshed by spending Merchant Sigils.
    """

    static let tradingPostLevel2 = """
    Upgrading the Trading Post adds 1 extra trade offer each time the list is regenerated.
    """

    static let tradingPostLevel3 = """
    Upgrading the Trading Post adds 1 extra trade offer each time the list is regenerated.
    """
}
// swiftlint:enable line_length
