//
//  CurrentWeatherView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/3/24.
//

import SwiftUI

struct CurrentWeatherView: View {
    var currentWeather: CurrentWeather
    
    init(currentWeather: CurrentWeather) {
        self.currentWeather = currentWeather
        currentTime = getFormattedTime(from: Date(), with: "HH:mm:ss", for: self.currentWeather.timeZone)
    }
    @State private var isLoading    = true
    @State private var currentTime: String
    @State private var timer        = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
            HStack{
                VStack{
                    OnlineImageView(imageURL: currentWeather.weatherIconName, isLoading: $isLoading)
                        .frame(width: 50)
                    .padding([.top, .bottom, .trailing], 3.0)
                    
                    HStack {
                        Text(currentWeather.weatherName)
                        Text(currentWeather.presentTemperature())
                    }
                    .shimmering(active: isLoading)
                    .font(.title2)
                    .scaledToFit()
                    .minimumScaleFactor(0.5)
                }
                .padding()
                .background()
                .backgroundStyle(.ultraThinMaterial)
                .clipShape(.rect(cornerRadius: 10))
                
                
                Spacer()
                
                VStack(alignment: .trailing){
                    Text(currentTime)
                        .onReceive(timer) { _ in
                            updateTime()
                        }
                        .transition(.blurReplace())
                        .animation(.easeIn, value: currentTime)
                    
                    Text(currentWeather.dayName)
                    Text(currentWeather.date)
                }
                .font(.system(size: 35))
                .frame(alignment: .trailing)
                .shimmering(active: isLoading)
            }
                
        }
        .redacted(reason: isLoading ? .placeholder : [])
        .font(.system(size: 40))
        .foregroundStyle(.white)
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
    }
    
    private func updateTime() {
        self.currentTime = getFormattedTime(from: Date(), with: "HH:mm:ss", for: currentWeather.timeZone)
    }
}



#Preview {
    CurrentWeatherView(currentWeather: SampleData.sampleCurrentWeather)
}
