//
//  LookAroundView.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI
import MapKit

struct LookAroundView: View {
    let lookAroundScene: MKLookAroundScene?
    let selectedResult: MKMapItem?
    let route: MKRoute?
    
    private var travelTime: String? {
        guard let route else { return nil }
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route.expectedTravelTime)
    }
    
    var body: some View {
        LookAroundPreview(initialScene: lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(selectedResult?.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
    }
    
}



//#Preview {
//    LookAroundView()
//}
