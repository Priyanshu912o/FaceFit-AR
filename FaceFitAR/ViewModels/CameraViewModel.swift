import Foundation
import ARKit
import Combine

class CameraViewModel: ObservableObject {
    @Published var selectedFilter: FilterType = .none
    @Published var isSessionRunning = false
    @Published var isFaceDetected = false
    @Published var capturedImage: UIImage?
    @Published var showPreview = false
    
    private let firestoreService = FirestoreService()
    
    func selectFilter(_ filter: FilterType, userId: String?) {
        let previousFilter = selectedFilter
        selectedFilter = filter
        
        if filter != .none, filter != previousFilter, let userId = userId {
            firestoreService.logFilterUsage(userId: userId, filterType: filter)
        }
    }
    
    func capturePhoto(from arView: ARSCNView) {
        let snapshot = arView.snapshot()
        DispatchQueue.main.async {
            self.capturedImage = snapshot
            self.showPreview = true
        }
    }
}
