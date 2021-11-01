//
//  MapLocation.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let country: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
