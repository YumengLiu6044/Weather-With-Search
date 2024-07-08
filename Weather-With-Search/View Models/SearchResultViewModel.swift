//
//  SearchResultViewModel.swift
//  API_Demo
//
//  Created by Yumeng Liu on 7/8/24.
//

import Foundation
import MapKit

final class SearchResultViewModel: ObservableObject {
    @Published var isSearch: Bool = false
    @Published var searchText: String = ""
    
    func listCities(completions: [MKLocalSearchCompletion]) -> [MKLocalSearchCompletion] {
        let filtered_completions = completions.filter { result in
            if result.subtitle.isEmpty {
                return false
            }
            else if result.subtitle.filter({char in char == ","}).count > 1 {
                return false
            }
            else if result.subtitle == "Search Nearby" {
                return false
            }
            return true
        }
        return filtered_completions
    }
    
    
    
}
