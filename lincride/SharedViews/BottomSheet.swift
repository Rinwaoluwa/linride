//
//  BottomSheet.swift
//  lincride
//
//  Created by Adeoluwa on 25/02/2025.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    @State private var sheetHeight: CGFloat = UIScreen.main.bounds.height * 0.4
    
    let content: () -> Content
    
    @Binding var showSheet: Bool
    
    private let mediumDetent = UIScreen.main.bounds.height * 0.8
    private let smallDetent = UIScreen.main.bounds.height * 0.4
    
    init(
        showSheet: Binding<Bool>,
        content: @escaping () -> Content
        
    ) {
        self.content = content
        self._showSheet = showSheet
    }
    
    var body: some View {
        VStack {
            Spacer()
            VStack {
                // Handle for dragging
                RoundedRectangle(cornerRadius: 2.5)
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray)
                    .padding(.top, 10)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                let newHeight = sheetHeight - value.translation.height
                                if newHeight >= UIScreen.main.bounds.height * 0.1 &&
                                    newHeight <= UIScreen.main.bounds.height * 0.8 {
                                    sheetHeight = newHeight
                                }
                            }
                            .onEnded { value in
                                if sheetHeight > mediumDetent * 0.8 {
                                    withAnimation(.spring()) {
                                        sheetHeight = mediumDetent
                                        self.showSheet = true
                                    }
                                } else {
                                    withAnimation(.spring()) {
                                        sheetHeight = smallDetent
                                        self.showSheet = false
                                    }
                                }
                            }
                    )
                
                // Your bottom sheet content here
                content()
                
                Spacer()
            }
            .frame(height: showSheet ? mediumDetent : sheetHeight)
            .frame(maxWidth: .infinity)
            .background(.ultraThinMaterial)
            .cornerRadius(16, corners: [.topLeft, .topRight])
        }.onChange(of: showSheet, { _, _ in
            // if show sheet is false set sheet height to medium height
            if(!showSheet) {
                withAnimation {
                    sheetHeight = smallDetent
                }
            }
        })
        .ignoresSafeArea(edges: .bottom)
    }
}

struct RoundedCornerShape: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

//#Preview {
//    BottomSheet {
//        Text("TESTING")
//    }
//}
