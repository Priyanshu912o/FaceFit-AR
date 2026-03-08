import SceneKit
import ARKit

class FaceFilterNode: SCNNode {
    
    let filterType: FilterType
    
    init(filterType: FilterType) {
        self.filterType = filterType
        super.init()
        setupFilter()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    private func setupFilter() {
        switch filterType {
        case .none:
            break
        case .sunglasses:
            setupSunglasses()
        case .devil:
            setupDevil()
        case .crown:
            setupCrown()
        case .mask:
            setupMask()
        }
    }
    
    // MARK: - Sunglasses
    private func setupSunglasses() {
        let leftLens = SCNPlane(width: 0.03, height: 0.025)
        leftLens.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.85)
        leftLens.cornerRadius = 0.005
        let leftNode = SCNNode(geometry: leftLens)
        leftNode.position = SCNVector3(-0.032, 0.025, 0.06)
        
        let rightLens = SCNPlane(width: 0.03, height: 0.025)
        rightLens.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.85)
        rightLens.cornerRadius = 0.005
        let rightNode = SCNNode(geometry: rightLens)
        rightNode.position = SCNVector3(0.032, 0.025, 0.06)
        
        let bridge = SCNCylinder(radius: 0.002, height: 0.025)
        bridge.firstMaterial?.diffuse.contents = UIColor.darkGray
        let bridgeNode = SCNNode(geometry: bridge)
        bridgeNode.position = SCNVector3(0, 0.025, 0.06)
        bridgeNode.eulerAngles = SCNVector3(0, 0, Float.pi / 2)
        
