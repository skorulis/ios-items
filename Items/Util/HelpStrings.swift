//Created by Alexander Skorulis on 2/3/2026.

import Foundation

enum HelpStrings {

    static let warehouse = """
    The Warehouse is your inventory of discovered items and artifacts.
    Items are grouped by quality. Tap an item or artifact to view its details.
    New discoveries are marked until you view them. Items here can be used in sacrifices and other activities.
    """

    static let recipeList = """
    The Sacrifices screen lets you define rules for what items will be sacrificed on the next item generation.
    Each time an item is generated it will pick the first sacrifice option which has ingredients in your warehouse and consume them.
    Sacrificing low quality items helps to create specific higher quality ones.
    """

    static let research = """
    Research unlocks knowledge about items over time. Select an item from your warehouse to start researching it; progress begins immediately and is shown in the bar.
    
    Each research level takes twice as long as the previous one, starting at 2 minutes for the first level. Progress continues in real time even when the app is closed or in the background.
    
    Only one item can be researched at a time. Switching to another item pauses the current one; selecting it again resumes from where you left off. Higher research levels unlock essences and improve item discovery and artifact chances.
    """

    static let artifacts = """
    Artifacts are unique items that give special bonuses when equipped in the warehouse.
    """
}
