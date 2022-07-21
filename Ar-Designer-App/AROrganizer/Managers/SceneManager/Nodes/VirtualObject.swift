//
//  VirtualObject.swift
//  ARDesignerApp
//
//  Created by Goran Pavlovic on 4/4/22.
//

import SceneKit

final class VirtualObject: SCNNode {
    
    // MARK: - Public
    enum Constants {
        static let scaleFactor = 0.01
        static let placeholderPulse = "placeholder_pulse"
        static let highlightPulse = "highlight_pulse"
        static let colliderName = "Virtual Object - Collider Node"
    }

    var id: UUID
    var sku: Int?
    var colliderName: String
    var contactSides: Set<CalibrationBox.Side> = []
    var referenceNode: SCNReferenceNode
    var placeholder: SCNNode
    var isMoving = false
    var borders: SCNNode?
    var isRotated = false
    var referenceURL: URL?
    
    /// Can be provided by product if we in edit mode
    var initialPosition: SCNVector3?
    
    var bounds: Measurements {
        let min = referenceNode.boundingBox.min
        let max = referenceNode.boundingBox.max

        let width = Float(max.x - min.x)
        let height = Float(max.y - min.y)
        let length = Float(max.z - min.z)
        if isRotated {
            return .init(width: length, length: width, height: height)
        }
        return .init(width: width, length: length, height: height)
    }
  
    // MARK: - Private
    private(set) var collider: SCNNode?
    private(set) var highlightNode: SCNNode?

    init?(url referenceURL: URL) {
        self.referenceURL = referenceURL
        
        guard let node = SCNReferenceNode(url: referenceURL) else { return nil }
        referenceNode = node

        let cylinder = SCNCylinder(radius: 10, height: 0.3)
        cylinder.materials.forEach {
            $0.diffuse.contents = UIColor.placeholder
            $0.lightingModel = .constant
        }
        placeholder = SCNNode(geometry: cylinder)
        placeholder.isHidden = true
        self.id = UUID()
        
        colliderName = Constants.colliderName + id.uuidString

        super.init()
        addChildNode(referenceNode)
        addChildNode(placeholder)
        
        assignRotation(url: referenceURL)

        // We need to add geometry to SCNReferenceNode
        // in order for ray casting to pick it up when
        // the user wants to move it
        addReferenceGeometry()
        categoryBitMask = RenderingCategory.model.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func load() {
        referenceNode.load()
    }

    func unload() {
        referenceNode.unload()
    }

    func showPlaceholder() {
        guard !isMoving else { return }
        isMoving = true
        placeholder.isHidden = false
        adjustHeightPosition(isPlacehoderHidden: false)
        updateHighlightPosition()
        placeholder.runAction(
            .pulse(from: 0.4, to: 1.0, duration: 1.0),
            forKey: Constants.placeholderPulse
        )
    }

    func hidePlaceholder() {
        isMoving = false
        placeholder.removeAction(forKey: Constants.placeholderPulse)
        placeholder.isHidden = true
        adjustHeightPosition(isPlacehoderHidden: true)
        referenceNode.position = position
        updateHighlightPosition()
    }
    
    func rotate() {
        let degrees = CGFloat(GLKMathDegreesToRadians(90))
        let rotate = SCNAction.rotate(by: degrees, around: SCNVector3(0, 1, 0), duration: 0.2)
        isRotated.toggle()
        runAction(rotate)
    }
}

// MARK: - Rotation Helpers
// TODO: Remove once models will be updated
private extension VirtualObject {
    func shouldRotateByZ(url: URL) -> Bool {
        return shouldRotate(
            for: ["10079034", "10059916", "10059915", "10071135"],
            url: url
        )
    }
    
    func shouldRotateByZX(url: URL) -> Bool {
        return shouldRotate(
            for: ["10079579", "10079580", "10079583"],
            url: url
        )
    }
    
    func shouldRotate(for skus: [String], url: URL) -> Bool {
        return skus
            .map { url.absoluteString.contains($0) }
            .contains(true)
    }
    
    func assignRotation(url: URL) {
        if shouldRotateByZ(url: url) {
            referenceNode.eulerAngles.z = -Float.pi / 2
        }
        
        if shouldRotateByZX(url: url) {
            referenceNode.eulerAngles.x = -Float.pi / 2
        }
    }
    
    func referenceNodeYOffset(url: URL) -> Float {
        let boundingBox = referenceNode.boundingBox
        if shouldRotateByZ(url: url) {
            return boundingBox.max.x - boundingBox.min.x
        }

        if shouldRotateByZX(url: url) {
            return boundingBox.max.z - boundingBox.min.z
        }
        
        return boundingBox.max.y - boundingBox.min.y
    }
    
}

// MARK: - Helpers
extension VirtualObject {
    private func addReferenceGeometry() {
        let color = UIColor(
            red: 1,
            green: 1,
            blue: 1,
            alpha: 0
        )

        geometry = SCNCapsule(capRadius: 20, height: 25)
        geometry?.materials.forEach { $0.diffuse.contents = color }
    }

    private func adjustHeightPosition(isPlacehoderHidden: Bool) {
        let yOffset: Float = 3
        let vector = isPlacehoderHidden ? SCNVector3(x: 0, y: -yOffset, z: 0) : SCNVector3(x: 0, y: yOffset, z: 0)
        referenceNode.localTranslate(by: vector)
    }
}

// MARK: - Highlight
extension VirtualObject {
    
