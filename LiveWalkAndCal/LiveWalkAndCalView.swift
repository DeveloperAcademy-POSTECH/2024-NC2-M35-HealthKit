//
//  LiveWalkAndCalView.swift
//  LiveWalkAndCal
//
//  Created by Giwoo Kim on 6/11/24.
//

import Foundation
import SwiftUI
import HealthKit
import ActivityKit


struct LiveWalkAndCalView : View {
    @EnvironmentObject var   healthStoreProvider : HealthStoreProvider
    
    @ObservedObject var calorieManager = CalorieManager()
    @State var calorieBurned : Double?
    @State var notificationPublisher = NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
    @State var inputCal : Double = 50
    @State var inputTime : Double = 30
    @State var startTime : Date?
    @State  var isStarted : Bool = false
    @State var isWidgetActive : Bool = false
    @State var remainingTime: Double?
    var body: some View{
        
        
        NavigationView {
            VStack {
                Image("BurnItImage")
                    .padding()
                    .frame(alignment: .center)
                Image("BurnUpYourDayString")
                    .padding()
                    .frame(alignment: .center)
               
                GroupBox{
                    VStack(alignment: .leading){
                        HStack {
                            Text("목표칼로리:")
                                .font(.headline)
                            TextField("숫자", value: $inputCal, formatter: NumberFormatter.integerFormatter)
                                .keyboardType(.numberPad)
                                .padding()
                                .border(Color.gray, width: 0.5)
                                .frame(width: 100)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: inputCal  ) { newValue in
                                    // 3자리 숫자 제한
                                    if newValue > 500 {
                                        inputCal = 500
                                    } else if newValue < 0 {
                                        inputCal = 0
                                    }
                                    
                                }
                            Stepper("", value: $inputCal)
                                .labelsHidden()
                            
                        }
                        
                        HStack{
                            Text("활동 시간  : ")
                                .font(.headline)
                            
                            TextField("숫자", value: $inputTime, formatter: NumberFormatter())
                                .keyboardType(.numberPad)
                                .padding()
                                .border(Color.gray, width: 0.5)
                                .frame(width: 100) // TextField의 크기를 조절합니다.
                                .multilineTextAlignment(.trailing)
                                .onChange(of: inputTime ) { newValue in
                                    // 3자리 숫자 제한
                                    if newValue > 90 {
                                        inputTime = 90
                                    } else if newValue < 0 {
                                        inputTime = 0
                                    }
                                    
                                }
                            Stepper("", value: $inputTime)
                                .labelsHidden()
                        }
                        
                    }
                }
                // 나중에 수정 네비게이션링크가 맞는지 모르겠다????
                NavigationLink(destination: EnergyBurnedStatusView (targetCal: $inputCal,  measureTime: $inputTime, startTime: startTime ?? Date.now ) , isActive: $isStarted ) {
                    EmptyView()
                }
                
  
                
                Button(action: {
                   
                    if isWidgetActive == false {
                        isWidgetActive = true
                        isStarted = true
                        
                       
                        saveIsWidgetActiveToUserDefaults(isWidgetActive: isWidgetActive)
                        let startTime = Date()
                        saveStartTimeToUserDefaults(startTime: startTime)
                        self.startTime = startTime
                        
                        print("startime \(startTime)")
                        let endTime = Calendar.current.date(byAdding: .minute, value: Int(inputTime), to: startTime)!
                        print("endTime \(endTime)")
                        saveEndTimeToUserDefaults(endTime: endTime)
//                        let testst = loadStartTimeFromUserDefaults()
//                        let tested = loadEndTimeFromUserDefaults()
//                        print("testst isWidget == false  :\(testst)")
//                        print("tested isWidget == false : \(tested)")
//                        
                        saveInputCalToUserDefaults(inputCal: inputCal)
                        
                        ActivityManager.shared.startLiveActivity()
                    } else {
                        isWidgetActive = false
                        isStarted = false
                        
                        //데이터 초기화
                        saveIsWidgetActiveToUserDefaults(isWidgetActive: isWidgetActive)
                        let startTime = Date()
                        saveStartTimeToUserDefaults(startTime: startTime)
                      
                        let endTime = startTime
                        saveEndTimeToUserDefaults(endTime: endTime)
                        ActivityManager.shared.stopLiveActivity()
//
//                        let testst = loadStartTimeFromUserDefaults()
//                        let tested = loadEndTimeFromUserDefaults()
//                        
//                        print("testst  isWidget == true :\(testst)")
//                        print("tested isWidget == true: \(tested)")
                       
                    }
                    
                }) {
                    Text(isWidgetActive ? "종료" : "시작하기")
                        .font(.title) // 텍스트 크기 조정
                        .padding()
                        .frame(width: 340, height: 60) // 버튼 크기 조정
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
            }
            
            
        }  
        .onAppear{
            UserDefaults.init(suiteName: "group.com.giwoo.andy.LiveAndWalk")
            CalorieManager.shared.requestAuthorization()
             
            requestAuthorization()
            
        }
        .onReceive(notificationPublisher){_ in
            print("App entered foreground")
            

        }
       
        
      
    } 
   
    
}

//#Preview {
//    LiveWalkAndCalView(stepCount: 100, calorieBurned: 10.00)
//    
//}
