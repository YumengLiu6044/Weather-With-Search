//
//  LocationModel.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/7/24.
//

import Foundation

struct LocationData: Identifiable, Hashable {
    
    let id : UUID = UUID()
    let cityName: String
    let cityGeocodeString: String
    
}
