import Foundation

struct AppUser: Codable, Identifiable {
    var id: String
    var email: String
    var displayName: String
    var createdAt: Date
    
    var dictionary: [String: Any] {
        return [
            "id": id,
            "email": email,
            "displayName": displayName,
            "createdAt": createdAt
        ]
    }
}
