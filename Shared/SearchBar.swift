//
//  SearchBar.swift
//  maps
//
//  Created by Anthony José on 01/11/21.
//

import SwiftUI

// SearchBar
struct SearchBar<Content: View>: View {
    
    let content: Content
    
    init (@ViewBuilder content: @escaping () -> Content) {
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
