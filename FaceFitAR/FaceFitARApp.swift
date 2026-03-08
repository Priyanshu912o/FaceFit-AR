import SwiftUI
import FirebaseCore

@main
struct FaceFitARApp: App {
    @StateObject private var authVM: AuthViewModel
    
    init() {
        // Configure Firebase BEFORE creating any ViewModels that use it
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        } else {
            print("⚠️ GoogleService-Info.plist not found. Firebase features will not work.")
            print("⚠️ Download it from Firebase Console and add it to the Xcode project.")
        }
        
        // Now safe to create AuthViewModel
        _authVM = StateObject(wrappedValue: AuthViewModel())
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isAuthenticated {
                    CameraView()
                } else {
                    LoginView()
                }
            }
            .environmentObject(authVM)
            .preferredColorScheme(.dark)
        }
    }
}
