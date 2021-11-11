//
//  MapView.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI
import MapKit


// Main map View
struct MapViewBody: View {
    
    @StateObject private var mapViewModel = MapViewModel()
    @State private var bottomSheetShown = false
    @State private var showPlacemark = false
    
    
    @State private var directions: [String] = []
    
    @State private var placemarkSearchText = ""
    @State private var name = ""
    @State private var title = ""
    
    let spacerHeight: CGFloat = 50
    
    
    func moveToLocation(to location: Landmark) {
        mapViewModel.updateMapRegion(location: location.coordinate)
        title = location.title
        name = location.name
        bottomSheetShown = false
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
                ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                    Map(coordinateRegion: $mapViewModel.mapRegion, showsUserLocation: true)
                        .ignoresSafeArea()
                    
//                    // Settings Button...
//                    Button(action: {
//                        withAnimation(.spring()) {
//                            bottomSheetShown.toggle()
//                        }
//                    }) {
//                        Image(systemName: "magnifyingglass")
//                            .font(.title2)
//                            .foregroundColor(.black)
//                            .padding(.vertical, 10)
//                            .padding(.horizontal, 15)
//                            .background(Color("BackgroundComponents"))
//                            .cornerRadius(10)
//                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: -5, y: -5)
//                    }
                    
            
                    
                    
                    // Filter or Radio Button View
                    BottomSheetViewBuilder(isShowing: $bottomSheetShown, maxHeight: gr.size.height - 50) {
                        HStack {
                            SearchBar {
                                TextField("Buscar no mapa", text: $placemarkSearchText, onEditingChanged: { edit in
                                    showResultsSearchLocations()
                                }).padding(10)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                        }
                        .padding([.horizontal, .top])
                        .padding(.bottom, 10)
                        
                        if bottomSheetShown == true {
                            ScrollView {
                                VStack(alignment: .leading, spacing: 0) {
                                    ForEach(mapViewModel.landmarks, id: \.id) { location in
                                        VStack(alignment: .leading, spacing: 13) {
                                            Button(action: {
                                                withAnimation(.spring()) {
                                                    moveToLocation(to: location)
                                                    bottomSheetShown = false
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
                            }
                        }
                    }
                    .ignoresSafeArea()
                    .background(
                        Color.black.opacity(0.3).ignoresSafeArea().opacity(bottomSheetShown ? 1 : 0)
                    )
                }
            }
            
        }
    }
}


struct ContentViewMapView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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
