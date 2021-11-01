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
    
    @StateObject private var viewModel = MapViewModel()
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
        viewModel.updateMapRegion(location: location.coordinate)
        title = location.title
        name = location.name
        bottomSheetShown = false
    }

    var body: some View {
        GeometryReader { gr in
            VStack {
                ZStack {
                    Map(coordinateRegion: $viewModel.mapRegion,
                        interactionModes: MapInteractionModes.all,
                        showsUserLocation: true,
                        annotationItems: viewModel.MapLocations,
                        annotationContent: { location in
                        MapPin(coordinate: location.coordinate, tint: .red)
                    })
                        .edgesIgnoringSafeArea(.all)
                        .onAppear {
                            viewModel.checkIfLocatioServiceIsEnabled()
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
                                // Fallback on earlier versions
                            }
                        }
                        
                        Spacer(minLength: spacerHeight)

                        BottomSheetView(isOpen: $bottomSheetShown, maxHeight: gr.size.height * 0.8) { location in
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
