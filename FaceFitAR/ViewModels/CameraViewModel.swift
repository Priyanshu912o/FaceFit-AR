import Foundation
import ARKit
import Combine

class CameraViewModel: ObservableObject {
    @Published var selectedFilter: FilterType = .none
    @Published var isSessionRunning = false
    @Published var isFaceDetected = false
    @Published var capturedImage: UIImage?
    @Published var showPreview = false
    @Published var sortedFilters: [FilterModel] = FilterModel.allFilters
    
    private let firestoreService = FirestoreService()
    private var usageCounts: [FilterType: Int] = [:]
    
    func selectFilter(_ filter: FilterType, userId: String?) {
        let previousFilter = selectedFilter
        selectedFilter = filter
        
        if filter != .none, filter != previousFilter, let userId = userId {
            firestoreService.logFilterUsage(userId: userId, filterType: filter)
        }
    }
    
    /// Fetches usage data from Firestore and sorts filters by frequency
    func loadFilterOrder(userId: String) {
        firestoreService.fetchFilterUsageCounts(userId: userId) { [weak self] counts in
            DispatchQueue.main.async {
                self?.usageCounts = counts
                self?.sortFiltersByUsage()
            }
        }
    }
    
    /// Sorts filters: "None" always first, then by usage count (most used first)
    private func sortFiltersByUsage() {
        let allFilters = FilterModel.allFilters
        
        // Keep "None" at the front, sort the rest by usage count (descending)
        let noneFilter = allFilters.filter { $0.filterType == .none }
        let otherFilters = allFilters
            .filter { $0.filterType != .none }
            .sorted { usageCounts[$0.filterType, default: 0] > usageCounts[$1.filterType, default: 0] }
        
        sortedFilters = noneFilter + otherFilters
    }
    
    func capturePhoto(from arView: ARSCNView) {
        let snapshot = arView.snapshot()
        DispatchQueue.main.async {
            self.capturedImage = snapshot
            self.showPreview = true
        }
    }
}
