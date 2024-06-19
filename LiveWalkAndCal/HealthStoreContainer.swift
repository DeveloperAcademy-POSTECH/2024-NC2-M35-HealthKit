//
//  HealthStoreContainer.swift
//  LiveWalkAndCal
//
//  Created by Giwoo Kim on 6/11/24.
//

import Foundation

import HealthKit

protocol HealthStoreContainer {
    // A required property that contains the health store.
    var healthStore: HKHealthStore! { get set }
}

class HealthStoreProvider: ObservableObject {
    @Published var healthStore = HKHealthStore()
}

