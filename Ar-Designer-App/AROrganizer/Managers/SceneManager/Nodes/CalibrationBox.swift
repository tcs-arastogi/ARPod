//
//  CalibrationBox.swift
//  ARDesignerApp
//
//  Created by Vitalii Yaremchuk on 2/6/22.
//

import Foundation
import SceneKit
import ARKit

class CalibrationBox: SCNNode {
    enum Edge {
        case min, max
    }
    
    enum Side: String, CaseIterable {
        case front, back
        case top, bottom
        case left, right
        
        var axis: SCNVector3.Axis {
            switch self {
            case .left, .right: return .x
            case .top, .bottom: return .y
            case .front, .back: return .z
            }
        }
        
        var edge: Edge {
            switch self {
            case .back, .bottom, .left: return .min
            case .front, .top, .right: return .max
            }
        }
    }
    
    enum HorizontalAlignment {
        case left, right, center
        
        var anchor: Float {
            switch self {
            case .left: return 0
            case .right: return 1
            case .center: return 0.5
            }
        }
    }
    
    enum VerticalAlignment {
        case top, bottom, center
        
        var anchor: Float {
            switch self {
            case .bottom: return 0
            case .top: return 1
            case .center: return 0.5
            }
        }
    }
    
    var drawDirection = DrawDirection()
    var measurements: Measurements = Measurements(width: 0, length: 0, height: 0)
    
    let labelMargin = Float(0.01)
    
    let lineWidth = CGFloat(0.005)
    
    let vertexRadius = CGFloat(0.005)
    
    let fontSize = Float(0.025)
    
    /// Don't show labels on axes that are less than this length
    let minLabelDistanceThreshold = Float(0.01)
    
    /// At heights below this, the box will be flattened until it becomes completely 2D
    let minHeightFlatteningThreshold = Float(0.05)
    
    // Bottom vertices
    lazy var vertexA: SCNNode = self.makeVertex()
    lazy var vertexB: SCNNode = self.makeVertex()
    lazy var vertexC: SCNNode = self.makeVertex()
    lazy var vertexD: SCNNode = self.makeVertex()
    
    // Top vertices
    lazy var vertexE: SCNNode = self.makeVertex()
    lazy var vertexF: SCNNode = self.makeVertex()
    lazy var vertexG: SCNNode = self.makeVertex()
    lazy var vertexH: SCNNode = self.makeVertex()
    
    // Bottom lines
    lazy var lineAB: SCNNode = self.makeLine()
    lazy var lineBC: SCNNode = self.makeLine()
    lazy var lineCD: SCNNode = self.makeLine()
    lazy var lineDA: SCNNode = self.makeLine()
    
    // Top lines
    lazy var lineEF: SCNNode = self.makeLine()
    lazy var lineFG: SCNNode = self.makeLine()
    lazy var lineGH: SCNNode = self.makeLine()
    lazy var lineHE: SCNNode = self.makeLine()
    
    // Vertical lines
    lazy var lineAE: SCNNode = self.makeLine()
    lazy var lineBF: SCNNode = self.makeLine()
    lazy var lineCG: SCNNode = self.makeLine()
    lazy var lineDH: SCNNode = self.makeLine()
    
    lazy var widthLabel: SCNNode = self.makeLabel()
    lazy var heightLabel: SCNNode = self.makeLabel()
    lazy var lengthLabel: SCNNode = self.makeLabel()
    
    var labels: [SCNNode] {
        [widthLabel, heightLabel, lengthLabel]
    }
    
    lazy var faceBottom: SCNNode = self.makeFace(for: .bottom)
    lazy var faceTop: SCNNode = self.makeFace(for: .top)
    lazy var faceLeft: SCNNode = self.makeFace(for: .left)
    lazy var faceRight: SCNNode = self.makeFace(for: .right)
    lazy var faceFront: SCNNode = self.makeFace(for: .front)
    lazy var faceBack: SCNNode = self.makeFace(for: .back)
    
    private var vertices: [SCNNode] {
        [vertexA, vertexB, vertexC, vertexD, vertexE, vertexF, vertexG, vertexH]
    }
    
