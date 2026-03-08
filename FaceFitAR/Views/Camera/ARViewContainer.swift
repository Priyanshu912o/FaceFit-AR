import SwiftUI
import ARKit
import SceneKit

struct ARViewContainer: UIViewRepresentable {
    @ObservedObject var cameraVM: CameraViewModel
    @Binding var arView: ARSCNView?
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView(frame: .zero)
        sceneView.delegate = context.coordinator
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        DispatchQueue.main.async {
            self.arView = sceneView
        }
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking not supported on this device")
            return sceneView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
        
        DispatchQueue.main.async {
            cameraVM.isSessionRunning = true
        }
        
        return sceneView
    }
    
    func updateUIView(_ sceneView: ARSCNView, context: Context) {
        context.coordinator.currentFilter = cameraVM.selectedFilter
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(cameraVM: cameraVM)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var cameraVM: CameraViewModel
        var currentFilter: FilterType = .none {
            didSet {
                if currentFilter != oldValue {
                    updateFilterNode()
                }
            }
        }
        private var faceNode: SCNNode?
        private var filterNode: FaceFilterNode?
        
        init(cameraVM: CameraViewModel) {
            self.cameraVM = cameraVM
            super.init()
        }
        
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard anchor is ARFaceAnchor else { return nil }
            
            let node = SCNNode()
            faceNode = node
            
            let filter = FaceFilterNode(filterType: currentFilter)
            filterNode = filter
            node.addChildNode(filter)
            
            DispatchQueue.main.async {
                self.cameraVM.isFaceDetected = true
            }
            
            return node
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            filterNode?.updateWithBlendShapes(faceAnchor.blendShapes)
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
            guard anchor is ARFaceAnchor else { return }
            
            DispatchQueue.main.async {
                self.cameraVM.isFaceDetected = false
            }
            
            faceNode = nil
            filterNode = nil
        }
        
        private func updateFilterNode() {
            guard let faceNode = faceNode else { return }
            
            filterNode?.removeFromParentNode()
            
            let newFilter = FaceFilterNode(filterType: currentFilter)
            newFilter.opacity = 0
            faceNode.addChildNode(newFilter)
            filterNode = newFilter
            
            // Smooth fade-in transition
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.3
            newFilter.opacity = 1
            SCNTransaction.commit()
        }
    }
}
