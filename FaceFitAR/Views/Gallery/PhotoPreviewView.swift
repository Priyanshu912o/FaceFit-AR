import SwiftUI

struct PhotoPreviewView: View {
    let image: UIImage
    @ObservedObject var mediaVM: MediaViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar
                HStack {
                    Button {
                        mediaVM.reset()
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(12)
                            .background(Circle().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    Text("Preview")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                Spacer()
                
                // Image preview
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 20)
                    .shadow(color: Color.theme.accent.opacity(0.3), radius: 20, x: 0, y: 10)
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 24) {
                    // Retake
                    Button {
                        mediaVM.reset()
                        dismiss()
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.system(size: 22))
                            Text("Retake")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                        )
                    }
                    
                    // Save
                    Button {
                        mediaVM.savePhoto(image)
                    } label: {
                        VStack(spacing: 6) {
                            if mediaVM.isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else if mediaVM.isSaved {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(Color.theme.success)
                            } else {
                                Image(systemName: "square.and.arrow.down")
                                    .font(.system(size: 22))
                            }
                            Text(mediaVM.isSaved ? "Saved!" : "Save")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(mediaVM.isSaved ? Color.theme.success.opacity(0.3) : Color.theme.accent.opacity(0.6))
                        )
                    }
                    .disabled(mediaVM.isSaving || mediaVM.isSaved)
                    
                    // Share
                    ShareLink(item: Image(uiImage: image), preview: SharePreview("FaceFit AR Photo", image: Image(uiImage: image))) {
                        VStack(spacing: 6) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 22))
                            Text("Share")
                                .font(.caption)
                        }
                        .foregroundColor(.white)
                        .frame(width: 80, height: 70)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.15))
                        )
                    }
                }
                .padding(.bottom, 40)
                
                // Error message
                if let error = mediaVM.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color.theme.error)
                        .padding(.bottom, 16)
                }
            }
        }
        .animation(.easeInOut, value: mediaVM.isSaved)
    }
}