    private var lines: [SCNNode] {
        [
            lineAB, lineBC, lineCD, lineDA,
            lineEF, lineFG, lineGH, lineHE,
            lineAE, lineBF, lineCG, lineDH
        ]
    }
    
    var faces: [Side: SCNNode] {
        return [
            .top: faceTop,
            .bottom: faceBottom,
            .left: faceLeft,
            .right: faceRight,
            .front: faceFront,
            .back: faceBack
        ]
    }
    
    // MARK: - Constructors
    
    override init() {
        super.init()
        resizeTo(min: .zero, max: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func makeNode(with geometry: SCNGeometry) -> SCNNode {
        for material in geometry.materials {
            material.lightingModel = .constant
            material.diffuse.contents = UIColor.white
            material.isDoubleSided = false
        }
        
        let node = SCNNode(geometry: geometry)
        self.addChildNode(node)
        return node
    }
    
    fileprivate func makeVertex() -> SCNNode {
        let ball = SCNSphere(radius: vertexRadius)
        return makeNode(with: ball)
    }
    
    fileprivate func makeLine() -> SCNNode {
        let box = SCNBox(width: lineWidth, height: lineWidth, length: lineWidth, chamferRadius: 0)
        //        for material in box.materials{
        //        material.diffuse.contents = UIImage(named: "line")!
        //        material.diffuse.wrapS = .repeat
        //        material.diffuse.wrapT = .repeat
        //        material.isDoubleSided = true // Not sure if this is really needed here^
        //
        //
        //
        //        }
        //        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width * repeatCountPerMeter, height * repeatCountPerMeter, 1)
        //        material.multiply.contents = UIColor.green
        
        return makeNode(with: box)
    }
    
    fileprivate func makeLabel() -> SCNNode {
        // NOTE: SCNText font sizes are measured in the same coordinate systems as everything else, so font size 1.0 means a font that's 1 metre high.
        // For some reason very small font sizes gave incorrect results (e.g. invisible/misplaced geometry), so we handle font sizing using scale instead.
        
        let text = SCNText(string: "", extrusionDepth: 0.0)
        
        text.font = UIFont.boldSystemFont(ofSize: 1.0)
        text.flatness = 0.01
        
        let node = makeNode(with: text)
        node.setUniformScale(fontSize)
        
        let billboardConstraint = SCNBillboardConstraint()
        node.constraints = [billboardConstraint]
        
        return node
    }
    
    fileprivate func makeFace(for side: Side) -> SCNNode {
        let plane = SCNPlane()
        let node = makeNode(with: plane)
        node.name = side.rawValue
        node.geometry?.firstMaterial?.transparency = 0
        node.geometry?.firstMaterial?.writesToDepthBuffer = false
        
        // Rotate each face to the appropriate facing
        switch side {
        case .top:
            node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX)
        case .bottom:
            node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisX)
        case .front:
            break
        case .back:
            node.orientation = SCNQuaternion(radians: Float.pi, around: .axisY)
        case .left:
            node.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisY)
        case .right:
            node.orientation = SCNQuaternion(radians: Float.pi / 2, around: .axisY)
        }
        
