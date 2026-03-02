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
}
