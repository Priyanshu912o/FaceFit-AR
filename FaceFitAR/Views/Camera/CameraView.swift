import SwiftUI
import ARKit

struct CameraView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var cameraVM = CameraViewModel()
    @StateObject private var mediaVM = MediaViewModel()
    @StateObject private var videoService = VideoRecordingService()
    @State private var arView: ARSCNView?
    @State private var showFilterLabel = false
    @State private var filterLabelText = ""
    @State private var showVideoPreview = false
    @State private var recordedVideoURL: URL?
    
    var body: some View {
        ZStack {
            // AR Camera - full screen
            ARViewContainer(cameraVM: cameraVM, arView: $arView)
                .ignoresSafeArea()
            
            // Overlay UI
            VStack {
                // Top bar
                topBar
                
                Spacer()
                
                // Recording duration indicator
                if videoService.isRecording {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .opacity(recordingPulse ? 0.3 : 1.0)
                        
                        Text(videoService.formattedDuration())
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.red.opacity(0.7)))
                    .transition(.opacity.combined(with: .scale))
                    .padding(.bottom, 8)
                }
                
                // Filter name popup
                if showFilterLabel && !videoService.isRecording {
                    Text(filterLabelText)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.black.opacity(0.5))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                                )
                        )
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                        .padding(.bottom, 8)
                }
                
                // Face detection indicator
                if !cameraVM.isFaceDetected && cameraVM.isSessionRunning && !videoService.isRecording {
                    HStack(spacing: 8) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("Looking for face...")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(Color.black.opacity(0.5)))
                    .padding(.bottom, 8)
                }
                
                // Hint text
                if !videoService.isRecording {
                    Text("Tap for photo · Hold for video")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.bottom, 4)
                }
                
                // Unified capture button
                captureButton
                    .padding(.bottom, 12)
                
                // Filter selector (hide during recording)
                if !videoService.isRecording {
                    FilterSelectorView(
                        selectedFilter: $cameraVM.selectedFilter,
                        filters: cameraVM.sortedFilters,
                        onFilterSelected: { filter in
                            cameraVM.selectFilter(filter, userId: authVM.currentUser?.id)
                            showFilterPopup(filter.displayName)
                        }
                    )
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $cameraVM.showPreview) {
            if let image = cameraVM.capturedImage {
                PhotoPreviewView(image: image, mediaVM: mediaVM)
            }
        }
        .sheet(isPresented: $showVideoPreview) {
            if let url = recordedVideoURL {
                VideoPreviewView(videoURL: url, mediaVM: mediaVM)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: cameraVM.isFaceDetected)
        .animation(.spring(response: 0.4), value: showFilterLabel)
        .animation(.easeInOut(duration: 0.3), value: videoService.isRecording)
        .onAppear {
            if let userId = authVM.currentUser?.id {
                cameraVM.loadFilterOrder(userId: userId)
            }
        }
    }
    
    @State private var recordingPulse = false
    @State private var isLongPressing = false
    @GestureState private var isDetectingLongPress = false
    
    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Color.theme.accent.opacity(0.3))
                        .frame(width: 38, height: 38)
                    
                    Text(String(authVM.currentUser?.displayName.prefix(1).uppercased() ?? "U"))
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                if let name = authVM.currentUser?.displayName {
                    Text(name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            if !videoService.isRecording {
                Button {
                    authVM.signOut()
                } label: {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Circle().fill(Color.black.opacity(0.4)))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Unified Capture Button (Tap = Photo, Long Press = Video)
    private var captureButton: some View {
        ZStack {
            // Outer ring — white normally, red when recording
            Circle()
                .stroke(videoService.isRecording ? Color.red : Color.white, lineWidth: 4)
                .frame(width: 72, height: 72)
                .scaleEffect(videoService.isRecording ? 1.15 : 1.0)
            
            // Inner circle — white normally, red square when recording
            if videoService.isRecording {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.red)
                    .frame(width: 28, height: 28)
            } else {
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
            }
        }
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
        .onTapGesture {
            if videoService.isRecording {
                // Tap to stop recording
                stopRecording()
            } else {
                // Tap for photo
                if let arView = arView {
                    cameraVM.capturePhoto(from: arView)
                }
            }
        }
        .onLongPressGesture(minimumDuration: 0.5, perform: {
            // Long press starts recording
            if !videoService.isRecording {
                startRecording()
            }
        })
        .animation(.easeInOut(duration: 0.3), value: videoService.isRecording)
    }
    
    // MARK: - Recording Controls
    private func startRecording() {
        guard let arView = arView else { return }
        videoService.startRecording(arView: arView)
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
            recordingPulse = true
        }
    }
    
    private func stopRecording() {
        recordingPulse = false
        videoService.stopRecording { url in
            guard let url = url else { return }
            recordedVideoURL = url
            mediaVM.reset()
            showVideoPreview = true
        }
    }
    
    private func showFilterPopup(_ name: String) {
        filterLabelText = name
        showFilterLabel = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            showFilterLabel = false
        }
    }
}