        let leftFrame = SCNTorus(ringRadius: 0.017, pipeRadius: 0.002)
        leftFrame.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let leftFrameNode = SCNNode(geometry: leftFrame)
        leftFrameNode.position = SCNVector3(-0.032, 0.025, 0.06)
        leftFrameNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        let rightFrame = SCNTorus(ringRadius: 0.017, pipeRadius: 0.002)
        rightFrame.firstMaterial?.diffuse.contents = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
        let rightFrameNode = SCNNode(geometry: rightFrame)
        rightFrameNode.position = SCNVector3(0.032, 0.025, 0.06)
        rightFrameNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        [leftNode, rightNode, bridgeNode, leftFrameNode, rightFrameNode].forEach { addChildNode($0) }
    }
    
    // MARK: - Devil Horns
    private func setupDevil() {
        let leftHorn = SCNCone(topRadius: 0, bottomRadius: 0.012, height: 0.06)
        leftHorn.firstMaterial?.diffuse.contents = UIColor.red
        let leftHornNode = SCNNode(geometry: leftHorn)
        leftHornNode.position = SCNVector3(-0.05, 0.13, 0.0)
        leftHornNode.eulerAngles = SCNVector3(0, 0, Float.pi * 0.15)
        
        let rightHorn = SCNCone(topRadius: 0, bottomRadius: 0.012, height: 0.06)
        rightHorn.firstMaterial?.diffuse.contents = UIColor.red
        let rightHornNode = SCNNode(geometry: rightHorn)
        rightHornNode.position = SCNVector3(0.05, 0.13, 0.0)
        rightHornNode.eulerAngles = SCNVector3(0, 0, -Float.pi * 0.15)
        
        let leftBrow = SCNPlane(width: 0.025, height: 0.005)
        leftBrow.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.6)
        let leftBrowNode = SCNNode(geometry: leftBrow)
        leftBrowNode.position = SCNVector3(-0.032, 0.045, 0.06)
        leftBrowNode.eulerAngles = SCNVector3(0, 0, Float.pi * 0.1)
        
        let rightBrow = SCNPlane(width: 0.025, height: 0.005)
        rightBrow.firstMaterial?.diffuse.contents = UIColor.red.withAlphaComponent(0.6)
        let rightBrowNode = SCNNode(geometry: rightBrow)
        rightBrowNode.position = SCNVector3(0.032, 0.045, 0.06)
        rightBrowNode.eulerAngles = SCNVector3(0, 0, -Float.pi * 0.1)
        
        [leftHornNode, rightHornNode, leftBrowNode, rightBrowNode].forEach { addChildNode($0) }
    }
    
    // MARK: - Crown
    private func setupCrown() {
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        
        let base = SCNTorus(ringRadius: 0.05, pipeRadius: 0.005)
        base.firstMaterial?.diffuse.contents = gold
        base.firstMaterial?.specular.contents = UIColor.white
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.13, -0.02)
        baseNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        addChildNode(baseNode)
        
        for i in 0..<5 {
            let angle = Float(i) * (2 * Float.pi / 5)
            let point = SCNPyramid(width: 0.015, height: 0.03, length: 0.015)
            point.firstMaterial?.diffuse.contents = gold
            point.firstMaterial?.specular.contents = UIColor.white
            let pointNode = SCNNode(geometry: point)
            pointNode.position = SCNVector3(sin(angle) * 0.045, 0.14, cos(angle) * 0.045 - 0.02)
            addChildNode(pointNode)
        }
        
        for i in stride(from: 0, to: 5, by: 2) {
            let angle = Float(i) * (2 * Float.pi / 5)
            let jewel = SCNSphere(radius: 0.004)
            jewel.firstMaterial?.diffuse.contents = UIColor.red
            jewel.firstMaterial?.specular.contents = UIColor.white
            let jewelNode = SCNNode(geometry: jewel)
            jewelNode.position = SCNVector3(sin(angle) * 0.045, 0.15, cos(angle) * 0.045 - 0.02)
            addChildNode(jewelNode)
        }
    }
    
    // MARK: - Neon Mask
    private func setupMask() {
        let faceOverlay = SCNPlane(width: 0.14, height: 0.17)
        faceOverlay.firstMaterial?.diffuse.contents = UIColor(red: 0.48, green: 0.23, blue: 0.93, alpha: 0.35)
        faceOverlay.firstMaterial?.isDoubleSided = true
        faceOverlay.cornerRadius = 0.04
        let overlayNode = SCNNode(geometry: faceOverlay)
        overlayNode.position = SCNVector3(0, 0.01, 0.055)
        
        let leftEye = SCNTorus(ringRadius: 0.016, pipeRadius: 0.003)
        leftEye.firstMaterial?.diffuse.contents = UIColor.cyan
        leftEye.firstMaterial?.emission.contents = UIColor.cyan
        let leftEyeNode = SCNNode(geometry: leftEye)
        leftEyeNode.position = SCNVector3(-0.032, 0.025, 0.065)
        leftEyeNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        let rightEye = SCNTorus(ringRadius: 0.016, pipeRadius: 0.003)
        rightEye.firstMaterial?.diffuse.contents = UIColor.cyan
        rightEye.firstMaterial?.emission.contents = UIColor.cyan
        let rightEyeNode = SCNNode(geometry: rightEye)
        rightEyeNode.position = SCNVector3(0.032, 0.025, 0.065)
        rightEyeNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        
        let noseLine = SCNCylinder(radius: 0.002, height: 0.025)
        noseLine.firstMaterial?.diffuse.contents = UIColor.cyan
        noseLine.firstMaterial?.emission.contents = UIColor.cyan
        let noseNode = SCNNode(geometry: noseLine)
        noseNode.position = SCNVector3(0, 0.0, 0.065)
        
        [overlayNode, leftEyeNode, rightEyeNode, noseNode].forEach { addChildNode($0) }
    }
    
    // MARK: - Blend Shape Updates
    func updateWithBlendShapes(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        guard filterType != .none else { return }
        
        if let mouthOpen = blendShapes[.jawOpen]?.floatValue, filterType == .mask {
            let scale = 1.0 + (mouthOpen * 0.1)
            self.scale = SCNVector3(scale, scale, scale)
        }
    }
}
