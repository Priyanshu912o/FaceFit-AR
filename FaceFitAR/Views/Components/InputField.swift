import SwiftUI

struct InputField: View {
    let iconName: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    @State private var isPasswordVisible = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: iconName)
                .foregroundColor(isFocused ? Color.theme.accent : Color.theme.textSecondary)
                .frame(width: 20)
                .animation(.easeInOut(duration: 0.2), value: isFocused)
            
            if isSecure && !isPasswordVisible {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Color.theme.textPrimary)
                    .focused($isFocused)
                    .autocapitalization(.none)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Color.theme.textPrimary)
                    .focused($isFocused)
                    .autocapitalization(.none)
                    .keyboardType(isSecure ? .default : .emailAddress)
            }
            
            if isSecure {
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(Color.theme.textSecondary)
                        .frame(width: 20)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.theme.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(isFocused ? Color.theme.accent.opacity(0.6) : Color.clear, lineWidth: 1.5)
                )
        )
    }
}
