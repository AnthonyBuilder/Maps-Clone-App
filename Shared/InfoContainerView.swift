//
//  InfoContainerView.swift
//  maps
//
//  Created by Anthony José on 12/11/21.
//

import Foundation
import SwiftUI

struct InfoContainerView: View {
    @State var landmarkName: String = ""
    @State var landmarkTitle: String = ""
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack(alignment: .leading, spacing: 5) {
                Text(landmarkName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(landmarkTitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
    }
}
