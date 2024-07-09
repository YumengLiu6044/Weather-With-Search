//
//  SearchRecommendationView.swift
//  Weather-With-Search
//
//  Created by Yumeng Liu on 7/8/24.
//

import SwiftUI
import MapKit

struct SearchRecommendationView: View {
    var result: MKLocalSearchCompletion
    var body: some View {
        VStack (alignment: .leading){
            Text(result.title)
            Text(result.subtitle)
                .font(.caption)
        }
        
    }
}