        return node
    }
    
    // MARK: - Transformation
    func move(side: Side, to extent: Float) {
        var (min, max) = boundingBox
        switch side.edge {
        case .min: min.setAxis(side.axis, to: extent)
        case .max: max.setAxis(side.axis, to: extent)
        }
        
        resizeTo(min: min, max: max)
    }
    
    func resizeTo(min minExtents: SCNVector3, max maxExtents: SCNVector3) {
        // Normalize the bounds so that min is always < max
        let absMin = SCNVector3(x: min(minExtents.x, maxExtents.x), y: min(minExtents.y, maxExtents.y), z: min(minExtents.z, maxExtents.z))
        let absMax = SCNVector3(x: max(minExtents.x, maxExtents.x), y: max(minExtents.y, maxExtents.y), z: max(minExtents.z, maxExtents.z))
        
        boundingBox = (absMin, absMax)
        update()
    }
    
    func updateLabels(camera: ARCamera?, distance: Float) {
        guard let camera = camera, case .normal = camera.trackingState else { return }
        let distance = simd_distance(simdTransform.columns.3, camera.transform.columns.3)
        let multiplier = distance / distance
        labels.forEach { $0.setUniformScale(multiplier * fontSize) }
    }
    
    func highlight(enable: Bool) {
        let color: UIColor = enable ? .systemBlue : .white
        
        (vertices + lines + faces.values).forEach { node in
            node.geometry?.materials.forEach {
                $0.lightingModel = .constant
                $0.diffuse.contents = color
            }
        }
    }
    
    func createPhysicsBodies() {
        faces.forEach { key, value in
            guard let plane = value.geometry as? SCNPlane else { return }
            
            let geometry: SCNGeometry
            if key == .bottom {
                geometry = SCNBox(width: plane.width, height: plane.height, length: 0.1, chamferRadius: 0)
            } else {
                geometry = SCNPlane(width: plane.width, height: plane.height)
            }
            
            value.physicsBody = SCNPhysicsBody(
                type: .kinematic,
                shape: .init(
                    geometry: geometry,
                    options: [
                        .collisionMargin: 0.0001
                    ]
                )
            )
            value.physicsBody?.categoryBitMask = CollisionCategory.boxCategory.rawValue
            value.physicsBody?.contactTestBitMask = CollisionCategory.modelCategory.rawValue
            value.physicsBody?.isAffectedByGravity = false
        }
    }
    
    fileprivate func update() {
        let (minBounds, maxBounds) = boundingBox
        
        let size = maxBounds - minBounds
        
        assert(size.x >= 0 && size.y >= 0 && size.z >= 0)
        
        let a = SCNVector3(x: minBounds.x, y: minBounds.y, z: minBounds.z)
        let b = SCNVector3(x: maxBounds.x, y: minBounds.y, z: minBounds.z)
        let c = SCNVector3(x: maxBounds.x, y: minBounds.y, z: maxBounds.z)
        let d = SCNVector3(x: minBounds.x, y: minBounds.y, z: maxBounds.z)
        
        let e = SCNVector3(x: minBounds.x, y: maxBounds.y, z: minBounds.z)
        let f = SCNVector3(x: maxBounds.x, y: maxBounds.y, z: minBounds.z)
        let g = SCNVector3(x: maxBounds.x, y: maxBounds.y, z: maxBounds.z)
        let h = SCNVector3(x: minBounds.x, y: maxBounds.y, z: maxBounds.z)
        
        vertexA.position = a
        vertexB.position = b
        vertexC.position = c
        vertexD.position = d
        
        vertexE.position = e
        vertexF.position = f
        vertexG.position = g
        vertexH.position = h
        
        updateLine(lineAB, from: a, distance: size.x, axis: .x)
        updateLine(lineBC, from: b, distance: size.z, axis: .z)
        updateLine(lineCD, from: c, distance: -size.x, axis: .x)
        updateLine(lineDA, from: d, distance: -size.z, axis: .z)
        
        updateLine(lineEF, from: e, distance: size.x, axis: .x)
        updateLine(lineFG, from: f, distance: size.z, axis: .z)
        updateLine(lineGH, from: g, distance: -size.x, axis: .x)
        updateLine(lineHE, from: h, distance: -size.z, axis: .z)
        
        updateLine(lineAE, from: a, distance: size.y, axis: .y)
        updateLine(lineBF, from: b, distance: size.y, axis: .y)
        updateLine(lineCG, from: c, distance: size.y, axis: .y)
        updateLine(lineDH, from: d, distance: size.y, axis: .y)
        
        updateFace(faceTop)
        updateFace(faceBottom)
        updateFace(faceLeft)
        updateFace(faceRight)
        updateFace(faceFront)
        updateFace(faceBack)
        
        // Align width label along the front bottom edge of box, flat against the ground
        updateLabel(widthLabel, distance: size.x, horizontalAlignment: .center, verticalAlignment: .top)
        widthLabel.position = pointInBounds(at: SCNVector3(x: 0.5, y: 0, z: 1))
        widthLabel.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX)
        
        // Align length label along right bottom edge of box, flat against the ground
        updateLabel(lengthLabel, distance: size.z, horizontalAlignment: .center, verticalAlignment: .top)
        lengthLabel.position = pointInBounds(at: SCNVector3(x: 1, y: 0, z: 0.5))
        lengthLabel.orientation = SCNQuaternion(radians: -Float.pi / 2, around: .axisX).concatenating(SCNQuaternion(radians: Float.pi / 2, around: .axisY))
        
        // Align height label to top left edge of box, parallel to the box's vertical axis
        updateLabel(heightLabel, distance: size.y, horizontalAlignment: .right, verticalAlignment: .top)
        heightLabel.position = pointInBounds(at: SCNVector3(x: 0, y: 0.5, z: 1))
        
        widthLabel.isHidden = size.x < minLabelDistanceThreshold
        heightLabel.isHidden = size.y < minLabelDistanceThreshold
        lengthLabel.isHidden = size.z < minLabelDistanceThreshold
        
        // At very low heights, flatten the box until it becomes 2D.
        let horizontalNodes = [
            vertexA, vertexB, vertexC, vertexD,
            vertexE, vertexF, vertexG, vertexH,
            lineAB, lineBC, lineCD, lineDA,
            lineEF, lineFG, lineGH, lineHE
        ]
        
        let flatteningRatio = min(size.y, minHeightFlatteningThreshold) / minHeightFlatteningThreshold
        for node in horizontalNodes {
            node.scale = SCNVector3(x: 1, y: flatteningRatio, z: 1)
        }
    }
    
    fileprivate func updateLine(_ line: SCNNode, from position: SCNVector3, distance: Float, axis: SCNVector3.Axis) {
        guard let box = line.geometry as? SCNBox else {
            fatalError("Tried to update something that is not a line")
        }
        
        let absDistance = CGFloat(abs(distance))
        let offset = distance * 0.5
        switch axis {
        case .x:
            box.width = absDistance
            line.position = position + SCNVector3(x: offset, y: 0, z: 0)
        case .y:
            box.height = absDistance
            line.position = position + SCNVector3(x: 0, y: offset, z: 0)
        case .z:
            box.length = absDistance
            line.position = position + SCNVector3(x: 0, y: 0, z: offset)
        }
    }
    
    fileprivate func updateFace(_ face: SCNNode) {
        guard let plane = face.geometry as? SCNPlane, let name = face.name, let side = Side(rawValue: name) else {
            fatalError("Tried to update something that is not a face")
        }
        
        let (min, max) = boundingBox
        let size = max - min
        
        let anchor: SCNVector3
        let dimensions: (width: Float, height: Float)
        switch side {
        case .top:
            dimensions = (size.x, size.z)
            anchor = SCNVector3(x: 0.5, y: 1, z: 0.5)
        case .bottom:
            dimensions = (size.x, size.z)
            anchor = SCNVector3(x: 0.5, y: 0, z: 0.5)
        case .front:
            dimensions = (size.x, size.y)
            anchor = SCNVector3(x: 0.5, y: 0.5, z: 1)
        case .back:
            dimensions = (size.x, size.y)
            anchor = SCNVector3(x: 0.5, y: 0.5, z: 0)
        case .left:
            dimensions = (size.z, size.y)
            anchor = SCNVector3(x: 0, y: 0.5, z: 0.5)
        case .right:
            dimensions = (size.z, size.y)
            anchor = SCNVector3(x: 1, y: 0.5, z: 0.5)
        }
        
        plane.width = CGFloat(dimensions.width)
        plane.height = CGFloat(dimensions.height)
        face.position = pointInBounds(at: anchor)
    }
    
    fileprivate func updateLabel(_ label: SCNNode,
                                 distance distanceInMetres: Float,
                                 horizontalAlignment: HorizontalAlignment,
                                 verticalAlignment: VerticalAlignment) {
        guard let text = label.geometry as? SCNText else {
            fatalError("Tried to update something that is not a label")
        }
        
        text.string = MeasurementsUtils.shared.toString(from: distanceInMetres)
        let textAnchor = text.pointInBounds(at: SCNVector3(x: horizontalAlignment.anchor, y: verticalAlignment.anchor, z: 0))
        label.pivot = SCNMatrix4(translation: textAnchor)
    }
}

