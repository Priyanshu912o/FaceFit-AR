import SwiftUI
import ARKit

struct CameraView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var cameraVM = CameraViewModel()
    @StateObject private var mediaVM = MediaViewModel()
    @State private var arView: ARSCNView?
    @State private var showFilterLabel = false
    @State private var filterLabelText = ""
    
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
                
                // Filter name popup
                if showFilterLabel {
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
                if !cameraVM.isFaceDetected && cameraVM.isSessionRunning {
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
                
                // Capture button
                captureButton
                    .padding(.bottom, 12)
                
                // Filter selector
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
        .sheet(isPresented: $cameraVM.showPreview) {
            if let image = cameraVM.capturedImage {
                PhotoPreviewView(image: image, mediaVM: mediaVM)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: cameraVM.isFaceDetected)
        .animation(.spring(response: 0.4), value: showFilterLabel)
        .onAppear {
            if let userId = authVM.currentUser?.id {
                cameraVM.loadFilterOrder(userId: userId)
            }
        }
    }
    
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
        .padding(.horizontal, 20)
        .padding(.top, 10)
    }
    
    // MARK: - Capture Button
    private var captureButton: some View {
        Button {
            if let arView = arView {
                cameraVM.capturePhoto(from: arView)
            }
        } label: {
            ZStack {
                Circle()
                    .stroke(Color.white, lineWidth: 4)
                    .frame(width: 72, height: 72)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 60, height: 60)
            }
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
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
