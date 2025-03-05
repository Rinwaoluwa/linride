//
//  LookAroundView.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI
import MapKit

struct LookAroundView: View {
    var viewModel: MapView.ViewModel
    
    private var travelTime: String? {
        let route = viewModel.route
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: route?.expectedTravelTime ?? 00)
    }
    
    var body: some View {
        LookAroundPreview(initialScene: viewModel.lookAroundScene)
            .overlay(alignment: .bottomTrailing) {
                HStack {
                    Text("\(viewModel.selectedLocation?.name ?? "")")
                    if let travelTime {
                        Text(travelTime)
                    }
                }
                .font(.caption)
                .foregroundStyle(.white)
                .padding(10)
            }
            .onChange(of: viewModel.selectedLocation) {
                viewModel.getLookAroundScene()
            }
            .onAppear {
                viewModel.getLookAroundScene()
                
            }
    }
    
}



//#Preview {
//    LookAroundView()
//}
