//
//  Extensions.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI

// Extension to create rounded corners
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCornerShape(radius: radius, corners: corners))
    }
}
