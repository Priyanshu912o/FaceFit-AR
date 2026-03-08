import SwiftUI

struct PrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color.theme.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: Color.theme.accent.opacity(0.4), radius: 12, x: 0, y: 6)
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.8 : 1.0)
    }
}
