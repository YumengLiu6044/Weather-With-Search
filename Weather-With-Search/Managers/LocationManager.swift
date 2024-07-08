//
//  LocationManager.swift
//  Weather and Climate Control
//
//  Created by Yumeng Liu on 7/2/24.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate{
    
    let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    @Published var isLoading = false
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        isLoading = true
        manager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        isLoading = false
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Error getting location: \(error.localizedDescription)")
        if let clError = error as? CLError {
            print("CLError code: \(clError.code.rawValue)")
        }
        isLoading = false
    }
    
    func lookUpCurrentLocation(completionHandler: @escaping (CLPlacemark?) -> Void ) {
        // Use the last reported location.
        if let lastLocation = self.location {
            let geocoder = CLGeocoder()
            
            // Look up the location and pass it to the completion handler
            geocoder.reverseGeocodeLocation(CLLocation(latitude: lastLocation.latitude, longitude: lastLocation.longitude),
                                            completionHandler: { (placemarks, error) in
                if error == nil {
                    let firstLocation = placemarks?[0]
                    completionHandler(firstLocation)
                }
                else {
                    // An error occurred during geocoding.
                    completionHandler(nil)
                }
            })
        }
        else {
            // No location was available.
            completionHandler(nil)
        }
    }
    
    func forwardGeocoding(address: String) -> CLLocationCoordinate2D {
        var result: CLLocationCoordinate2D?
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address, completionHandler: { (placemarks, error) in
            if error != nil {
                print("Failed to retrieve location")
                return
            }
            
            var location: CLLocation?
            
            if let placemarks = placemarks, placemarks.count > 0 {
                location = placemarks.first?.location
            }
            
            if let location = location {
                let coordinate = location.coordinate
                print("\nlat: \(coordinate.latitude), long: \(coordinate.longitude)")
                result = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            }
            else
            {
                print("No Matching Location Found")
            }
        })
        return result ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }
    
}
