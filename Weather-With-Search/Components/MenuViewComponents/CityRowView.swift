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
    var locationManager: LocationManager = LocationManager()
    var weatherManager: WeatherManager = WeatherManager()
    var city: LocationData
    @State private var isLoading: Bool = true
    @State private var response: WeatherData?
    @State private var currentWeather: CurrentWeather?
    @State private var isDay: Bool = true
    @State private var timer  = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var currentTime: String = ""
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(city.cityTitle)
                    .font(.title)
                Text(city.citySubtitle)
                    .font(.body)
                Text(self.currentTime)
                    .onReceive(timer) { _ in
                        self.currentTime = getFormattedTime(from: Date(), with: "HH:mm:ss", for: currentWeather?.timeZone ?? "America/Los_Angeles")
                    }
            }
            
            Spacer()
            VStack{
                OnlineImageView(imageURL: currentWeather?.weatherIconName ?? "", isLoading: $isLoading)
                    .frame(width:70, height:70)
                    .padding(.leading, 5)
                Text(currentWeather?.presentTemperature() ?? "what_the")
                    .font(.title)
                    .redacted(reason: isLoading ? .placeholder : [])
                    .shimmering(active: isLoading)
            }
        }
        .transition(.blurReplace())
        .animation(.easeInOut, value: isLoading)
        .padding()
        .fontWeight(.semibold)
        .onAppear {
            self.currentTime = getFormattedTime(from: Date(), with: "HH:mm:ss", for: currentWeather?.timeZone ?? "America/Los_Angeles")
        }
        .task {
            locationManager.getCoordinate(addressString: city.getGeocodeString()) { (coordinate, error) in
                if let error = error {
                    print("Error geocoding address: \(error.localizedDescription)")
                } else {
                    let location = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                    print(location)
                    
                    Task {
                        do {
                            response = try await weatherManager.getCurrentWeather(latitude: location.latitude, longitude: location.longitude, unit: "celsius")
                            
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
            }
            
        }
    }
}

#Preview {
    CityRowView(city: LocationData(cityTitle: "Pleasanton, CA", citySubtitle: "United States"))
    
}
