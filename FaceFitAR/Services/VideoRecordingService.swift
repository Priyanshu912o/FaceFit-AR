import Foundation
import AVFoundation
import SceneKit
import ARKit
import Photos

class VideoRecordingService: NSObject, ObservableObject {
    @Published var isRecording = false
    @Published var recordingDuration: TimeInterval = 0
    @Published var recordedVideoURL: URL?
    @Published var errorMessage: String?
    
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor?
    private var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var timer: Timer?
    private weak var arView: ARSCNView?
    
    private var outputURL: URL {
        let tempDir = FileManager.default.temporaryDirectory
        return tempDir.appendingPathComponent("FaceFitAR_\(Int(Date().timeIntervalSince1970)).mp4")
    }
    
    func startRecording(arView: ARSCNView) {
        guard !isRecording else { return }
        self.arView = arView
        
        let url = outputURL
        
        // Get AR view size for video dimensions
        let viewSize = arView.bounds.size
        let scale = UIScreen.main.scale
        let videoWidth = Int(viewSize.width * scale)
        let videoHeight = Int(viewSize.height * scale)
        
        // Set up AVAssetWriter
        do {
            assetWriter = try AVAssetWriter(outputURL: url, fileType: .mp4)
        } catch {
            errorMessage = "Failed to create video writer: \(error.localizedDescription)"
            return
        }
        
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: videoWidth,
            AVVideoHeightKey: videoHeight,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 6_000_000,
                AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
            ]
        ]
        
        videoInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        videoInput?.expectsMediaDataInRealTime = true
        
        let sourcePixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String: videoWidth,
            kCVPixelBufferHeightKey as String: videoHeight
        ]
        
        pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: videoInput!,
            sourcePixelBufferAttributes: sourcePixelBufferAttributes
        )
        
        if let videoInput = videoInput, assetWriter?.canAdd(videoInput) == true {
            assetWriter?.add(videoInput)
        }
        
        assetWriter?.startWriting()
        assetWriter?.startSession(atSourceTime: .zero)
        
        // Start frame capture using CADisplayLink
        startTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(captureFrame))
        displayLink?.preferredFrameRateRange = CAFrameRateRange(minimum: 24, maximum: 30, preferred: 30)
        displayLink?.add(to: .main, forMode: .common)
        
        DispatchQueue.main.async {
            self.isRecording = true
            self.recordingDuration = 0
            self.recordedVideoURL = url
            self.startDurationTimer()
        }
    }
    
    @objc private func captureFrame() {
        guard isRecording,
              let arView = arView,
              let videoInput = videoInput,
              videoInput.isReadyForMoreMediaData,
              let adaptor = pixelBufferAdaptor else { return }
        
        // Capture the AR view (camera feed + 3D filter overlays, no UI)
        let snapshot = arView.snapshot()
        
        guard let cgImage = snapshot.cgImage else { return }
        
        let elapsed = CACurrentMediaTime() - startTime
        let presentationTime = CMTime(seconds: elapsed, preferredTimescale: 600)
        
        // Create pixel buffer from snapshot
        var pixelBuffer: CVPixelBuffer?
        let width = cgImage.width
        let height = cgImage.height
        
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                          kCVPixelFormatType_32BGRA, attrs as CFDictionary,
                                          &pixelBuffer)
        
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return }
        
        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        
        adaptor.append(buffer, withPresentationTime: presentationTime)
    }
    
    func stopRecording(completion: @escaping (URL?) -> Void) {
        guard isRecording else {
            completion(nil)
            return
        }
        
        displayLink?.invalidate()
        displayLink = nil
        timer?.invalidate()
        timer = nil
        
        videoInput?.markAsFinished()
        
        assetWriter?.finishWriting { [weak self] in
            DispatchQueue.main.async {
                self?.isRecording = false
                let url = self?.recordedVideoURL
                completion(url)
            }
        }
    }
    
    func saveVideoToPhotos(url: URL, completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
            guard status == .authorized || status == .limited else {
                DispatchQueue.main.async { completion(false) }
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error saving video: \(error.localizedDescription)")
                    }
                    completion(success)
                }
            }
        }
    }
    
    private func startDurationTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.recordingDuration += 0.1
        }
    }
    
    func formattedDuration() -> String {
        let minutes = Int(recordingDuration) / 60
        let seconds = Int(recordingDuration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
