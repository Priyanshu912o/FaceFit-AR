import Foundation
import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: AppUser?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    private let firestoreService = FirestoreService()
    
    /// Whether Firebase is configured (GoogleService-Info.plist exists)
    private var isFirebaseConfigured: Bool {
        return FirebaseApp.app() != nil
    }
    
    init() {
        guard isFirebaseConfigured else {
            print("⚠️ Firebase not configured — auth features disabled.")
            return
        }
        listenToAuthState()
    }
    
    deinit {
        if let listener = authStateListener {
            if isFirebaseConfigured {
                Auth.auth().removeStateDidChangeListener(listener)
            }
        }
    }
    
    private func listenToAuthState() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.isAuthenticated = user != nil
                if let user = user {
                    self?.fetchUser(uid: user.uid)
                } else {
                    self?.currentUser = nil
                }
            }
        }
    }
    
    func signUp(email: String, password: String, name: String) {
        guard isFirebaseConfigured else {
            errorMessage = "Firebase not configured. Please add GoogleService-Info.plist."
            return
        }
        guard validateInputs(email: email, password: password, name: name) else { return }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                    return
                }
                
                guard let uid = result?.user.uid else { return }
                
                let newUser = AppUser(
                    id: uid,
                    email: email,
                    displayName: name,
                    createdAt: Date()
                )
                
                self?.firestoreService.saveUser(newUser)
                self?.currentUser = newUser
            }
        }
    }
    
    func signIn(email: String, password: String) {
        guard isFirebaseConfigured else {
            errorMessage = "Firebase not configured. Please add GoogleService-Info.plist."
            return
        }
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func signOut() {
        guard isFirebaseConfigured else { return }
        do {
            try Auth.auth().signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    private func fetchUser(uid: String) {
        firestoreService.fetchUser(uid: uid) { [weak self] user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    private func validateInputs(email: String, password: String, name: String) -> Bool {
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            errorMessage = "Please enter your name."
            return false
        }
        if !isValidEmail(email) {
            errorMessage = "Please enter a valid email address."
            return false
        }
        if password.count < 6 {
            errorMessage = "Password must be at least 6 characters."
            return false
        }
        return true
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let regex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email)
    }
}
