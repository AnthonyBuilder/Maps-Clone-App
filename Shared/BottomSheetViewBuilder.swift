//
//  BottomSheetViewBuilder.swift
//  maps
//
//  Created by Anthony José on 09/11/21.
//

import Foundation
import SwiftUI

struct BottomSheetViewBuilder<Content: View>: View {
    
    @State var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @Binding var isShowing: Bool
    
    private let content: Content
    
    @State var offset: CGFloat = 0
    @State var lastOffset: CGFloat = 0
    @GestureState var gestureOffset: CGFloat = 0
    
    let maxHeight: CGFloat
    
    init(isShowing: Binding<Bool>, maxHeight: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.content = content()
        self._isShowing = isShowing
        self.maxHeight = maxHeight
    }
    
    var body: some View {
        VStack {
            Spacer()
            if #available(iOS 15.0, *) {
                VStack(spacing: 18) {
                    Capsule().frame(width: 30, height: 5, alignment: .center).opacity(0.5).foregroundColor(.primary).padding(.top, 10)
                    content
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 25))
                .offset(y: maxHeight)
                .offset(y: isShowing ? offset : 0)
                .gesture(
                    DragGesture().updating($gestureOffset, body: { value, out, _ in
                        out = value.translation.height
                        onChange()
                    }).onEnded({value in
                        withAnimation(.spring()) {
                            // Logic for moving states
                            // Up down or mid...
                            if -offset > 100 && -offset < maxHeight - 250 / 2 {
                                // Mid...
                                offset = -(maxHeight / 3) - 50
                                isShowing = true
                            } else if -offset > maxHeight / 2 {
                                offset = -maxHeight + 50
                                isShowing = true
                            } else {
                                offset = 0
                                isShowing = false
                            }
                        }
                        lastOffset = offset
                    })
                )
            }
        }
    }
    
    func onChange() {
        DispatchQueue.main.async {
            self.offset = gestureOffset + lastOffset
        }
    }
}
