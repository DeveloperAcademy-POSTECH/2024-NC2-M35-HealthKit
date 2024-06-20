//
//  WalkAndCalWidgetLiveActivity.swift
//  WalkAndCalWidget
//
//  Created by Giwoo Kim on 6/11/24.
//

import ActivityKit
import WidgetKit
import SwiftUI
import HealthKit
import os

struct WalkAndCalWidgetAttributes: ActivityAttributes {

    
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
        var remainingTime: TimeInterval
        var burnedCal : Double
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}


struct WalkAndCalWidgetLiveActivity: Widget {
//    @State var currentDate : Date?
//    @State var startDate : Date?
//    @State var endDate : Date?
//    @State var remainingTime: TimeInterval?
//    @State var targetCal: Double?
//    @State var burnedCal: Double?
//    @ObservedObject var calorieManager = CalorieManager()
//    
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: WalkAndCalWidgetAttributes.self) { context in
            // Lock. screen/banner UI goes here
            VStack {
                
                Text("남은시간 \n \(timeString(from: context.state.remainingTime ?? 0))")
                Text("소모열량  \n \(context.state.burnedCal , specifier: "%.0f")")
                Text(context.state.emoji).frame(alignment: .center)
                Image("BurnItImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height:50, alignment: .bottom)
            }
       
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.yellow)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("잔여시간: \(timeString(from: context.state.remainingTime))")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("소모열량\(context.state.burnedCal , specifier: "%.0f")")
                        .foregroundColor(.yellow)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Image("BurnItImage")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height:50, alignment: .center)
                    
                     
                    // more content
                }
            } compactLeading: {
                Text("\(timeString(from: context.state.remainingTime))")
                    .foregroundColor(.white)
            } compactTrailing: {
                Text("\(context.state.burnedCal, specifier: "%.0f") Kcal")
                    .backgroundStyle(.white)
            } minimal: {
                Image("BurnItImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height:30)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}



extension WalkAndCalWidgetAttributes {
    fileprivate static var preview: WalkAndCalWidgetAttributes {
        WalkAndCalWidgetAttributes(name: "World")
    }
}

extension WalkAndCalWidgetAttributes.ContentState {
    fileprivate static var smiley: WalkAndCalWidgetAttributes.ContentState {
        WalkAndCalWidgetAttributes.ContentState(emoji: "😀", remainingTime: 300, burnedCal: 30)
     }
     
    fileprivate static var starEyes: WalkAndCalWidgetAttributes.ContentState {
         WalkAndCalWidgetAttributes.ContentState(emoji: "🤩",remainingTime: 300, burnedCal: 40)
     }
}

#Preview("Notification", as: .content, using: WalkAndCalWidgetAttributes.preview) {
    WalkAndCalWidgetLiveActivity()
} contentStates: {
    WalkAndCalWidgetAttributes.ContentState.smiley
    WalkAndCalWidgetAttributes.ContentState.starEyes
}
