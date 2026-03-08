import Foundation
import FirebaseCore
import FirebaseFirestore

class FirestoreService {
    private var db: Firestore? {
        guard FirebaseApp.app() != nil else {
            print("⚠️ Firebase not configured — Firestore unavailable.")
            return nil
        }
        return Firestore.firestore()
    }
    
    func saveUser(_ user: AppUser) {
        guard let db = db else { return }
        do {
            try db.collection("users").document(user.id).setData(from: user)
        } catch {
            print("Error saving user: \(error.localizedDescription)")
        }
    }
    
    func fetchUser(uid: String, completion: @escaping (AppUser?) -> Void) {
        guard let db = db else {
            completion(nil)
            return
        }
        db.collection("users").document(uid).getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else {
                completion(nil)
                return
            }
            
            let user = AppUser(
                id: data["id"] as? String ?? uid,
                email: data["email"] as? String ?? "",
                displayName: data["displayName"] as? String ?? "",
                createdAt: (data["createdAt"] as? Timestamp)?.dateValue() ?? Date()
            )
            completion(user)
        }
    }
    
    func logFilterUsage(userId: String, filterType: FilterType) {
        guard let db = db else { return }
        let data: [String: Any] = [
            "userId": userId,
            "filterType": filterType.rawValue,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        db.collection("filterUsage").addDocument(data: data) { error in
            if let error = error {
                print("Error logging filter usage: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetches filter usage counts for a specific user from Firestore
    func fetchFilterUsageCounts(userId: String, completion: @escaping ([FilterType: Int]) -> Void) {
        guard let db = db else {
            completion([:])
            return
        }
        
        db.collection("filterUsage")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents, error == nil else {
                    completion([:])
                    return
                }
                
                var counts: [FilterType: Int] = [:]
                for doc in documents {
                    if let rawType = doc.data()["filterType"] as? String,
                       let filterType = FilterType(rawValue: rawType) {
                        counts[filterType, default: 0] += 1
                    }
                }
                completion(counts)
            }
    }
}
