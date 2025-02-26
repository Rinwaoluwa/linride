//
//  LoadingView.swift
//  lincride
//
//  Created by Adeoluwa on 26/02/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(.circular)
            Spacer()
        }
    }
}

#Preview {
    LoadingView()
}
