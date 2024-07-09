//
//  CityRowView.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/8/24.
//

import SwiftUI
import CoreLocation

struct CityRowView: View {
    var locationManager: LocationManager = LocationManager()
    var weatherManager: WeatherManager = WeatherManager()
    var city: LocationData
    @State private var isLoading: Bool = true
    @State private var response: WeatherData?
    @State private var currentWeather: CurrentWeather?
    @State private var isDay: Bool = true
    
    var body: some View {
        HStack {
            VStack(alignment: .leading){
                Text(city.cityTitle)
                    .font(.title)
                Text(city.citySubtitle)
                    .font(.body)
            }
            
            Spacer()
            VStack{
                OnlineImageView(imageURL: currentWeather?.weatherIconName ?? "", isLoading: $isLoading)
                    .frame(width:70, height:70)
                    .padding(.leading, 5)
                Text(currentWeather?.presentTemperature() ?? "Placeholder")
                    .font(.title)
                    .redacted(reason: isLoading ? .placeholder : [])
                
                
            }
            
        }
        .padding()
        .fontWeight(.semibold)
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
                        
                        isLoading = false
                    }
                }
            }
            
        }
    }
}

#Preview {
    CityRowView(city: LocationData(cityTitle: "Pleasanton, CA", citySubtitle: "United States"))
    
}
