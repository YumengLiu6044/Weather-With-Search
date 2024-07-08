//
//  ContentView.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/2/24.
//

import Foundation
import SwiftUI


struct MenuView: View {
    var weatherManager = WeatherManager()
    @ObservedObject var locationService = LocationService()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var searchResultViewModel = SearchResultViewModel()
    @AppStorage("saved_city_csv_string") private var savedCityString: String = SampleData.sampleCitiesString
    @State private var citySet: Set<String> = []
    @State private var isLoadingWeatherView = false
    
    var body: some View {
        NavigationStack{
            VStack{
                List {
                    ForEach(Array(citySet), id:\.self) { city in
                        CityRowView(weatherManager: weatherManager, city: city)
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
                ForEach(searchResultViewModel.listCities(completions: locationService.searchResults), id:\.self) {
                    result in
                    VStack (alignment: .leading){
                        Text(result.title)
                        Text(result.subtitle)
                            .font(.caption)
                    }
                    .onTapGesture {
                        addCity(result.title)
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
            citySet.insert(String(city))
        }
    }
    
    private func addCity(_ newCity: String) {
        citySet.insert(newCity)
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
            save += i + "#"
        }
        if !save.isEmpty {
            save.removeLast()
        }
        savedCityString = save
    }
}

#Preview {
    MenuView()
        .preferredColorScheme(.dark)
}
