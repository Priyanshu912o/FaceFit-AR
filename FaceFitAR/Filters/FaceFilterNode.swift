import SceneKit
import ARKit

class FaceFilterNode: SCNNode {
    
    let filterType: FilterType
    
    // Named child nodes for expression reactions
    private var leftHornNode: SCNNode?
    private var rightHornNode: SCNNode?
    private var leftFireEmitter: SCNNode?
    private var rightFireEmitter: SCNNode?
    private var leftLensNode: SCNNode?
    private var rightLensNode: SCNNode?
    private var glintNode: SCNNode?
    private var crownJewelNodes: [SCNNode] = []
    private var crownPointNodes: [SCNNode] = []
    private var maskOverlayNode: SCNNode?
    private var leftEyeRingNode: SCNNode?
    private var rightEyeRingNode: SCNNode?
    
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
    
    // MARK: - Sunglasses (Wink → Lens Glint)
    private func setupSunglasses() {
        let leftLens = SCNPlane(width: 0.03, height: 0.025)
        leftLens.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.85)
        leftLens.cornerRadius = 0.005
        let leftNode = SCNNode(geometry: leftLens)
        leftNode.position = SCNVector3(-0.032, 0.025, 0.06)
        leftLensNode = leftNode
        
        let rightLens = SCNPlane(width: 0.03, height: 0.025)
        rightLens.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.85)
        rightLens.cornerRadius = 0.005
        let rightNode = SCNNode(geometry: rightLens)
        rightNode.position = SCNVector3(0.032, 0.025, 0.06)
        rightLensNode = rightNode
        
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
        
        // Lens glint effect (hidden by default, shown on wink)
        let glint = SCNPlane(width: 0.008, height: 0.018)
        glint.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.9)
        glint.firstMaterial?.emission.contents = UIColor.white
        glint.cornerRadius = 0.003
        let glintN = SCNNode(geometry: glint)
        glintN.position = SCNVector3(-0.026, 0.028, 0.062)
        glintN.eulerAngles = SCNVector3(0, 0, Float.pi * 0.15)
        glintN.opacity = 0
        glintNode = glintN
        
        [leftNode, rightNode, bridgeNode, leftFrameNode, rightFrameNode, glintN].forEach { addChildNode($0) }
    }
    
    // MARK: - Devil Horns (Mouth Open → Fire Particles)
    private func setupDevil() {
        let leftHorn = SCNCone(topRadius: 0, bottomRadius: 0.012, height: 0.06)
        leftHorn.firstMaterial?.diffuse.contents = UIColor.red
        leftHorn.firstMaterial?.specular.contents = UIColor.orange
        let leftNode = SCNNode(geometry: leftHorn)
        leftNode.position = SCNVector3(-0.05, 0.13, 0.0)
        leftNode.eulerAngles = SCNVector3(0, 0, Float.pi * 0.15)
        leftHornNode = leftNode
        
        let rightHorn = SCNCone(topRadius: 0, bottomRadius: 0.012, height: 0.06)
        rightHorn.firstMaterial?.diffuse.contents = UIColor.red
        rightHorn.firstMaterial?.specular.contents = UIColor.orange
        let rightNode = SCNNode(geometry: rightHorn)
        rightNode.position = SCNVector3(0.05, 0.13, 0.0)
        rightNode.eulerAngles = SCNVector3(0, 0, -Float.pi * 0.15)
        rightHornNode = rightNode
        
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
        
        // Fire particle emitters on horn tips
        let leftFire = createFireEmitter()
        leftFire.position = SCNVector3(-0.05, 0.165, 0.0)
        leftFireEmitter = leftFire
        
        let rightFire = createFireEmitter()
        rightFire.position = SCNVector3(0.05, 0.165, 0.0)
        rightFireEmitter = rightFire
        
        // Start with particles hidden
        leftFire.particleSystems?.forEach { $0.birthRate = 0 }
        rightFire.particleSystems?.forEach { $0.birthRate = 0 }
        
        [leftNode, rightNode, leftBrowNode, rightBrowNode, leftFire, rightFire].forEach { addChildNode($0) }
    }
    
    // MARK: - Crown (Smile → Jewels Glow)
    private func setupCrown() {
        let gold = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0)
        
        let base = SCNTorus(ringRadius: 0.08, pipeRadius: 0.005)
        base.firstMaterial?.diffuse.contents = gold
        base.firstMaterial?.specular.contents = UIColor.white
        let baseNode = SCNNode(geometry: base)
        baseNode.position = SCNVector3(0, 0.18, -0.04)
        // Tilt forward ~20° so the ring wraps around the skull curve
        baseNode.eulerAngles = SCNVector3( 0.26, 0, 0)
        addChildNode(baseNode)
        
        for i in 0..<5 {
            let angle = Float(i) * (2 * Float.pi / 5)
            let zPos = cos(angle) * 0.08 - 0.04
            // Front horns drop, back horns rise well above the ring
            let yAdjust: Float = zPos > 0 ? -(zPos * 0.3) : -(zPos * 0.25)
            let point = SCNPyramid(width: 0.015, height: 0.03, length: 0.015)
            point.firstMaterial?.diffuse.contents = gold
            point.firstMaterial?.specular.contents = UIColor.white
            let pointNode = SCNNode(geometry: point)
            pointNode.position = SCNVector3(
                sin(angle) * 0.08,
                0.18 + yAdjust,
                zPos
            )
            crownPointNodes.append(pointNode)
            addChildNode(pointNode)
        }
        
        // Jewels sit on pyramid tips — pulled inward to center on point
        for i in stride(from: 0, to: 5, by: 2) {
            let angle = Float(i) * (2 * Float.pi / 5)
            let zPosPyramid = cos(angle) * 0.08 - 0.04
            let yAdjust: Float = zPosPyramid > 0 ? -(zPosPyramid * 0.3) : -(zPosPyramid * 0.25)
            let jewel = SCNSphere(radius: 0.003)
            jewel.firstMaterial?.diffuse.contents = UIColor.red
            jewel.firstMaterial?.specular.contents = UIColor.white
            jewel.firstMaterial?.emission.contents = UIColor.red.withAlphaComponent(0.5)
            let jewelNode = SCNNode(geometry: jewel)
            jewelNode.position = SCNVector3(
                sin(angle) * 0.08,
                0.18 + yAdjust + 0.031,  // just above the tip
                zPosPyramid
            )
            crownJewelNodes.append(jewelNode)
            addChildNode(jewelNode)
        }
        
        // Add sparkle particles (subtle, always-on)
        let sparkle = createSparkleEmitter()
        sparkle.position = SCNVector3(0, 0.20, -0.04)
        addChildNode(sparkle)
    }
    
    // MARK: - Neon Mask (Cheek Puff → Energy Pulse)
    private func setupMask() {
        let faceOverlay = SCNPlane(width: 0.14, height: 0.17)
        faceOverlay.firstMaterial?.diffuse.contents = UIColor(red: 0.48, green: 0.23, blue: 0.93, alpha: 0.35)
        faceOverlay.firstMaterial?.isDoubleSided = true
        faceOverlay.cornerRadius = 0.04
        let overlayNode = SCNNode(geometry: faceOverlay)
        overlayNode.position = SCNVector3(0, 0.01, 0.055)
        maskOverlayNode = overlayNode
        
        let leftEye = SCNTorus(ringRadius: 0.016, pipeRadius: 0.003)
        leftEye.firstMaterial?.diffuse.contents = UIColor.cyan
        leftEye.firstMaterial?.emission.contents = UIColor.cyan
        let leftEyeNode = SCNNode(geometry: leftEye)
        leftEyeNode.position = SCNVector3(-0.032, 0.025, 0.065)
        leftEyeNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        leftEyeRingNode = leftEyeNode
        
        let rightEye = SCNTorus(ringRadius: 0.016, pipeRadius: 0.003)
        rightEye.firstMaterial?.diffuse.contents = UIColor.cyan
        rightEye.firstMaterial?.emission.contents = UIColor.cyan
        let rightEyeNode = SCNNode(geometry: rightEye)
        rightEyeNode.position = SCNVector3(0.032, 0.025, 0.065)
        rightEyeNode.eulerAngles = SCNVector3(Float.pi / 2, 0, 0)
        rightEyeRingNode = rightEyeNode
        
        let noseLine = SCNCylinder(radius: 0.002, height: 0.025)
        noseLine.firstMaterial?.diffuse.contents = UIColor.cyan
        noseLine.firstMaterial?.emission.contents = UIColor.cyan
        let noseNode = SCNNode(geometry: noseLine)
        noseNode.position = SCNVector3(0, 0.0, 0.065)
        
        [overlayNode, leftEyeNode, rightEyeNode, noseNode].forEach { addChildNode($0) }
    }
    
    // MARK: - Particle System Factories
    
    /// Creates fire particle effect for devil horns
    private func createFireEmitter() -> SCNNode {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleLifeSpan = 0.4
        particleSystem.particleLifeSpanVariation = 0.2
        particleSystem.birthRate = 40
        particleSystem.emissionDuration = CGFloat.greatestFiniteMagnitude
        particleSystem.particleSize = 0.005
        particleSystem.particleSizeVariation = 0.003
        particleSystem.spreadingAngle = 15
        particleSystem.particleVelocity = 0.02
        particleSystem.particleVelocityVariation = 0.01
        particleSystem.emittingDirection = SCNVector3(0, 1, 0) // fire goes up
        particleSystem.particleColor = UIColor.orange
        particleSystem.particleColorVariation = SCNVector4(0.1, 0.3, 0, 0) // red-orange variation
        particleSystem.blendMode = .additive
        particleSystem.isAffectedByGravity = false
        
        // Fade out over lifetime
        let colorAnimation = CAKeyframeAnimation()
        colorAnimation.values = [
            UIColor.yellow,
            UIColor.orange,
            UIColor.red,
            UIColor.red.withAlphaComponent(0)
        ]
        colorAnimation.keyTimes = [0, 0.3, 0.7, 1.0]
        particleSystem.propertyControllers = [
            .color: SCNParticlePropertyController(animation: colorAnimation)
        ]
        
        let node = SCNNode()
        node.addParticleSystem(particleSystem)
        return node
    }
    
    /// Creates subtle sparkle effect for crown
    private func createSparkleEmitter() -> SCNNode {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleLifeSpan = 0.8
        particleSystem.particleLifeSpanVariation = 0.3
        particleSystem.birthRate = 8
        particleSystem.emissionDuration = CGFloat.greatestFiniteMagnitude
        particleSystem.particleSize = 0.002
        particleSystem.particleSizeVariation = 0.001
        particleSystem.spreadingAngle = 180
        particleSystem.particleVelocity = 0.01
        particleSystem.emittingDirection = SCNVector3(0, 1, 0)
        particleSystem.particleColor = UIColor.yellow
        particleSystem.blendMode = .additive
        particleSystem.isAffectedByGravity = false
        
        // Fade in and out
        let opacityAnimation = CAKeyframeAnimation()
        opacityAnimation.values = [0.0, 1.0, 0.0] as [NSNumber]
        opacityAnimation.keyTimes = [0, 0.5, 1.0]
        particleSystem.propertyControllers = [
            .opacity: SCNParticlePropertyController(animation: opacityAnimation)
        ]
        
        let node = SCNNode()
        node.addParticleSystem(particleSystem)
        return node
    }
    
    // MARK: - Expression-Reactive Blend Shape Updates
    func updateWithBlendShapes(_ blendShapes: [ARFaceAnchor.BlendShapeLocation: NSNumber]) {
        guard filterType != .none else { return }
        
        let jawOpen = blendShapes[.jawOpen]?.floatValue ?? 0
        let smileLeft = blendShapes[.mouthSmileLeft]?.floatValue ?? 0
        let smileRight = blendShapes[.mouthSmileRight]?.floatValue ?? 0
        let blinkLeft = blendShapes[.eyeBlinkLeft]?.floatValue ?? 0
        let blinkRight = blendShapes[.eyeBlinkRight]?.floatValue ?? 0
        let cheekPuff = blendShapes[.cheekPuff]?.floatValue ?? 0
        let browUp = blendShapes[.browOuterUpLeft]?.floatValue ?? 0
        
        let smileAmount = (smileLeft + smileRight) / 2.0
        
        switch filterType {
        case .sunglasses:
            updateSunglassesExpressions(blinkLeft: blinkLeft, blinkRight: blinkRight, smile: smileAmount)
            
        case .devil:
            updateDevilExpressions(jawOpen: jawOpen, browUp: browUp)
            
        case .crown:
            updateCrownExpressions(smile: smileAmount)
            
        case .mask:
            updateMaskExpressions(jawOpen: jawOpen, cheekPuff: cheekPuff)
            
        case .none:
            break
        }
    }
    
    // MARK: - Sunglasses: Wink → Lens Glint Flash
    private func updateSunglassesExpressions(blinkLeft: Float, blinkRight: Float, smile: Float) {
        // Detect wink (one eye closed, other open)
        let isWinking = (blinkLeft > 0.6 && blinkRight < 0.3) || (blinkRight > 0.6 && blinkLeft < 0.3)
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.15
        
        if isWinking {
            // Flash glint on the open eye's lens
            glintNode?.opacity = 0.9
            if blinkLeft > 0.6 {
                // Left eye closed → glint on right lens
                glintNode?.position = SCNVector3(0.038, 0.028, 0.062)
            } else {
                // Right eye closed → glint on left lens
                glintNode?.position = SCNVector3(-0.026, 0.028, 0.062)
            }
        } else {
            glintNode?.opacity = 0
        }
        
        // Subtle tint shift on smile — lenses get slightly purple
        let purpleAmount = CGFloat(smile * 0.4)
        let lensColor = UIColor(red: purpleAmount * 0.3, green: 0, blue: purpleAmount, alpha: 0.85)
        leftLensNode?.geometry?.firstMaterial?.diffuse.contents = 
            smile > 0.3 ? lensColor : UIColor.black.withAlphaComponent(0.85)
        rightLensNode?.geometry?.firstMaterial?.diffuse.contents = 
            smile > 0.3 ? lensColor : UIColor.black.withAlphaComponent(0.85)
        
        SCNTransaction.commit()
    }
    
    // MARK: - Devil: Mouth Open → Fire Erupts from Horns
    private func updateDevilExpressions(jawOpen: Float, browUp: Float) {
        // Horns grow slightly when brows are raised
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        
        let hornScale = 1.0 + browUp * 0.15
        leftHornNode?.scale = SCNVector3(hornScale, hornScale, hornScale)
        rightHornNode?.scale = SCNVector3(hornScale, hornScale, hornScale)
        
        SCNTransaction.commit()
    }
    
    // MARK: - Crown: Smile → Jewels Glow Bright
    private func updateCrownExpressions(smile: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.2
        
        // Jewels glow proportionally to smile
        let glowColor = UIColor(
            red: 1.0,
            green: CGFloat(smile * 0.3),
            blue: CGFloat(smile * 0.1),
            alpha: CGFloat(smile)
        )
        
        for jewelNode in crownJewelNodes {
            jewelNode.geometry?.firstMaterial?.emission.contents = 
                smile > 0.15 ? glowColor : UIColor.black
            
            // Jewels grow slightly when smiling
            let jewelScale = 1.0 + smile * 0.4
            jewelNode.scale = SCNVector3(jewelScale, jewelScale, jewelScale)
        }
        
        // Crown points get a golden glow on big smiles
        if smile > 0.4 {
            let goldGlow = UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: CGFloat(smile * 0.5))
            for pointNode in crownPointNodes {
                pointNode.geometry?.firstMaterial?.emission.contents = goldGlow
            }
        } else {
            for pointNode in crownPointNodes {
                pointNode.geometry?.firstMaterial?.emission.contents = UIColor.black
            }
        }
        
        SCNTransaction.commit()
    }
    
    // MARK: - Mask: Cheek Puff → Energy Pulse + Jaw Open → Scale
    private func updateMaskExpressions(jawOpen: Float, cheekPuff: Float) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        
        // Scale with jaw
        let jawScale = 1.0 + jawOpen * 0.1
        self.scale = SCNVector3(jawScale, jawScale, jawScale)
        
        // Neon intensity increases with cheek puff
        let neonIntensity = CGFloat(0.5 + cheekPuff * 1.5)
        let puffCyan = UIColor(
            red: 0,
            green: CGFloat(0.8 + cheekPuff * 0.2),
            blue: CGFloat(0.8 + cheekPuff * 0.2),
            alpha: 1.0
        )
        
        leftEyeRingNode?.geometry?.firstMaterial?.emission.contents = 
            UIColor.cyan.withAlphaComponent(neonIntensity)
        rightEyeRingNode?.geometry?.firstMaterial?.emission.contents = 
            UIColor.cyan.withAlphaComponent(neonIntensity)
        
        // Overlay shifts to brighter purple on cheek puff
        if cheekPuff > 0.2 {
            let energyAlpha = CGFloat(0.35 + cheekPuff * 0.25)
            maskOverlayNode?.geometry?.firstMaterial?.diffuse.contents =
                UIColor(red: 0.55, green: 0.2, blue: 1.0, alpha: energyAlpha)
            maskOverlayNode?.geometry?.firstMaterial?.emission.contents =
                UIColor(red: 0.48, green: 0.23, blue: 0.93, alpha: CGFloat(cheekPuff * 0.3))
        } else {
            maskOverlayNode?.geometry?.firstMaterial?.diffuse.contents =
                UIColor(red: 0.48, green: 0.23, blue: 0.93, alpha: 0.35)
            maskOverlayNode?.geometry?.firstMaterial?.emission.contents = UIColor.black
        }
        
        SCNTransaction.commit()
    }
}
