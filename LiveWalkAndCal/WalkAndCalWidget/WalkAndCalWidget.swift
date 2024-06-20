//
//  WalkAndCalWidget.swift
//  WalkAndCalWidget
//
//  Created by Giwoo Kim on 6/11/24.
//

import WidgetKit
import SwiftUI
import HealthKit
import os


let logger = Logger(subsystem: "com.giwoo.andy.LiveWalkAndCal.Widget", category: "widget")

@available(iOSApplicationExtension 17.0, *)
struct Provider: AppIntentTimelineProvider {
 
    func placeholder(in context: Context) -> SimpleEntry {
        CalorieManager.shared.updateData()
        let startDate = loadStartTimeFromUserDefaults()
        let endDate = loadEndTimeFromUserDefaults()
        let remainingTime = CalorieManager.shared.remainingTime
        let calorieBurned = CalorieManager.shared.calorieBurned
        let targetCal = loadInputCalFromUserDefaults()
        
        return SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), startDate: startDate, endDate: endDate
                           , remainingTime: remainingTime , calBurned: calorieBurned , targtCal: targetCal, place: "placeholder")
       
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        CalorieManager.shared.updateData()
        let startDate = loadStartTimeFromUserDefaults()
        let endDate = loadEndTimeFromUserDefaults()
        let now = Date()
        let remainingTime = endDate.timeIntervalSince(now)
        let calorieBurned = CalorieManager.shared.calorieBurned
        let targetCal = loadInputCalFromUserDefaults()
   
        
        return  SimpleEntry(date:now, configuration: configuration,startDate: startDate.addingTimeInterval(-60 * 10 ), endDate: endDate, remainingTime: remainingTime, calBurned: calorieBurned, targtCal: targetCal , place: "snapshot")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let startDate = loadStartTimeFromUserDefaults()
        let endDate = loadEndTimeFromUserDefaults()
        logger.log("time-line endDate \(endDate)")
        let targetCal = loadInputCalFromUserDefaults()

        CalorieManager.shared.updateData()
        let burnedCal = CalorieManager.shared.calorieBurned  //for test purpose add 30
     
        
        logger.info("timeline - startDate: \(startDate, privacy: .public)")
        logger.info("timeline - endDate: \(endDate, privacy: .public)")
        logger.info("timeline - targetCal: \(targetCal, privacy: .public)")
     
        
        var lastEntryDate: Date? = nil
        var remainingTime : TimeInterval = 0
        for i in 0..<2 {
            let minOffset = i
            let entryDate = Calendar.current.date(byAdding: .minute, value: minOffset, to: currentDate)!
            remainingTime = endDate.timeIntervalSince(entryDate)
            let entry = SimpleEntry(
                date: entryDate,
                configuration: configuration,
                startDate: startDate,
                endDate: endDate,
                remainingTime: remainingTime,
                calBurned: burnedCal,
                targtCal: targetCal,
                place: "timeline"
            )
            entries.append(entry)
            lastEntryDate = entryDate
        }

        if let lastEntryDate = lastEntryDate {
            return Timeline(entries: entries, policy: remainingTime > 0 ? .after(lastEntryDate) : .never)
        } else {
            // 만약 루프가 실행되지 않아 lastEntryDate가 nil인 경우에 대한 처리
            return Timeline(entries: entries, policy: .never)
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct SimpleEntry: TimelineEntry {
    
    let date: Date
    let configuration: ConfigurationAppIntent
    let startDate : Date
    let endDate : Date
    var remainingTime: TimeInterval
    var calBurned :Double
    let targtCal : Double
    var place : String
}

@available(iOSApplicationExtension 17.0, *)

struct WalkAndCalWidgetEntryView : View {
    var entry: Provider.Entry
  
  
    var body: some View {
        VStack {
            
//            Text("entry :\(entry.date)")
//            Text("시작 \(entry.startDate)")
//            Text("종료\(entry.endDate)")
            Text("잔여시간: \(timeString(from: entry.remainingTime))")
            Text("목표열량: \(Int(entry.targtCal))")
            Text("현재소비량 : \(Int(entry.calBurned))")
            
            Image("BurnItImage")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height:50, alignment: .bottom)
            
            Text("\(entry.place)")
        }
        
    }
}


@available(iOSApplicationExtension 17.0, *)


struct WalkAndCalWidget: Widget {
    let kind: String = "WalkAndCalWidget"
    var body: some WidgetConfiguration {
        
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            WalkAndCalWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
         
        }
    }
}
@available(iOSApplicationExtension 17.0, *)
extension ConfigurationAppIntent {
        static var smiley: ConfigurationAppIntent {
            let intent = ConfigurationAppIntent()
            intent.favoriteEmoji = "😀"
            return intent
        }
        
        static var starEyes: ConfigurationAppIntent {
            let intent = ConfigurationAppIntent()
            intent.favoriteEmoji = "🤩"
            return intent
        }
    }

 


   
//#Preview(as: .systemLarge) {
//  
//        WalkAndCalWidget()
//    
//} timeline: {
//
//  
//        SimpleEntry(date: .now, configuration: .smiley)
//        SimpleEntry(date: .now + 15 , configuration: .starEyes)
//     
//    
//}
