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
    @ObservedObject var locationService = LocationService()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchResultViewModel = SearchResultViewModel()
    @AppStorage("saved_city_csv_string") private var savedCityString: String = SampleData.sampleCitiesString
    @State private var citySet: Set<LocationData> = []
    @State private var isLoadingWeatherView = false
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(Array(citySet), id:\.self) { city in
                        CityRowView(locationManager: locationManager, city: city)
                            .frame(height:120)
                            .clipShape(.rect(cornerRadius: 6))
                    }
                    .onDelete(perform: removeCity)
                }
                .listRowSpacing(20)
                
            }
            .navigationTitle("Weather")
            .searchable(text: $locationService.queryFragment, isPresented: $searchResultViewModel.isSearch)
            .searchSuggestions {
                Text("Use Current Location")
                
                ForEach(searchResultViewModel.listCities(completions: locationService.searchResults), id:\.self) {
                    result in
                    VStack (alignment: .leading){
                        Text(result.title)
                        Text(result.subtitle)
                            .font(.caption)
                    }
                    .onTapGesture {
                        addCity(result)
                        locationService.queryFragment = ""
                        searchResultViewModel.isSearch = false
                    }
                }
            }
        }
        
        .onAppear {
            loadCity()
        }
        
        
    }
    
    private func loadCity() {
        for city in savedCityString.split(separator: "#") {
            let components = city.split(separator: "@")
            if components.count == 2{
                citySet.insert(LocationData(cityTitle: String(components[0]), citySubtitle: String(components[1])))
            }
            
        }
    }
    
    private func addCity(_ newCity: MKLocalSearchCompletion) {
        citySet.insert(LocationData(cityTitle: newCity.title, citySubtitle: newCity.subtitle))
        saveCity()
    }
    
    private func removeCity(_ offsets: IndexSet) {
        for index in offsets {
            let city = Array(citySet)[index]
            citySet.remove(city)
        }
        saveCity()
    }
    
    private func saveCity() {
        var save: String = ""
        for i in citySet {
            save += i.cityTitle + "@" + i.citySubtitle + "#"
        }
        if !save.isEmpty {
            save.removeLast()
        }
        savedCityString = save
    }
}

#Preview {
    MenuView()
        .preferredColorScheme(.light)
}
