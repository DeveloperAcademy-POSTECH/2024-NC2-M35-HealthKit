//
//  WalkAndCalWidgetBundle.swift
//  WalkAndCalWidget
//
//  Created by Giwoo Kim on 6/11/24.
//

import WidgetKit
import SwiftUI


@available(iOSApplicationExtension 17.0, *)
@main

struct WalkAndCalWidgetBundle: WidgetBundle {
    var body: some Widget {
        
        WalkAndCalWidget()
        WalkAndCalWidgetLiveActivity()
    }
}
