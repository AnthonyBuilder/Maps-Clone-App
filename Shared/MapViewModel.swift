//
//  MapViewModel.swift
//  maps
//
//  Created by Anthony José on 26/10/21.
//

import MapKit
import SwiftUI
import UIKit

enum MapDetails {
    static let startingLocation = CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275)
    static let defaultSpan = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
}

// MapViewModel
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    var hasSetRegion = false
    
    @Published var landmarks: [Landmark] = [Landmark]()
    @Published var location: CLLocation?
    @Published var mapRegion = MKCoordinateRegion(
        center:
            MapDetails.startingLocation,
        span:
            MapDetails.defaultSpan
    )
    
    // check localization is authorized 
    func checkIfLocatioServiceIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            checkLocationAuthorization()
        } else {
            print("Show an alert letting them know this is off and to go turn it on.")
        }
    }
    
    // case CoreLocation not working
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locations.last.map {
            mapRegion = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude),
                span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
            )
        }
    }
    
    private func checkLocationAuthorization() {
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("Your location is restricted likely due to parental constrols.")
        case .denied:
            print(" ")
        case .authorizedAlways, .authorizedWhenInUse:
            mapRegion = MKCoordinateRegion(
                center: locationManager.location!.coordinate,
                span:  MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
   
    // get landmarks on MapKit
    func getNearByLandmarks(location search: Binding<String>) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search.wrappedValue
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
            }
        }
    }
    
    func updateMapRegion(location: CLLocationCoordinate2D?) {
        DispatchQueue.main.async {
            if let location = location {
                self.mapRegion = MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude),
                    span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
                )
            }
        }
    }
}

extension MKPointAnnotation {
    static var example: MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Home to the 2012 Summer Olympics."
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
        return annotation
    }
}

//    struct Product {
//        let category: Category
//        let description: Description
//    }
//
//    extension Product {
//        struct Category {}
//        struct Description {}
//    }
//
//    let category = Product.Category()
//    let description = Product.Description()
