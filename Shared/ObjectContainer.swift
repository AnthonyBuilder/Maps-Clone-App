//
//  ObjectContainer.swift
//  maps
//
//  Created by Anthony José on 27/10/21.
//

import SwiftUI
import CoreData

// Example of shortcut buttons to your favorite location.
// Storing data in core data.

//var landmaks: Landmark = Landmark()

struct ObjectContainer: View {
    var title = ""
    var subtitle = ""
    var icon = ""
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
            }.padding(10)
                .background(Color("BackgroundComponents").opacity(0.5))
                .cornerRadius(15)
        }.padding(.leading, 10)
    }
}

