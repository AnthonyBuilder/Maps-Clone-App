//
//  InfoContainerView.swift
//  maps
//
//  Created by Anthony José on 12/11/21.
//

import Foundation
import SwiftUI
import MapKit

struct InfoContainerView<Content: View>: View {
    @Binding var landmarkName: String
    @Binding var landmarkTitle: String
    
    private let content: Content
    
    init(landmarkName: Binding<String>, landmarkTitle: Binding<String>, @ViewBuilder content: @escaping () -> Content) {
        self._landmarkName = landmarkName
        self._landmarkTitle = landmarkTitle
        self.content = content()
    }
    var body: some View {
        if #available(iOS 15.0, *) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(landmarkName)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(landmarkTitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                content
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
