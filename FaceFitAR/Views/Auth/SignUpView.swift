import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var localError: String?
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.theme.background, Color(hex: "1a0533")],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            GeometryReader { geo in
                Circle()
                    .fill(Color(hex: "EC4899").opacity(0.12))
                    .frame(width: 280, height: 280)
                    .blur(radius: 55)
                    .offset(x: geo.size.width - 140, y: -40)
                
                Circle()
                    .fill(Color.theme.accent.opacity(0.12))
                    .frame(width: 220, height: 220)
                    .blur(radius: 45)
                    .offset(x: -60, y: geo.size.height - 250)
            }
            .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    Spacer().frame(height: 40)
                    
                    // Header
                    VStack(spacing: 12) {
                        Image("LoginLogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Join FaceFit AR today")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    
                    // Form Card
                    VStack(spacing: 18) {
                        InputField(iconName: "person.fill", placeholder: "Full Name", text: $name)
                        InputField(iconName: "envelope.fill", placeholder: "Email", text: $email)
                        InputField(iconName: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                        InputField(iconName: "lock.shield.fill", placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
                        
                        if let error = localError ?? authVM.errorMessage {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .font(.caption)
                            .foregroundColor(Color.theme.error)
                            .padding(.horizontal, 4)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        PrimaryButton(title: "Create Account", isLoading: authVM.isLoading) {
                            attemptSignUp()
                        }
                        .padding(.top, 4)
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.theme.cardBg.opacity(0.8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Back to Login
                    Button {
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .foregroundColor(Color.theme.textSecondary)
                            Text("Sign In")
                                .foregroundColor(Color.theme.accentLight)
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color.theme.textPrimary)
                        .padding(8)
                        .background(Circle().fill(Color.theme.surface))
                }
            }
        }
        .animation(.easeInOut, value: localError)
        .animation(.easeInOut, value: authVM.errorMessage)
    }
    
    private func attemptSignUp() {
        localError = nil
        
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            localError = "Please enter your name."
            return
        }
        
        guard password == confirmPassword else {
            localError = "Passwords do not match."
            return
        }
        
        authVM.signUp(email: email, password: password, name: name)
    }
}
