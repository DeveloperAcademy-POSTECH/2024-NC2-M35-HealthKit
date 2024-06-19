//
//  AppIntent.swift
//  WalkAndCalWidget
//
//  Created by Giwoo Kim on 6/11/24.
//

import WidgetKit
import AppIntents

@available(iOSApplicationExtension 17.0, *)
struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("Active Burned Calrorie ")
    
    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
