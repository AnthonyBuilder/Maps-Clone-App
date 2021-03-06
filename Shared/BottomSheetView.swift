//
//  BottomSheetView.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI


fileprivate enum Constants {
    static let minHeightRatio: CGFloat = 0.3
}

// Bottom sheet contents
struct BottomSheetView<Content: View>: View {
    
    @Binding var isOpen: Bool
    @Binding var isShowLocationPlacemark: Bool
    
    @State private var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.40
    @State private var currentDragOffsetY: CGFloat = 0
    @State private var endingOffsetY: CGFloat = 3.00
    @State private var local = ""
    
    private let content: (Landmark) -> Content
    
    @StateObject var mapViewModel: MapViewModel = .init()
    
    let minHeight: CGFloat
    let maxHeight: CGFloat
    
    init(isOpen: Binding<Bool>, isShowLocationPlacemark: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: @escaping (Landmark) -> Content) {
        self.minHeight = maxHeight * Constants.minHeightRatio
        self.maxHeight = maxHeight
        self.content = content
        self._isOpen = isOpen
        self._isShowLocationPlacemark = isShowLocationPlacemark
    }
    
    var otherActions: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                if isOpen == true {
                    ForEach(mapViewModel.landmarks, id: \.id) { location in
                        content(location)
                    }
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    
    func showResultsSearchLocations() {
        if local.isEmpty {
            mapViewModel.landmarks.removeAll()
        } else {
            mapViewModel.getNearByLandmarks(location: $local)
        }
    }
    
    
    //  MARK: Body - View
    var body: some View {
        
        if #available(iOS 15.0, *) {
            VStack {
                VStack(alignment: .center) {
                    Capsule()
                        .background(Color.gray.opacity(0.05))
                        .frame(width: 25, height: 5, alignment: .center)
                        .padding(5)
                }
                
                if isShowLocationPlacemark == false {
                    SearchBar {
                        TextField("Buscar no App Mapas", text: $local, onEditingChanged: { _ in
                            if isOpen {
                                showResultsSearchLocations()
                            } else if isOpen == false {
                                isOpen = true
                                showResultsSearchLocations()
                            } else if local.isEmpty && isOpen == true {
                                isOpen = false
                            }
                        })
                            .onSubmit {
                                if local.isEmpty == true {
                                    isOpen = false
                                } else {
                                    isOpen = true
                                    showResultsSearchLocations()
                                }
                            }
                            .onTapGesture {
                                if isOpen == false {
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
                                            isOpen = false
                                        }
                                }, alignment: .trailing
                            )
                    }.padding([.horizontal, .bottom])
                } else {
                    VStack {
                        HStack {
                            VStack {
                                Text("name")
                                    .font(.title3)
                                    .bold()
                                Text("title")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                if isOpen == true {
                    otherActions
                } else {
                    // fix bogus!
                    // titleMarkLocation
                }
            }
            .frame(height: isOpen ? self.maxHeight : 75)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
            .cornerRadius(20)
            
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


