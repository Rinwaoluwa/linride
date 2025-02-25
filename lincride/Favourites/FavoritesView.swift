//
//  FavoritesView.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI

import SwiftUI

struct FavoritesView: View {
    let onSelectFavouriteItem: (FavoriteItem) -> Void
    let favorites = [
        FavoriteItem(icon: "mappin.and.ellipse", title: "Parks", subtitle:  "outdoors",value: "Parks" ),
        FavoriteItem(icon: "cart.badge.plus", title: "Food", subtitle:  "healthy", value: "Store"),
        FavoriteItem(icon: "music.mic", title: "Club", subtitle:  "nightout", value: "Pubs"),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Favourites")
                .font(.headline)
            
            HStack(spacing: 20) {
                ForEach(favorites, id: \.icon) { item in
                    FavoriteItemView(item: item).onTapGesture {
                        onSelectFavouriteItem(item)
                    }
                }
            }
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding()
    }
}


#Preview {
    FavoritesView { favoriteItem in
        
    }
}
