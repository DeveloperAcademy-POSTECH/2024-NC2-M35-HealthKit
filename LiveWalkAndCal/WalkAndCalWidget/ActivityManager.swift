//
//  ActivityManager.swift
//  WalkAndCalWidgetExtension
//
//  Created by Giwoo Kim on 6/12/24.
//

import Foundation

import ActivityKit
import HealthKit
import SwiftUI

public class ActivityManager {
    public static let shared = ActivityManager()
    private var currentActivity: Activity<WalkAndCalWidgetAttributes>?
    @ObservedObject var calorieManager = CalorieManager()
    
    let startDate = loadStartTimeFromUserDefaults()
    let endDate = loadEndTimeFromUserDefaults()
    let targetCal = loadInputCalFromUserDefaults()
    
    var burnedCal : Double = 0
    var remainingTime :TimeInterval = 0
    var timer: Timer?
    private init() {
        
        CalorieManager.shared.requestAuthorization()
        CalorieManager.shared.startTimer()
        
    }
    
    public func startLiveActivity() {
        let now = Date()
        let remainingTime = endDate.timeIntervalSince1970 - Date().timeIntervalSince1970
        
        // Create the descriptor.
        
        print("activity - startDate: \(startDate)")
        print("activity - endDate: \(endDate)")
        print("activity - targetCal: \(targetCal)")
        print("activity - remainingTime: \(remainingTime)")
        burnedCal = CalorieManager.shared.calorieBurned
        
        let initialContentState = WalkAndCalWidgetAttributes.ContentState(emoji: "🤩",remainingTime: remainingTime, burnedCal: burnedCal)
        let activityAttributes = WalkAndCalWidgetAttributes(name: "Health Activity")
        
        let staleDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let initialActivityContent = ActivityContent(state: initialContentState, staleDate: staleDate)
        if currentActivity != nil { return }
        do {
            let activity = try Activity<WalkAndCalWidgetAttributes>.request(
                attributes: activityAttributes,
                content: initialActivityContent,
                pushType: nil)
            self.currentActivity = activity
            print("Requested a Live Activity with ID: \(activity.id)")
            
            
        } catch {
            print("Error requesting live activity: \(error.localizedDescription)")
        }
        self.startTimer()
    }
    //   public func end(_ content: ActivityContent<Activity<Attributes>.ContentState>?, dismissalPolicy: ActivityUIDismissalPolicy = .default) async
    
    public func stopLiveActivity(){
        let initialContentState = WalkAndCalWidgetAttributes.ContentState(emoji: "🤩", remainingTime: 300, burnedCal: 30)
        let activityAttributes = WalkAndCalWidgetAttributes(name: "Health Activity")
        
        let staleDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let initialActivityContent = ActivityContent(state: initialContentState, staleDate: staleDate)
        
        if let currentActivity = self.currentActivity {
            print("The current live activity will stop")
            Task{
                await currentActivity.end(initialActivityContent, dismissalPolicy: .default)
                self.currentActivity = nil
            }
        } else {
            print("current live activity is not available now.I can't stop it ")
        }
        
        timer?.invalidate()
    }
    
    public func updateLiveActivity(emoji: String, remainingTime: TimeInterval, burnedCal : Double) {
        guard let activity = currentActivity else {
            print("No active activity to update")
            return
        }
        
        let updatedContentState = WalkAndCalWidgetAttributes.ContentState(emoji:  "🤩",remainingTime: remainingTime, burnedCal: burnedCal)
        let updatedActivityContent = ActivityContent(state: updatedContentState, staleDate: nil)
        
        Task {
            await activity.update( updatedActivityContent)
            print("Updated activity with new emoji: \(emoji)")
            
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 35, repeats: true) { _ in
            
       //     self.remainingTime = CalorieManager.shared.remainingTime
            self.burnedCal = CalorieManager.shared.calorieBurned
          
            let timeInterval = self.endDate.timeIntervalSince(Date())
            
            if timeInterval > 0 {
                self.remainingTime = timeInterval
            } else {
                self.remainingTime = 0
                self.timer?.invalidate()
            }
            self.updateLiveActivity(emoji: "🤩", remainingTime: self.remainingTime , burnedCal : self.burnedCal )
            
        }
    }
}
