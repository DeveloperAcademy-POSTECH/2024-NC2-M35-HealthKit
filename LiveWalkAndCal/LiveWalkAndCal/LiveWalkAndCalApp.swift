//
//  LiveWalkAndCalApp.swift
//  LiveWalkAndCal
//
//  Created by Giwoo Kim on 6/11/24.

import SwiftUI
import HealthKit

class AppInitializer {
    static let shared = AppInitializer()

    private init() {}

    func performInitialSetup() {
        // 복잡한 초기화 작업 수행
        print("앱 초기화 중...")
        // 예: 네트워크 요청, 데이터베이스 설정 등
        guard HKHealthStore.isHealthDataAvailable() else { fatalError("This app requires a device that supports HealthKit") }
        print("HealthKit Activated!")
      
    }
}

@main
struct LiveWalkAndCalApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @StateObject private var healthStoreProvider = HealthStoreProvider()

    init() {
            AppInitializer.shared.performInitialSetup()
        }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthStoreProvider)
                .onAppear{
                    let healthStore = healthStoreProvider.healthStore
                    // Create the heart rate and heartbeat type identifiers.
                    var sampleTypes = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                                           HKSeriesType.heartbeat(),
                                           HKQuantityType.quantityType(forIdentifier: .heartRateVariabilitySDNN)!
                                           
                                          ])
                    
                    if let stepCount  = HKObjectType.quantityType(forIdentifier: .stepCount) {
                        
                        sampleTypes.insert(stepCount)
                    }
                    if let walkingSpeed = HKObjectType.quantityType(forIdentifier: .walkingSpeed) {
                        sampleTypes.insert(walkingSpeed)
                    }
                    
                    if let walkingSpeedLength =  HKObjectType.quantityType(forIdentifier: .walkingStepLength) {
                        sampleTypes.insert(walkingSpeedLength)
                    }
                    
                    if let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) {
                        
                        sampleTypes.insert(distanceWalkingRunning)
                    }
                    if let caloriesType = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)  {
                        sampleTypes.insert(caloriesType)
                        }
                    let workoutType = HKObjectType.workoutType()
                    sampleTypes.insert(workoutType)
                        
                    
                    // 공유될수없음 toShare 따로  read 따로
                    //            if let walkingHeartRateAverage =   HKObjectType.quantityType(forIdentifier: .walkingHeartRateAverage) {
                    //                sampleTypes.insert(walkingHeartRateAverage)
                    //            }
                    // Request permission to read and write heart rate and heartbeat data.
                    healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes) { (success, error) in
                        print("Request Authorization -- Success: ", success, " Error: ", error ?? "nil")
                        // Handle authorization errors here.
                        
                        
                    }
                }
        }
        .onChange(of: scenePhase) { oldScenePhase, newScenePhase in
            switch newScenePhase {
            case .active:
                print("앱이 활성화됨")
            case .inactive:
                print("앱이 비활성화됨")
            case .background:
                print("앱이 백그라운드로 전환됨")
            @unknown default:
                print("알 수 없는 상태")
            }
        }
    }
}
