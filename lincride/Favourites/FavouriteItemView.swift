//
//  FavouriteItem.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI

struct FavoriteItemView: View {
    let item: FavoriteItem
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(.ultraThickMaterial)
                    .frame(width: 60, height: 60)
                
                Image(systemName: item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            }
            
            Text(item.title)
                .font(.title3)
            Text(item.subtitle)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .frame(width: 80)
    }
    
}


#Preview {
    let item =     FavoriteItem(icon: "plus", title: "Club", subtitle:  "nightout", value: "Pubs")
    FavoriteItemView(item: item)
}
