//
//  ContentView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/2/24.
//

import Foundation
import SwiftUI
import MapKit


struct MenuView: View {
    @StateObject private var locationService        =   LocationService()
    @StateObject private var locationManager        =   LocationManager()
    @StateObject private var searchResultViewModel  =   SearchResultViewModel()
    @AppStorage("saved_city_csv_string") private var savedCityString: String = SampleData.sampleCitiesString
    @State private var cityArray: Array<LocationData> = []
    @State private var isLoadingWeatherView = false
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(cityArray, id:\.self) { city in
                        CityRowView(locationManager: self.locationManager, city: city)
                            .frame(height:120)
                            .clipShape(.rect(cornerRadius: 6))
                        
                        
                    }
                    .onDelete(perform: removeCity)
                    .onMove {
                        from, to in
                        cityArray.move(fromOffsets: from, toOffset: to)
                    }
                }
                .listRowSpacing(15)
                
            }
            .navigationTitle("Weather")
            .searchable(text: $locationService.queryFragment, isPresented: $searchResultViewModel.isSearch)
            .searchSuggestions {
                HStack{
                    Image(systemName: "location")
                    Text("Use Current Location")
                        .onTapGesture {
                            loadCurrentLocation()
                        }
                }
                
                
                ForEach(searchResultViewModel.listCities(completions: locationService.searchResults), id:\.self) {
                    result in
                    SearchRecommendationView(result: result)
                        .onTapGesture {
                            addCity(result)
                            locationService.queryFragment = ""
                            searchResultViewModel.isSearch = false
                        }
                    
                }
            }
        }
        .tint(.primary)
        .onAppear {
            loadCity()
            locationManager.requestLocation()
        }
        
        
    }
    
    private func loadCity() {
        cityArray.removeAll()
        for city in savedCityString.split(separator: "#") {
            let components = city.split(separator: "@")
            if components.count == 2{
                cityArray.append(LocationData(cityTitle: String(components[0]), citySubtitle: String(components[1])))
            }
            
            else if components.count == 1 {
                cityArray.append(LocationData(cityTitle: String(components[0]), citySubtitle: ""))
            }
            
        }
    }
    
    private func addCity(_ newCity: MKLocalSearchCompletion) {
        let adding = LocationData(cityTitle: newCity.title, citySubtitle: newCity.subtitle)
        if cityArray.contains(adding) {
            return
        }
        cityArray.append(adding)
        saveCity()
    }
    
    private func removeCity(_ offsets: IndexSet) {
        cityArray.remove(atOffsets: offsets)
        saveCity()
    }
    
    private func saveCity() {
        var save: String = ""
        for i in cityArray {
            save += i.cityTitle + "@" + i.citySubtitle + "#"
        }
        if !save.isEmpty {
            save.removeLast()
        }
        
        savedCityString = save
    }
    
    private func loadCurrentLocation() {
        
        if locationManager.isLoading {
            print("Still loading")
            return
        } else {
            print("Loaded")
        }
        guard locationManager.location != nil else {
            print("Failed to load current location")
            return
        }
        locationManager.lookUpCurrentLocation {
            placemark in
            if let placemark = placemark {
                // Access placemark information like locality (city), administrativeArea (state), etc.
                if let locality = placemark.locality {
                    locationService.queryFragment = "\(locality)"
                }
            }
        }
    }
}

#Preview {
    MenuView()
        .preferredColorScheme(.light)
}
