import SwiftUI

struct ErrorView: View {
    let model: ErrorPageModel
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Error Icon (SF Symbol)
            Image(systemName: model.iconName)
                .font(.system(size: 60))
                .foregroundColor(.red.opacity(0.8))
            
            // Error Title
            Text(model.errorTitle)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            // Error Description
            Text(model.errorDescription)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Actions
            VStack(spacing: 12) {
                // Primary retry button
                if let retryAction = model.retryAction {
                    Button(action: retryAction) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Try Again")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                
                // Secondary action button
                if let secondaryAction = model.secondaryAction,
                   let secondaryTitle = model.secondaryActionTitle {
                    Button(action: secondaryAction) {
                        Text(secondaryTitle)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, 40)
            .padding(.top, 10)
            
            Spacer()
        }
        .padding()
    }
}

// MARK: - Preview
#Preview {
    VStack {
        ErrorView(model: ErrorPageModel(
            errorTitle: "No Internet Connection",
            errorDescription: "Check your connection and try again.",
            iconName: "wifi.slash",
            retryAction: { print("Retry tapped") }
        ))
    }
}