extension CalibrationBox {
    var boxSize: Measurements { // meters
        
        let result = (boundingBox.max - boundingBox.min)
        return Measurements(width: result.z, length: result.x, height: result.y)
    }
    
    var boxSizeInc: Measurements {
        let box = boxSize
        let width = Measurement(value: Double(box.width), unit: UnitLength.meters).converted(to: UnitLength.inches).value
        let length = Measurement(value: Double(box.length), unit: UnitLength.meters).converted(to: UnitLength.inches).value
        let height = Measurement(value: Double(box.height), unit: UnitLength.meters).converted(to: UnitLength.inches).value
        return Measurements(width: Float(width), length: Float(length), height: Float(height))
    }
    
    func contains(node: SCNNode) -> Bool {
        let distance = boundingSphere.center.distance(to: node.position)
        return distance <= boundingSphere.radius
    }
}

// MARK: - Camera
extension CalibrationBox {
    func setDefaultCameraPosition(camera: ARCamera?, cameraMatrix: SCNMatrix4, distance: Float) { // !!!! need change logic
        transform = SCNMatrix4Mult(transform, cameraMatrix)
        position = SCNVector3Make(-0.2, -0.5, -measurements.height * 0.08)

        let rotate = SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(25)),
                                      around: SCNVector3(0, 1, 0),
                                      duration: 0.0)
        runAction(rotate)
    }
}

