//
//  ContentView.swift
//  Shared
//
//  Created by Anthony José on 19/10/21.
//

import SwiftUI
import MapKit
import CoreLocation


// Model
//struct Map {
//
//}

struct ContentView: View {
    var body: some View {
        MapView()
    }
}


// get landmarks on MapKit

// Main map View
struct MapView: View {
    
    @State var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.35
    @State var currentDragOffsetY: CGFloat = 0
    @State var endingOffsetY: CGFloat = 0

    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var search: String = ""
    
    private func getNearByLandmarks() {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
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
    
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack(alignment: .bottom) {
                    Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                        .edgesIgnoringSafeArea(.all)
                    BottomPanel()
                        .offset(y: startingOffsetY)
                        .offset(y: currentDragOffsetY)
                        .offset(y: endingOffsetY)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    withAnimation(.spring()) {
                                        currentDragOffsetY = value.translation.height
                                    }
                                }
                                .onEnded { value in
                                    withAnimation(.spring()) {
                                        if currentDragOffsetY < -100 {
                                            endingOffsetY = -startingOffsetY
                                            currentDragOffsetY = 0
                                        } else if endingOffsetY != 0 && currentDragOffsetY > 150 {
                                            endingOffsetY = 0
                                            currentDragOffsetY = 0
                                        } else {
                                            currentDragOffsetY = 0
                                        }
                                    }
                                }
                        )
                }
            }
        }
    }
}

// Top-bar searchBar
struct SearchLocation: View {
    @State var local = ""

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding(.leading)
            VStack(alignment: .leading) {
                TextField("Buscar no App Mapas", text: $local)
                    .font(.headline)
                    .padding(10)
                    .overlay(
                        withAnimation {
                            Image(systemName: "xmark.circle.fill")
                                .padding()
                                .font(.body)
                                .opacity(local.isEmpty ? 0.0 : 1.0)
                                .onTapGesture {
                                    local = ""
                                }
                        }, alignment: .trailing
                    )
            }
        }
        .background(Color("BackgroundComponents").opacity(0.5))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
    }
}

// Bottom-Bar contents

struct BottomPanel: View {
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                VStack(alignment: .center) {
                    Capsule()
                        .background(Color.gray.opacity(0.05))
                        .frame(width: 25, height: 5, alignment: .center)
                        .padding(10)
                }
                SearchLocation()
                    .padding([.leading, .bottom, .trailing])
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {
                        VStack {
                            ForEach(0..<5) { item in
                                Button(action: {}) {
                                    Text("Result search")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .padding(.leading, 25)
                                        .padding(5)
                                        .foregroundColor(.secondary)

                                }
                            }
                        }
                        Text("Sugestões da Siri")
                            .font(.headline)
                            .padding([.leading, .top])
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ObjectContainer(title: "Carro Estacionado", subtitle: "9,5 km de distancia, perto de Rodovia...", icon: "car.circle.fill")
                                ObjectContainer(title: "Super Mercado", subtitle: "2,8 km de distancia, perto de Rodovia...", icon: "cart.circle.fill")
                            }
                        }
                        Text("Favoritos")
                            .font(.headline)
                            .padding([.leading, .top])
                        ObjectContainer(title: "Casa", subtitle: "15 km de distância", icon: "house.circle.fill")
                    }.frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(height: 350)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .cornerRadius(15)
            .padding(10)
        } else {
            // Fallback on earlier versions
        }
    }
}

// exemple car station of Siri recomend
struct ObjectContainer: View {
    @State var title = ""
    @State var subtitle = ""
    @State var icon = ""

    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.subheadline)
                }
            }.padding(10)
            .background(Color("BackgroundComponents").opacity(0.5))
            .cornerRadius(15)
        }.padding(.leading, 10)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