    func checkForHighlight() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.contactSides == [.bottom]
            ? self.hideHighlight()
            : self.showHighlight()
        }
    }
    
    func showHighlight() {
        if highlightNode == nil {
            highlightNode = createHighlight()
        }

        highlightNode?.geometry?.materials.forEach {
            $0.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
        }

        highlightNode?.runAction(
            .pulse(from: 0.0, to: 1.0, duration: 1.0),
            forKey: Constants.highlightPulse
        )
    }
    
    func hideHighlight() {
        if highlightNode == nil {
            highlightNode = createHighlight()
        }

        highlightNode?.geometry?.materials.forEach {
            $0.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0)
        }

        highlightNode?.removeAction(forKey: Constants.highlightPulse)
    }
}

private extension VirtualObject {
    func updateHighlightPosition() {
        if highlightNode == nil {
            highlightNode = createHighlight()
        }

        let position = SCNVector3(
            x: referenceNode.position.x,
            y: referenceNode.position.y + referenceNodeYOffset(url: referenceNode.referenceURL) / 2,
            z: referenceNode.position.z
        )

        highlightNode?.position = position
        collider?.position = position
    }

    func createHighlight() -> SCNNode {
        if collider == nil {
            collider = createCollider()
        }

        let min = referenceNode.boundingBox.min
        let max = referenceNode.boundingBox.max

        let width = CGFloat(max.x - min.x)
        let height = CGFloat(max.y - min.y)
        let length = CGFloat(max.z - min.z)

        let geometry = SCNBox(
            width: width + 0.05,
            height: height + 0.05,
            length: length + 0.05,
            chamferRadius: 0
        )

        let refNode = SCNNode(geometry: geometry)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0)
        material.lightingModel = .constant

        refNode.geometry?.materials = [material]
        refNode.eulerAngles = referenceNode.eulerAngles
        
        let referencePosition = referenceNode.position
        refNode.position = SCNVector3(
            x: referencePosition.x,
            y: referencePosition.y,
            z: referencePosition.z
        )

        refNode.castsShadow = false
        addChildNode(refNode)

        return refNode
    }

    func createCollider() -> SCNNode {
        let min = referenceNode.boundingBox.min
        let max = referenceNode.boundingBox.max

        let width = CGFloat(max.x - min.x)
        let height = CGFloat(max.y - min.y)
        let length = CGFloat(max.z - min.z)

        let geometry = SCNBox(
            width: width,
            height: height,
            length: length,
            chamferRadius: 0
        )

        let refNode = SCNNode(geometry: geometry)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 1, green: 0, blue: 0, alpha: 0)

        refNode.geometry?.materials = [material]
        refNode.eulerAngles = referenceNode.eulerAngles

        let referencePosition = referenceNode.position
        refNode.position = SCNVector3(
            x: referencePosition.x,
            y: referencePosition.y + Float(height),
            z: referencePosition.z
        )

        addChildNode(refNode)

        refNode.name = colliderName
        refNode.physicsBody = SCNPhysicsBody(type: .kinematic, shape: nil)
        refNode.physicsBody?.isAffectedByGravity = false
        refNode.physicsBody?.categoryBitMask = CollisionCategory.modelCategory.rawValue
        refNode.physicsBody?.contactTestBitMask = CollisionCategory.boxCategory.rawValue | CollisionCategory.modelCategory.rawValue

        return refNode
    }
}

extension SCNAction {
    static func pulse(
        from fromValue: CGFloat,
        to toValue: CGFloat,
        duration: CGFloat
    ) -> SCNAction {
        let pulseOutAction = SCNAction.fadeOpacity(to: fromValue, duration: duration)
        let pulseInAction = SCNAction.fadeOpacity(to: toValue, duration: duration)
        pulseOutAction.timingMode = .easeInEaseOut
        pulseInAction.timingMode = .easeInEaseOut

        return .repeatForever(.sequence([pulseOutAction, pulseInAction]))
    }
}

// MARK: - SCNPhysicsContactDelegate
extension VirtualObject: SCNPhysicsContactDelegate {
    
    func resetContactSides() {
        contactSides.removeAll()
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let side = contact.contactSide, contact.penetrationDistance > 0.01 {
            contactSides.insert(side)
        }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        if let side = contact.contactSide, contact.penetrationDistance > 0.01 {
            contactSides.insert(side)
        }
    }

    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        if let side = contact.contactSide {
            contactSides.remove(side)
        }
    }
}

extension SCNPhysicsContact {
    var contactSide: CalibrationBox.Side? {
        [nodeA.name, nodeB.name]
            .compactMap { $0 }
            .compactMap { CalibrationBox.Side(rawValue: $0) }
            .first
    }
}

// MARK: - Packing
extension VirtualObject {
    var toPackableItem: PackableItem {
        let result = PackableItem(
            id: id,
            isRotated: isRotated,
            width: Float(MeasurementsUtils.shared.toMeters(from: bounds.width, forceCentimeters: true)),
            height: Float(MeasurementsUtils.shared.toMeters(from: bounds.length, forceCentimeters: true)),
            x: 0,
            y: 0)
        
        return result
    }
}

extension PackableItem {
    init(object: VirtualObject) {
        self.id = object.id
        self.isRotated = object.isRotated
        self.width = Float(MeasurementsUtils.shared.toMeters(from: object.bounds.width, forceCentimeters: true))
        self.height = Float(MeasurementsUtils.shared.toMeters(from: object.bounds.length, forceCentimeters: true))
    }
}

extension VirtualObject {
    func align(for item: PackableItem, direction: DrawDirection) {
        if item.isRotated {
            eulerAngles = SCNVector3Make(0, Float.pi / 2, 0)
            isRotated = item.isRotated
        }
        position.z = direction.z.sign == .plus
        ? item.y + item.height / 2
        : -(item.y + item.height / 2)
        
        position.x = direction.x.sign == .plus
        ? item.x + item.width / 2
        : -(item.x + item.width / 2)

        position.y = 0
    }
}
