//
//  CityRowView.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/8/24.
//

import SwiftUI
import CoreLocation

struct CityRowView: View {
    
    var weatherManager: WeatherManager = WeatherManager()
    var city: String
    @State private var isLoading: Bool = false
    @State private var response: WeatherData?
    @State private var currentWeather: CurrentWeather = SampleData.sampleCurrentWeather
    @State private var location: CLLocationCoordinate2D?
    @State private var isDay: Bool = true
    
    var body: some View {
        HStack {
            Text(city)
                .font(.title)
            
            Spacer()
            VStack{
                OnlineImageView(imageURL: currentWeather.weatherIconName, isLoading: $isLoading)
                    .frame(width:70, height:70)
                    .padding(.leading, 5)
                Text(currentWeather.presentTemperature())
                    .font(.title)
                    .redacted(reason: isLoading ? .placeholder : [])
                
                
            }
            
        }
        .padding()
        .fontWeight(.semibold)
        
        
        .task {
            guard let location = self.location else {return}
            
            do {
                response = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude, unit: "celsius")
                
            } catch networkingError.responseError{
                print("Response Error")
            } catch networkingError.dataError {
                print("Data error")
            } catch {
                print("Unexpected error")
            }
            if let response = response{
                currentWeather = loadCurrentWeather(response)
            }
            
            if let response = response {
                isDay = (isDayTime(date: Date(), response: response) == 1)
            }
        }
    }
}

#Preview {
    CityRowView(city: "Pleasanton")
    
}
