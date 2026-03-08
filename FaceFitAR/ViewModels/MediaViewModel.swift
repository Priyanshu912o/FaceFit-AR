import Foundation
import UIKit

class MediaViewModel: ObservableObject {
    @Published var isSaving = false
    @Published var isSaved = false
    @Published var errorMessage: String?
    
    private let photoService = PhotoLibraryService()
    
    func savePhoto(_ image: UIImage) {
        isSaving = true
        errorMessage = nil
        
        photoService.saveToPhotoLibrary(image: image) { [weak self] success, error in
            DispatchQueue.main.async {
                self?.isSaving = false
                if success {
                    self?.isSaved = true
                } else {
                    self?.errorMessage = error?.localizedDescription ?? "Failed to save photo."
                }
            }
        }
    }
    
    func reset() {
        isSaved = false
        errorMessage = nil
    }
}
