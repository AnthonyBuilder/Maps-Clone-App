//
//  MapView.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI
import MapKit


// Main map View
@available(iOS 15.0, *)
struct MapViewBody: View {
    
    @StateObject var mapViewModel = MapViewModel()
    @State private var isSheetShowing = false
    @State private var isSheetPersonShowing = false
    @State private var isSavedLocationsShowing = true
    @FocusState private var focusSheet: Bool
    
    @State private var placemarkSearchText = ""
    
    @State private var landmarkName = ""
    @State private var landmarkTitle = ""
    @State private var landmarkCoordinate: CLLocationCoordinate2D?
    
    
    
    func moveToLocation(to location: Landmark) {
        mapViewModel.updateMapRegion(location: location.coordinate)
        landmarkTitle = location.title
        landmarkName = location.name
        landmarkCoordinate = location.coordinate
        isSheetShowing = false
    }
    
    func showResultsSearchLocations() {
        if placemarkSearchText.isEmpty {
            mapViewModel.landmarks.removeAll()
        } else {
            mapViewModel.getNearByLandmarks(location: $placemarkSearchText)
        }
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                    Map(coordinateRegion: $mapViewModel.mapRegion, showsUserLocation: true)
                        .onTapGesture {
                            focusSheet = false
                            isSheetShowing = false
                        }
                        .ignoresSafeArea()
                    
                    HStack {
                        Spacer()
                        
                        // change terrain button
                        Button(action: {
                            withAnimation(.spring()) {
                                isSheetShowing.toggle()
                            }
                        }) {
                            Image(systemName: "globe.americas.fill")
                                .font(.title2)
                                .foregroundColor(.primary)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 10)
                                .background(Color("BackgroundComponents"))
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: -5)
                        }.padding(.trailing)
                    }
                    
                    
                    
                    // Bottom sheet content current location and action for location
                    if isSheetShowing == false && !landmarkName.isEmpty && !landmarkTitle.isEmpty {
                        withAnimation(.spring()) {
                            VStack {
                                Spacer()
                                InfoContainerView(landmarkName: $landmarkName, landmarkTitle: $landmarkTitle) {
                                    Button(action: {
                                        // Save location
                                        mapViewModel.saveLocation(selfLocation: MapLocation(name: landmarkName, country: landmarkTitle, latitude: landmarkCoordinate!.latitude, longitude: landmarkCoordinate!.longitude))
                                        print(mapViewModel.MapLocations)
                                    }) {
                                        Image(systemName: "heart.circle")
                                            .font(.title)
                                    }
                                }
                                    .padding(.horizontal, 10)
                            }.offset(y: -100)
                        }
                    }
                    
                    // Bottom sheet content Search location and actions
                    BottomSheetViewBuilder(isShowing: $isSheetShowing, maxHeight: gr.size.height - 50) {
                        HStack {
                            SearchBar {
                                TextField("Buscar por endereços", text: $placemarkSearchText, onEditingChanged: { edit in
                                    showResultsSearchLocations()
                                    isSheetShowing = true
                                    focusSheet = false
                                    if placemarkSearchText.isEmpty {
                                        placemarkSearchText = ""
                                        showResultsSearchLocations()
                                        isSheetShowing = false
                                    }
                                })
                                    .focused($focusSheet)
                                    .padding(10)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .onTapGesture {
                                    isSheetPersonShowing.toggle()
                                }
                        }
                        .padding([.horizontal])
                        .padding(.bottom, 10)
                        
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 0) {
                                ForEach(mapViewModel.landmarks, id: \.id) { location in
                                    VStack(alignment: .leading, spacing: 13) {
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                moveToLocation(to: location)
                                            }
                                        }) {
                                            VStack(alignment: .leading) {
                                                Text(location.name)
                                                    .font(.headline)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.primary)
                                                Text(location.title)
                                                    .font(.subheadline)
                                                    .multilineTextAlignment(.leading)
                                                    .foregroundColor(.secondary)
                                            }.padding()
                                        }
                                    }
                                }
                            }.padding(.vertical)
                            
                            VStack {
                                HStack {
                                    Text("Locais favoritos")
                                        .font(.title)
                                        .fontWeight(.bold)
                                    Spacer()
                                    
                                    Button(action: {
                                        // show list saved locations
                                        withAnimation(.spring()) {
                                            isSavedLocationsShowing.toggle()
                                        }
                                    }) {
                                        Image(systemName: "chevron.down")
                                            .rotationEffect(isSavedLocationsShowing ? .degrees(180) : .degrees(0) )
                                            .animation(.easeInOut)
                                            .font(.title2)
                                            .foregroundColor(.primary)
                                    }
                                }.padding()
                                
                                
                                if isSavedLocationsShowing == true {
                                    Divider()
                                    VStack(alignment: .leading, spacing: 15) {
                                        ForEach(mapViewModel.MapLocations) { savedLocations in
                                            HStack {
                                                Text(savedLocations.name)
                                                    .font(.headline)
                                                Spacer()
                                                Image(systemName: "xmark")
                                            }
                                        }
                                    }.padding()
                                }
                            }.padding(.vertical)
                        }
                    }
                    .ignoresSafeArea()
                    
                    if isSheetPersonShowing == true {
                        withAnimation(.spring()) {
                            BottomSheetViewBuilder(isShowing: $isSheetPersonShowing, maxHeight: gr.size.height - 100) {
                                VStack {
                                    HStack {
                                        Text("Anthony José")
                                            .font(.title)
                                            .fontWeight(.bold)
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            isSheetPersonShowing = false
                                        }) {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.title2)
                                        }
                                    }
                                    
                                    VStack(alignment: .leading) {
                                        Button(action: {
                                            // show favorites
                                        }){
                                            HStack {
                                                Image(systemName: "heart.fill")
                                                Text("Favoritos")
                                            }
                                        }
                                    }
                                }.padding()
                            }
                            .ignoresSafeArea()
                            .background(
                                Color.black.opacity(0.3).ignoresSafeArea().opacity(isSheetShowing ? 1 : 0)
                            )
                        }
                    }
                }
            }
        }
    }
}





//struct MapView: UIViewRepresentable {
//    typealias UIViewType = MKMapView
//
//    @StateObject private var mapViewModel = MapViewModel()
//    @Binding var directions: [String]
//
//
//    func makeCoordinator() -> MapViewCoordinator {
//        return MapViewCoordinator()
//    }
//
//    func makeUIView(context: Context) -> MKMapView {
//        let mapView = MKMapView()
//        mapView.delegate = context.coordinator
//
//        mapView.setRegion(mapViewModel.mapRegion, animated: true)
//
//        let request = MKDirections.Request()
//        request.source = MKMapItem(placemark: mapViewModel.initialPoint)
//        request.destination = MKMapItem(placemark: mapViewModel.finishPoint)
//        request.transportType = .automobile
//
//
//        let directions = MKDirections(request: request)
//        directions.calculate { response, error in
//            guard let route = response?.routes.first else { return }
//            mapView.addAnnotations([mapViewModel.initialPoint, mapViewModel.finishPoint])
//            mapView.addOverlay(route.polyline)
//            mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
//            self.directions = route.steps.map {$0.instructions}.filter { !$0.isEmpty}
//        }
//
//        return mapView
//    }
//
//    func updateUIView(_ uiView: MKMapView, context: Context) {
//    }
//
//    class MapViewCoordinator: NSObject, MKMapViewDelegate {
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            let renderer = MKPolylineRenderer(overlay: overlay)
//            renderer.strokeColor = .systemBlue
//            renderer.lineWidth = 5
//            return renderer
//        }
//    }
//}
//
