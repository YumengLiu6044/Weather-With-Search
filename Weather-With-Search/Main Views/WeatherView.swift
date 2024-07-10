//
//  ContentView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/2/24.
//

import SwiftUI
import CoreLocation
import Shimmer


struct WeatherView: View {
    
    var weatherManager = WeatherManager()
    
    var response: WeatherData
    var cityName: String
    @Binding var preferredUnit: UnitTemperature
    
    @State private var maxTemperature: Double = 40.0
    @State private var minTemperature: Double = 11.0
    
    @State private var hourWeatherArray     =   SampleData.sampleHourWeatherArray
    @State private var dayWeatherArray      =   SampleData.sampleDayWeatherArray
    @State private var currentWeather       =   SampleData.sampleCurrentWeather
    
    @State private var isVisible            =   false
    @State private var isLoading            =   true
    @State private var isDay                =   true
    
    var body: some View {
        ZStack {
            AnimatedLinearGradient(isDay: $isDay)
                .ignoresSafeArea()
            
            if isVisible {
                VStack(spacing: 20) {
                    Text(cityName)
                        .font(.system(size: 50))
                        .fontWeight(.semibold)
                        .scaledToFit()
                        .minimumScaleFactor(0.3)
                        .foregroundStyle(Color(.white))
                        .shadow(radius: 10)
                        .transition(.blurReplace())
                        .animation(.easeIn, value: cityName)
                    
                    
                    CurrentWeatherView(currentWeather: currentWeather, preferredUnit: $preferredUnit)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 5){
                            ForEach(hourWeatherArray) { day in
                                HourRowItemView(preferredUnit: $preferredUnit, hourWeatherItem: day)
                                    .scrollTransition {
                                        content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                    }
                                
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .padding(10)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    
                    
                    ScrollView(.vertical) {
                        VStack(spacing: 10) {
                            ForEach(dayWeatherArray) {
                                day in
                                DayWeatherRowView(dayWeatherItem: day, maxTemperature: maxTemperature, minTemperature: minTemperature, preferredUnit: $preferredUnit)
                                    .scrollTransition {
                                        content, phase in
                                        content
                                            .opacity(phase.isIdentity ? 1 : 0)
                                    }
                            }
                        }
                        .padding(.vertical, 10)
                        .scrollTargetLayout()
                        
                    }
                    .scrollTargetBehavior(.viewAligned)
                    .background(.ultraThinMaterial)
                    .clipShape(.rect(cornerRadius: 10))
                    
                }
                .padding(20.0)
                .transition(.backslide)
            }
            
            
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
        .task {
            loadWeather()
        }
    }
    
    private func loadWeather() {
        maxTemperature = response.daily.temperature_2m_max.max() ?? 40
        minTemperature = response.daily.temperature_2m_min.min() ?? 11

        currentWeather = loadCurrentWeather(response)
        hourWeatherArray = loadHourWeather(response)
        dayWeatherArray = loadDailyWeather(response)
        
        isDay = response.current.is_day == 1
        isLoading = false
        
    }
    
}

