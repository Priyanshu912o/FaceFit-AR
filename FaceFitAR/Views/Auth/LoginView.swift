import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color.theme.background, Color(hex: "1a0533")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                // Decorative blurred circles
                GeometryReader { geo in
                    Circle()
                        .fill(Color.theme.accent.opacity(0.15))
                        .frame(width: 300, height: 300)
                        .blur(radius: 60)
                        .offset(x: -100, y: -50)
                    
                    Circle()
                        .fill(Color(hex: "EC4899").opacity(0.1))
                        .frame(width: 250, height: 250)
                        .blur(radius: 50)
                        .offset(x: geo.size.width - 100, y: geo.size.height - 200)
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        Spacer().frame(height: 60)
                        
                        // Logo
                        VStack(spacing: 12) {
                            Image("LoginLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            
                            Text("FaceFit AR")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(Color.theme.textPrimary)
                            
                            Text("Sign in to continue")
                                .font(.subheadline)
                                .foregroundColor(Color.theme.textSecondary)
                        }
                        
                        // Form Card
                        VStack(spacing: 20) {
                            InputField(iconName: "envelope.fill", placeholder: "Email", text: $email)
                            InputField(iconName: "lock.fill", placeholder: "Password", text: $password, isSecure: true)
                            
                            if let error = authVM.errorMessage {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                    Text(error)
                                }
                                .font(.caption)
                                .foregroundColor(Color.theme.error)
                                .padding(.horizontal, 4)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                            
                            PrimaryButton(title: "Sign In", isLoading: authVM.isLoading) {
                                authVM.signIn(email: email, password: password)
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
                        
                        // Sign Up Link
                        Button {
                            showSignUp = true
                        } label: {
                            HStack(spacing: 4) {
                                Text("Don't have an account?")
                                    .foregroundColor(Color.theme.textSecondary)
                                Text("Sign Up")
                                    .foregroundColor(Color.theme.accentLight)
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                }
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .animation(.easeInOut, value: authVM.errorMessage)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