// MARK: - Did Change Measurements
extension CalibrationBox {
    func didUpdateBox(by measurements: Measurements) {
        self.measurements = measurements
        let unit = UnitLength.inches
        let width = Measurement(value: Double(measurements.width), unit: unit).converted(to: .meters).value
        let length = Measurement(value: Double(measurements.length), unit: unit).converted(to: .meters).value
        let height = Measurement(value: Double(measurements.height), unit: unit).converted(to: .meters).value
        
        move(side: .right, to: Float(length))
        drawDirection.x = DrawOption(side: .right, sign: length.sign)
        
        if drawDirection.z.sign == .minus {
            move(side: .front, to: 0)
            move(side: .back, to: Float(-width))
        } else {
            move(side: .front, to: Float(width))
            move(side: .back, to: 0)
        }
        
        move(side: .top, to: Float(height))
        drawDirection.y = DrawOption(side: .top, sign: height.sign)
    }
    
    func didChangeWorldPosition(_ worldPosition: SCNVector3, type: MeasurementsType) {
        switch type {
        case .width:
            didChangeWidth(worldPosition: worldPosition)
            
        case .length:
            didChangeLength(worldPosition: worldPosition)
            
        case .height:
            didChangeHeight(worldPosition: worldPosition)
            
        default:
            return
        }
    }
    
    func didChangeWidth(worldPosition: SCNVector3) {
        // This drags a line out that determines the box's width and its orientation:
        // The box's front will face 90 degrees clockwise out from the line being dragged.
        let delta = position - worldPosition
        let distance = delta.length
        let angleInRadians = atan2(delta.z, delta.x)
        
        move(side: .right, to: distance)
        rotation = SCNVector4(x: 0, y: 1, z: 0, w: -(angleInRadians + Float.pi))
        drawDirection.x = DrawOption(side: .right, sign: distance.sign)
    }
    
    func didChangeLength(worldPosition: SCNVector3) {
        // Check where the hit vector landed within the box's own coordinate system, which may be rotated.
        let locationInBox = convertPosition(worldPosition, from: nil)
        
        // Front side faces toward +z, back side toward -z
        if locationInBox.z < 0 {
            move(side: .front, to: 0)
            move(side: .back, to: locationInBox.z)
            drawDirection.z = DrawOption(side: .back, sign: locationInBox.z.sign)
        } else {
            move(side: .front, to: locationInBox.z)
            move(side: .back, to: 0)
            drawDirection.z = DrawOption(side: .front, sign: locationInBox.z.sign)
        }
    }
    
    func didChangeHeight(worldPosition: SCNVector3) {
        
    }
}

struct DrawOption {
    let side: CalibrationBox.Side
    let sign: FloatingPointSign
    var coefficient: Float { sign == .plus ? 1.0 : -1.0 }
}

struct DrawDirection {
    // from calBox
    var x: DrawOption = DrawOption(side: .right, sign: .plus)
    var y: DrawOption = DrawOption(side: .top, sign: .plus)
    var z: DrawOption = DrawOption(side: .back, sign: .plus)
}
