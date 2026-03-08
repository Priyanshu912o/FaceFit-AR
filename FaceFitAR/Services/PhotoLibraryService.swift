import Photos
import UIKit

class PhotoLibraryService {
    func saveToPhotoLibrary(image: UIImage, completion: @escaping (Bool, Error?) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async {
                    completion(false, NSError(
                        domain: "PhotoLibrary",
                        code: 1,
                        userInfo: [NSLocalizedDescriptionKey: "Photo library access denied. Please enable in Settings."]
                    ))
                }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAsset(from: image)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
}
