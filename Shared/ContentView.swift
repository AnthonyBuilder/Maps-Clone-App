//
//  ContentView.swift
//  Shared
//
//  Created by Anthony José on 19/10/21.
//
import SwiftUI
import MapKit

struct ContentView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            MapViewBody()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
