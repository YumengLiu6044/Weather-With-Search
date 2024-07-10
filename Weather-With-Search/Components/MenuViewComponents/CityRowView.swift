//
//  CityRowView.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/8/24.
//

import SwiftUI
import CoreLocation
import Shimmer

struct CityRowView: View {
    var locationManager: LocationManager
    var weatherManager: WeatherManager = WeatherManager()
    var city: LocationData
    @Binding var preferredUnit: UnitTemperature
    @State private var isLoading: Bool = true
    @State private var response: WeatherData?
    @State private var currentWeather: CurrentWeather?
    @State private var timeZone: String = "America/Los_Angeles"
    @State private var isDay: Bool = true
    @State private var timer  = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime: String = "23:59"
    
    var body: some View {
        NavigationLink{
            if !isLoading {
                WeatherView(weatherManager: self.weatherManager, response: self.response!, cityName: self.city.cityTitle, preferredUnit: $preferredUnit)
                    .navigationBarTitleDisplayMode(.inline)
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 5){
                    Text(city.cityTitle)
                        .font(.title)
                    Text(city.citySubtitle)
                        .font(.title2)
                    Text(self.currentTime)
                        .font(.title2)
                        .onReceive(timer) { _ in
                            self.currentTime = getFormattedTime(from: Date(), with: "HH:mm", for: timeZone)
                        }
                        .shimmering(active: isLoading)
                        .redacted(reason: isLoading ? .placeholder : [])
                }
                
                Spacer()
                VStack{
                    OnlineImageView(imageURL: currentWeather?.weatherIconName ?? "", isLoading: .constant(true))
                        .frame(width:70, height:70)
                        .padding(.leading, 5)
                    if let currentWeather = currentWeather {
                        Text(showTemperature(from: currentWeather.temperature, of: currentWeather.temperatureUnit, to: preferredUnit))
                            .font(.title)
                            .redacted(reason: isLoading ? .placeholder : [])
                            .shimmering(active: isLoading)
                            .transition(.blurReplace())
                            .animation(.easeIn, value: preferredUnit)
                    } else {
                        Text("what_the")
                            .font(.title)
                            .redacted(reason: isLoading ? .placeholder : [])
                            .shimmering(active: isLoading)
                    }
                    
                }
            }
            .transition(.blurReplace())
            .animation(.easeInOut, value: isLoading)
            .padding()
            .fontWeight(.semibold)
            .task{
                loadLocation()
            }
            
        }
        .tint(.white)
    }
    
    private func loadLocation() {
        locationManager.getCoordinate(addressString: city.getGeocodeString()) { (coordinate, error) in
            if let error = error {
                print("Error geocoding address: \(error.localizedDescription)")
            } else {
                let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                Task {
                    await loadTimeZone(location: location)
                }
            }
        }
        
    }
    
    private func loadTimeZone(location: CLLocationCoordinate2D) async {
        locationManager.getTimeZone(forLatitude: location.latitude, longitude: location.longitude) { timeZoneIdentifier in
            if let timeZoneIdentifier = timeZoneIdentifier {
                self.timeZone = timeZoneIdentifier
                Task {
                    await loadWeather(location: location)
                }
            } else {
                print("Failed to load time zone")
            }
        }
        
        
    }
    
    private func loadWeather(location: CLLocationCoordinate2D) async {
        do {
            response = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude, unit: preferredUnit == UnitTemperature.celsius ? "celsius" : "fahrenheit", timeZone: timeZone)
            
            if let response = response {
                currentWeather = loadCurrentWeather(response)
            }
        } catch networkingError.responseError {
            print("Response Error")
        } catch networkingError.dataError {
            print("Data error")
        } catch {
            print("Unexpected error")
        }
        withAnimation {
            isLoading = false
        }
    }
}

#Preview {
    CityRowView(locationManager: LocationManager(), city: LocationData(cityTitle: "Beijing", citySubtitle: "China"), preferredUnit: .constant(.celsius))
    
}
