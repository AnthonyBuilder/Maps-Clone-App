//
//  ContentView.swift
//  Shared
//
//  Created by Anthony José on 19/10/21.
//
import SwiftUI
import MapKit
import CoreLocation


fileprivate enum Constants {
    static let minHeightRatio: CGFloat = 0.3
}

// MapViewModel
final class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager?
    
    @Published var region = MKCoordinateRegion(center:
                                                    CLLocationCoordinate2D(latitude: 51.507222, longitude: -0.1275),
                                                span:
                                                    MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    
    func checkIfLocatioServiceIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            checkLocationAuthorization()
        } else {
            print("Show an alert letting them know this is off and to go turn it on.")
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
            print("Your have denied this app location permissions. Go into settings to change it.")
        case .authorizedAlways, .authorizedWhenInUse:
            region = MKCoordinateRegion(center: locationManager.location!.coordinate, span:  MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
    
    
    @State static private(set) var landmarks: [Landmark] = [Landmark]()
    
    // get landmarks on MapKit
    func getNearByLandmarks(location search: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = search
        
        let search = MKLocalSearch(request: request)
        
        search.start { (response, error) in
            if let response = response {
                let mapItems = response.mapItems
                MapViewModel.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        MapView()
    }
}


// Main map View
struct MapView: View {
    
    @StateObject private var viewModel = MapViewModel()
    @State private var bottomSheetShown = false

    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack(alignment: .bottom) {
                    Map(coordinateRegion: $viewModel.region, showsUserLocation: true, userTrackingMode: .constant(.follow))
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            viewModel.checkIfLocatioServiceIsEnabled()
                        }
                    BottomSheetView(isOpen: $bottomSheetShown, maxHeight: gr.size.height * 0.8, mapViewModel: .init())
                }
            }
        }
    }
}

// SearchBar
struct SearchBar<Content: View>: View {
    
    let content: Content
    
    init (@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .padding(.leading)
            VStack(alignment: .leading) {
                self.content
            }
        }
        .background(Color("BackgroundComponents").opacity(0.5))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.2), radius: 5, y: 5)
    }
}

// Bottom-Bar contents
struct BottomSheetView: View {
    
    @Binding var isOpen: Bool
    
    @State private var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.03
    @State private var currentDragOffsetY: CGFloat = 0
    @State private var endingOffsetY: CGFloat = 0
    @State private var local = ""
    
    @ObservedObject var mapViewModel: MapViewModel

    
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    init(isOpen: Binding<Bool>, maxHeight: CGFloat, mapViewModel: MapViewModel) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.mapViewModel = mapViewModel
        self._isOpen = isOpen
    }
    
    
    var otherActions: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                VStack {
                    ForEach(MapViewModel.landmarks, id: \.id) { item in
                        Button(action: {}) {
                            Text(item.name)
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.leading, 25)
                                .padding(5)
                                .foregroundColor(.secondary)

                        }
                    }
                }
                
                ForEach(0..<5) { item in
                    Text("Sugestões da Siri")
                        .font(.headline)
                        .padding([.leading, .top])
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ObjectContainer(title: "Carro Estacionado", subtitle: "9,5 km de distancia, perto de Rodovia...", icon: "car.circle.fill")
                            ObjectContainer(title: "Super Mercado", subtitle: "2,8 km de distancia, perto de Rodovia...", icon: "cart.circle.fill")
                        }
                    }
                }
               
                Text("Favoritos")
                    .font(.headline)
                    .padding([.leading, .top])
                ObjectContainer(title: "Casa", subtitle: "15 km de distância", icon: "house.circle.fill")
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack {
                VStack(alignment: .center) {
                    Capsule()
                        .background(Color.gray.opacity(0.05))
                        .frame(width: 25, height: 5, alignment: .center)
                        .padding(5)
                }
                
                SearchBar {
                    TextField("Buscar no App Mapas", text: $local, onEditingChanged: { item in
                        isOpen.toggle()
                        mapViewModel.getNearByLandmarks(location: local)
                    })
                        .onSubmit {
                            if !local.isEmpty {
                                isOpen = true
                            }
                        }
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
                }.padding([.leading, .bottom, .trailing])
                
                if isOpen == true {
                    otherActions
                }
            }
            .frame(height: isOpen ? self.maxHeight : 80)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .cornerRadius(20)
            .padding(10)
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
                                isOpen = true
                                endingOffsetY = -startingOffsetY
                                currentDragOffsetY = 0
                            } else if endingOffsetY != 0 && currentDragOffsetY > 150 {
                                isOpen = false
                                endingOffsetY = 0
                                currentDragOffsetY = 0
                            } else {
                                currentDragOffsetY = 0
                            }
                        }
                    }
            )
        } else {
            
        }
    }
}

// exemple car station of Siri recomend
struct ObjectContainer: View {
    var title = ""
    var subtitle = ""
    var icon = ""

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
