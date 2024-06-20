//
//  EngeryBurnedStatusView.swift
//  LiveWalkAndCal
//
//  Created by Giwoo Kim on 6/17/24.
//

import Foundation
import SwiftUI

struct EnergyBurnedStatusView : View{
    @Binding var targetCal : Double 
    @Binding var measureTime : Double
    
    var startTime: Date
    @ObservedObject var calorieManager = CalorieManager()
    
    @State var calorieBurned : Double = 50
    @State var remainingTime: Double = 0
    @State var level : Double = 0.5
    @State var levelProportionalToTime: Double = 1
   // calorieBurned는 추후에 Wideget과  LA LOCKSCREEN 모두에서 사용될 예정
                                        // update는  LA에서 하고 글로발리 파일로 저장하거나 읽을때마다 다른 View의 값들이 모두 바뀌게 조정해줘야함.
    @State var remainTime2 : Double?
    // 왜 init이 자주 호출될까????
    init(targetCal: Binding<Double>, measureTime: Binding<Double>, startTime: Date) {
        _targetCal = targetCal
        _measureTime = measureTime
        self.startTime = startTime
    //    print("passed value : \(self.targetCal) \(self.measureTime) \(startTime)")
    //    ActivityManager.shared.startLiveActivity()
    }
    
    
    var body: some View {
        VStack {
            if levelProportionalToTime  <= 0.5 {
                
                Image("PooImage").padding()
                Image("PooString").padding()
                
            } else if  levelProportionalToTime > 0.7 && levelProportionalToTime < 1.0  {
                
                Image("ThumbUpImage").padding()
                Image("GoodString").padding()
            } else {
                Image("BurnItImage").padding()
                Image("BurnItString").padding()
            }
//            Text("Calories Burned for debug \(calorieBurned, specifier: "%.0f")")
//            Text("잔여시간 for debug  \(CalorieManager.shared.remainingTime , specifier : "%.0f")")
//    
            Text("목표량")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment:.leading)
            GroupBox(){
                VStack {
                    HStack {
                        Text("활동칼로리")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("목표칼로리")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }   .padding(.horizontal)
                    
                    
                    EnergyBurnedShape(level: level)
                        .frame(height: 10)
                    
                    
                    
                    HStack {
                        Text("\(calorieBurned, specifier: "%.0f")")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(targetCal, specifier: "%.0f")")
                            .font(.footnote)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    } .padding(.horizontal)
                }
            }
            Text("잔여시간")
                .font(.title3)
                .frame(maxWidth: .infinity, alignment:.leading)
            
            GroupBox(){
                VStack {
                    HStack {
                        Text("설정시간")
                        
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("\(measureTime, specifier: "%.0f") 분")
                        
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    
                    let startDate = Date()
                    let endDate = Calendar.current.date(byAdding: .second, value: Int(measureTime * 60) , to: startDate)!
                    let dateRange = startDate...endDate
                    
                    HStack {
                        Text("잔여시간")
                        
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        
                        Text(" \(timeString(from: remainingTime) )" )
                        
                    } .onAppear {
                        updateRemainingTime(endDate: endDate)
                    }
                    
                    //위의 Timer.scheduleTimer.를 사용해서 Text하는것과 동시에 실행이 안되는 이유????
                    //                        Text(timerInterval: dateRange, countsDown: true)
                    //                         .font(.footnote)
                    //                        
                }
                .padding(.horizontal)
            }
            
            
        }.onAppear {
            CalorieManager.shared.requestAuthorization()
            CalorieManager.shared.updateData()
            calorieBurned = CalorieManager.shared.calorieBurned
        
            if targetCal > 0 {
                level = Double(calorieBurned) / Double(targetCal)
            //    print("level : \(level)")
            }
            else {
                print("error in targetCal")
            }
            levelProportionalToTime =  calorieBurned / targetCal  / (Double(measureTime * 60 ) - remainingTime + 10 )  * Double(measureTime * 60 )
        }
        .onChange(of: remainingTime) {
            
           
            calorieBurned = CalorieManager.shared.calorieBurned
            
            if targetCal > 0 {
                level = calorieBurned / targetCal
            //    print("level : \(level)")
            }
            else {
                print("error in targetCal")
            }
            levelProportionalToTime =  calorieBurned / ( targetCal ) / (Double(measureTime * 60 ) - remainingTime + 10) * Double(measureTime * 60 )
       
 //           print("levelpro \(levelProportionalToTime)  \(targetCal) \(measureTime) \(remainingTime)")
        }
        
    }
    private func updateRemainingTime(endDate: Date) {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            let currentTime = Date()
            let timeInterval = endDate.timeIntervalSince(currentTime)
            if timeInterval > 0 {
                remainingTime = timeInterval
            } else {
                remainingTime = 0
                timer.invalidate()
            }
        }
    }
    
}





func formatTime(date: Date) -> String {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .abbreviated
    formatter.allowedUnits = [.minute, .second]
    
    if let formattedString = formatter.string(from: Date(), to: date) {
        return formattedString
    } else {
        return ""
    }
}


@available(iOSApplicationExtension 17.0, *)
struct EnergyBurnedShape: View {
    var level: Double
    
    
    var body: some View {
        GeometryReader { geometry in
            let frame = geometry.frame(in: .local)
            let boxWidth = frame.width *  level
            
            RoundedRectangle(cornerRadius: 4)
                .foregroundStyle(Color.gray)
            
            RoundedRectangle(cornerRadius: 4)
                .frame(width: boxWidth)
                .foregroundStyle(Color.green)
        }
    }
}

@available(iOSApplicationExtension 17.0, *)
struct EnergyBurnedShape_Previews: PreviewProvider {
    static var previews: some View {
        EnergyBurnedShape(level: 0.5)
            .frame(height: 10
            )
            .previewLayout(.fixed(width: 160, height: 20))
    }
}
