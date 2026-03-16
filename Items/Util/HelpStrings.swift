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
    Research unlocks knowledge about items over time. Select an item from your warehouse to start researching it; progress begins immediately and is shown in the bar.

    Each research level takes twice as long as the previous one, starting at 2 minutes for the first level. Progress continues in real time even when the app is closed or in the background.

    Only one item can be researched at a time. Switching to another item pauses the current one; selecting it again resumes from where you left off. Higher research levels unlock essences and improve item discovery and artifact chances.
    """

    static let artifacts = """
    Artifacts are unique items that give special bonuses when equipped in the warehouse.
    """
}
// swiftlint:enable line_length
