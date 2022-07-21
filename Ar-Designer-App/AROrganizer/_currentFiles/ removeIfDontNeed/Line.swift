//
//  Line.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import SceneKit
import ARKit

final class Line {
    private enum Constants {
        static let scale = SCNVector3(1 / 500.0, 1 / 500.0, 1 / 500.0)
        static let eulerAngles = SCNVector3Make(0, .pi, 0)
    }
    
    private var color: UIColor = .yellow
    private let sceneView: ARSCNView
    private let startVector: SCNVector3
    private let unit: Distance
    
    private var startNode: SCNNode
    private var endNode: SCNNode
    
    private var text: SCNText
    private var textNode: SCNNode
    private var lineNode: SCNNode?
    
    // MARK: - Lifecycle
    init(sceneView: ARSCNView, startVector: SCNVector3, unit: Distance) {
        self.sceneView = sceneView
        self.startVector = startVector
        self.unit = unit
        
        let dot = SCNSphere(radius: 0.5)
        dot.firstMaterial?.diffuse.contents = color
        dot.firstMaterial?.lightingModel = .constant
        dot.firstMaterial?.isDoubleSided = true
        startNode = SCNNode(geometry: dot)
        startNode.scale = Constants.scale
        startNode.position = startVector
        sceneView.scene.rootNode.addChildNode(startNode)
        
        endNode = SCNNode(geometry: dot)
        endNode.scale = Constants.scale
        
        text = SCNText(string: "", extrusionDepth: 0.1)
        text.font = .systemFont(ofSize: 5)
        text.firstMaterial?.diffuse.contents = color
        text.firstMaterial?.isDoubleSided = true
        
        let textWrapperNode = SCNNode(geometry: text)
        textWrapperNode.eulerAngles = SCNVector3Make(0, .pi, 0)
        textWrapperNode.scale = Constants.scale
        
        textNode = SCNNode()
        textNode.addChildNode(textWrapperNode)
        ///
        let constraint = SCNLookAtConstraint(target: sceneView.pointOfView)
        constraint.isGimbalLockEnabled = true
        textNode.constraints = [constraint]
        
        sceneView.scene.rootNode.addChildNode(textNode)
    }
    
    func update(to vector: SCNVector3) {
        lineNode?.removeFromParentNode()
        lineNode = startVector.line(to: vector, color: color)
        sceneView.scene.rootNode.addChildNode(lineNode!)
        
        text.string = distance(to: vector)
        textNode.position = SCNVector3((startVector.x + vector.x) / 2.0,
                                        (startVector.y + vector.y) / 2.0,
                                        (startVector.z + vector.z) / 2.0)
        
        endNode.position = vector
       
        if endNode.parent == nil {
            sceneView.scene.rootNode.addChildNode(endNode)
        }
    }
    
    func distance(to vector: SCNVector3) -> String {
        return String(format: "%.2f %@", startVector.distanceValue(from: vector) * unit.fator, unit.unit)
    }
    
    func removeFromParentNode() {
        startNode.removeFromParentNode()
        endNode.removeFromParentNode()
        
        lineNode?.removeFromParentNode()
        textNode.removeFromParentNode()
    }
}
