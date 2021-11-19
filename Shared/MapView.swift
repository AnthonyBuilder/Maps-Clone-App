//
//  MapView.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI
import MapKit
import CoreLocation

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
    
    @State private var firstPoint: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 40.71, longitude: -74))
    @State private var finishPoint: MKPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: 42.36, longitude: -71.05))
    
    let mapView = MKMapView()
    
    @State var directions: [String] = [String]()
    
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
                    MapView(directions: $directions, region: $mapViewModel.mapRegion, firstPoint: $firstPoint, finishPoint: $finishPoint)
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
                                    HStack {
                                        Button(action: {
                                            // set route
                                            firstPoint = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: -23.2950886, longitude: -46.7326319))
                                            
                                            finishPoint = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: landmarkCoordinate!.latitude, longitude: landmarkCoordinate!.longitude))
                                            
                                        }) {
                                            Image(systemName: "car.fill")
                                                .font(.title)
                                        }
                                        Button(action: {
                                            // Save location
                                            mapViewModel.saveLocation(selfLocation: MapLocation(name: landmarkName, country: landmarkTitle, latitude: landmarkCoordinate!.latitude, longitude: landmarkCoordinate!.longitude))
                                            print(mapViewModel.MapLocations)
                                        }) {
                                            Image(systemName: "heart.circle")
                                                .font(.title)
                                        }
                                    }
                                }.padding(.horizontal, 10)
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
                    
                    // Bottom sheet showing user informations
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


struct MapView: UIViewRepresentable {
    typealias UIViewType = MKMapView

    @StateObject private var mapViewModel = MapViewModel()
    @Binding var directions: [String]
    @Binding var region: MKCoordinateRegion
    
    @Binding var firstPoint: MKPlacemark
    @Binding var finishPoint: MKPlacemark

    init(directions: Binding<[String]>, region: Binding<MKCoordinateRegion>, firstPoint: Binding<MKPlacemark>, finishPoint: Binding<MKPlacemark>) {
        self._directions = directions
        self._region = region
        self._firstPoint = firstPoint
        self._finishPoint = finishPoint
    }
    
    func makeCoordinator() -> MapViewCoordinator {
        return MapViewCoordinator()
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        mapView.setRegion(region, animated: true)
        
        mapView.showsUserLocation = true
        
        setMapRoute(mapView: mapView)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        setMapRoute(mapView: uiView)
    }
    
    func setMapRoute(mapView: MKMapView) {
        DispatchQueue.main.async {
            let request = MKDirections.Request()
            request.source = MKMapItem(placemark: firstPoint)
            request.destination = MKMapItem(placemark: finishPoint)
            request.transportType = .automobile
            
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let route = response?.routes.first else { return }
                let overlays = mapView.overlays
                mapView.removeOverlays(overlays)
                mapView.removeAnnotations([firstPoint, finishPoint])
                mapView.addAnnotations([firstPoint, finishPoint])
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
                self.directions = route.steps.map {$0.instructions}.filter { !$0.isEmpty}
            }
        }
    }

    class MapViewCoordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 5
            return renderer
        }
    }
}

