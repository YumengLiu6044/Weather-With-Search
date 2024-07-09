//
//  LocationModel.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/7/24.
//

import Foundation

struct LocationData: Hashable {
    
    let cityTitle: String
    let citySubtitle: String
    
    func getGeocodeString() -> String {
        let combined = cityTitle + " " + citySubtitle
        return combined.replacingOccurrences(of: ",", with: "")
    }
    
}
