//
//  ContentView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/2/24.
//

import Foundation
import SwiftUI


struct MenuView: View {
    @StateObject var locationManager = LocationManager()
    @State private var isLoadingWeatherView = false
    
    var body: some View {
        Text("Hello")
        
    }
}

#Preview {
    MenuView()
}
