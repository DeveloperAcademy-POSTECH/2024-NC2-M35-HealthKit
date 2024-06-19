//
//  ContentView.swift
//  LiveWalkAndCal
//
//  Created by Giwoo Kim on 6/11/24.
//

import SwiftUI

struct ContentView: View {
   
    @EnvironmentObject private var healthStoreProvider : HealthStoreProvider

   

    var body: some View {
        VStack {
           LiveWalkAndCalView()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
