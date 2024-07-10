//
//  DayWeatherRowView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/3/24.
//

import SwiftUI
import Shimmer

struct DayWeatherRowView: View {
    var dayWeatherItem: DayWeatherItem = SampleData.sampleDayWeatherArray[0]
    
    var maxTemperature: Double
    var minTemperature: Double
    
    @Binding var preferredUnit: UnitTemperature
    @State private var isLoading = true
    
    var body: some View {
        HStack {
            OnlineImageView(imageURL: dayWeatherItem.weatherIconName, isLoading: $isLoading)
                .frame(width:45)
            
            .padding(.trailing, 10.0)
            
            Text(dayWeatherItem.dayName)
                .shimmering(active: isLoading)
            
            Spacer()
            
            GaugeRow(gaugeData: GaugeData(
                minimunValue: convertTemperature(from: Float(self.minTemperature), of: dayWeatherItem.temperatureUnit, to: preferredUnit),
                maximimValue: convertTemperature(from: Float(self.maxTemperature), of: dayWeatherItem.temperatureUnit, to: preferredUnit),
                minimunTrackValue: convertTemperature(from: Float(dayWeatherItem.minTemperature), of: dayWeatherItem.temperatureUnit, to: preferredUnit),
                maximimTrackValue: convertTemperature(from: Float(dayWeatherItem.maxTemperature), of: dayWeatherItem.temperatureUnit, to: preferredUnit)))
                .frame(width: 200, height: 10)
                .shimmering(active: isLoading)
                
                
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .font(.title2)
        .foregroundStyle(.white)
        .shadow(radius: 10)
        .listRowSeparator(.hidden)
        .listRowBackground(Rectangle().foregroundStyle(.ultraThinMaterial))
        .padding(.horizontal, 10.0)
        
    }
    
}



#Preview {
    DayWeatherRowView(maxTemperature: 40.0, minTemperature: 11.0, preferredUnit: .constant(.celsius))
        .preferredColorScheme(.light)
}
