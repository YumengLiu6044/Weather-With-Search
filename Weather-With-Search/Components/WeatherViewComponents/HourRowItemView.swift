//
//  RowItemView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/3/24.
//

import SwiftUI
import Shimmer

struct HourRowItemView: View {
    
    @State private var isLoading = true
    @Binding var preferredUnit: UnitTemperature
    var hourWeatherItem: HourWeatherItem = SampleData.sampleHourWeatherArray[0]
    
    var body: some View {
        VStack{
            Text(hourWeatherItem.hour)
                .shimmering(active: isLoading)

            OnlineImageView(imageURL: hourWeatherItem.weatherIconName, isLoading: $isLoading)
                .frame(width:50)
                
            Text(showTemperature(from: hourWeatherItem.temperature, of: hourWeatherItem.temperatureUnit, to: preferredUnit))
                .shimmering(active: isLoading)
            
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .font(.title2)
        .foregroundStyle(Color(.white))
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        .padding(5.0)
        .clipShape(.rect(cornerRadius: 7))
        
        
    }
}

#Preview {
    HourRowItemView(preferredUnit: .constant(.celsius))
        .preferredColorScheme(.dark)
}
