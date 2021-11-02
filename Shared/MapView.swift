//
//  MapView.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI
import MapKit

// Main map View
struct MapView: View {
    
    @StateObject private var mapViewModel = MapViewModel()
    @State private var bottomSheetShown = false
    
    @State private var name = ""
    @State private var title = ""
    
    let spacerHeight: CGFloat = 50
    
    var LocationDescription: some View {
        VStack {
            HStack {
                VStack {
                    Text(name)
                        .font(.title3)
                        .bold()
                    Text(title)
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    func moveToLocation(to location: Landmark) {
        mapViewModel.updateMapRegion(location: location.coordinate)
        title = location.title
        name = location.name
        bottomSheetShown = false
    }
    
    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack {
                    Map(coordinateRegion: $mapViewModel.mapRegion,
                        interactionModes: MapInteractionModes.all,
                        showsUserLocation: true,
                        annotationItems: mapViewModel.MapLocations,
                        annotationContent: { location in
                        MapPin(coordinate: location.coordinate, tint: .red)
                    })
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            mapViewModel.checkIfLocatioServiceIsEnabled()
                        }
                        .onTapGesture {
                            withAnimation(.spring()) {
                                bottomSheetShown = false
                            }
                        }
                    
                    VStack {
                        if bottomSheetShown == false && name.isEmpty == false {
                            if #available(iOS 15.0, *) {
                                withAnimation(.easeInOut) {
                                    LocationDescription
                                        .padding(10)
                                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                                }
                            } else {
                                withAnimation(.easeInOut) {
                                    LocationDescription
                                        .padding(10)
                                        .background(Color("BackgroundComponents"))
                                }
                            }
                        }
                        
                        Spacer(minLength: spacerHeight)
                        
                        BottomSheetView(isOpen: $bottomSheetShown, maxHeight: gr.size.height * 0.9) { location in
                            if bottomSheetShown == true {
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
                    }
                }
            }
        }
    }
}
