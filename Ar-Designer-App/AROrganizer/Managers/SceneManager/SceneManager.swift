//
//  SceneManager.swift
//  AROrganizer-Develop
//
//  Created by Yurii Goroshenko on 6/9/22.
//

import ARKit
import SceneKit

protocol SceneManagerDelegate: AnyObject {
    func sceneManagerDidOpenProjectFinish()
    func sceneManagerDidChangedDrawState(_ state: SceneManager.DrawingState)
    func sceneManagerDidUpdateMeasurements(_ measurements: Measurements)
    func sceneManagerDidRotateFinish(_ model: VirtualObject)
    func sceneManagerDidDublicateFinish(_ model: VirtualObject)
    func sceneManagerDidUndoFinish(_ model: VirtualObject)
    func sceneManagerDidStartEdit(_ model: VirtualObject)
    func sceneManagerDidMove(_ model: VirtualObject)
    func sceneManagerDidFinishEdit(_ model: VirtualObject)
    func sceneManagerDidSorted(_ models: [VirtualObject], overlappedModels: [VirtualObject])
    func sceneManagerDidShowError(_ message: String)
    func sceneManagerDidTapOnScreen()
}

final class SceneManager: NSObject {
    private enum Constants {
        static let optimalCameraDistance: Float = 0.75  // Distance in meters
    }
    
    public enum Error: LocalizedError {
        case general
        case noSpace
        case itemsOverlap
        
        var errorDescription: String {
            switch self {
            case .general:
                return "General error"

            case .noSpace:
                return "There is no available space to insert"

            case .itemsOverlap:
                return "Items can't overlap. Please move the item"
            }
        }
    }
    
    enum DrawingState: Int {
        case none = 0
        case foundPlane
        case waitingForLocation
        case draggingInitialWidth
        case draggingInitialLength
        case draggingInitialHeight
        case done
    }
    
    // MARK: - Properties
    private let hitTestPlane: SCNNode = SCNNode()
    private let box: CalibrationBox = CalibrationBox()
    private var displayObjects: [VirtualObject] = []
    private var selectedObject: VirtualObject?
    private var currentAnchor: ARAnchor?
    private var coachingOverlay: ARCoachingOverlayView?
    private var isExistingProject: Bool = false
    private var startingCoordinates: CGPoint = CGPoint.zero
    var state: DrawingState = .none { didSet { refreshUI() } }
    weak var sceneView: ARSCNView!
    weak var delegate: SceneManagerDelegate?
    
    // MARK: - Lifecycle
    init(_ sceneView: ARSCNView, delegate: SceneManagerDelegate? = nil) {
        self.sceneView = sceneView
        self.delegate = delegate
        super.init()
        setup()
    }
}

// MARK: - Private functions
private extension SceneManager {
    func setup() {
        createLight()
        createHitPlane()
        state = .none
        
        sceneView.scene.physicsWorld.contactDelegate = self
        sceneView.scene.rootNode.addChildNode(box)
        
        createGestures()
    }
    
    func createLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional
        lightNode.light?.intensity = 600
        lightNode.position = SCNVector3(1, 1, -0.7)
        box.addChildNode(lightNode)
    }
    
    func createHitPlane() {
        hitTestPlane.geometry?.firstMaterial?.diffuse.contents = UIColor.green.withAlphaComponent(_: 0.3)
        box.addChildNode(hitTestPlane)
    }
    
    func createOverlay() {
        let view = ARCoachingOverlayView()
        view.delegate = self
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.goal = .horizontalPlane
        view.activatesAutomatically = true
        view.frame = sceneView.bounds
        view.session = sceneView.session
        sceneView.addSubview(view)
        
        self.coachingOverlay = view
    }
    
    func scenekitHit() -> SCNVector3 {
        let coordinate = CGPoint(x: sceneView.center.x, y: sceneView.center.y)
        let hits = sceneView.hitTest(coordinate, options: [
            .boundingBoxOnly: true,
            .firstFoundOnly: true,
            .rootNode: hitTestPlane,
            .ignoreChildNodes: true
        ])
        
        return hits.first?.worldCoordinates ?? SCNVector3.zero
    }
    
    func createGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionTapOnScreen(_:)))
        sceneView.addGestureRecognizer(tapGesture)
        
        let panGesture = ThresholdPanGesture(target: self, action: #selector(actionFingerPositionDidChanged(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
        
    func refreshUI() {
        switch state {
        case .none:
            box.isHidden = true
            hitTestPlane.isHidden = true
            box.resizeTo(min: .zero, max: .zero)
            actionUpdateMeasurements(Measurements(width: 0, length: 0, height: 0))
            
        case .foundPlane: break
            
        case .waitingForLocation:
            print("")
            
        case .draggingInitialWidth, .draggingInitialLength:
            box.isHidden = false
            // Place the hit-test plane flat on the z-axis, aligned with the bottom of the box.
            hitTestPlane.isHidden = false
            hitTestPlane.position = .zero
            hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: 0, z: -1000)
            hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 0, z: 1000)
            
        case .draggingInitialHeight:
            box.isHidden = false
            hitTestPlane.isHidden = true
            hitTestPlane.position = .zero
            hitTestPlane.boundingBox.min = SCNVector3(x: -1000, y: -1000, z: 0)
            hitTestPlane.boundingBox.max = SCNVector3(x: 1000, y: 1000, z: 0)
           
        case .done:
            box.createPhysicsBodies()
            guard coachingOverlay != nil else { return }
            coachingOverlay?.removeFromSuperview()
        }
    }
    
    func getWorldPosition(from coordinate: CGPoint) -> ARRaycastResult? {
        guard
            let query = sceneView.raycastQuery(from: coordinate, allowing: .existingPlaneGeometry, alignment: .horizontal),
            let result = sceneView.session.raycast(query).first
        else {
            return nil
        }
        
        return result
    }
    
    func calculateWorldPosition(from screenPosition: CGPoint) -> SCNVector3? {
        let location = screenPosition
        let hitResult = sceneView.hitTest(location)
        let result = hitResult.first
        return result?.worldCoordinates
    }
}

// MARK: - Product/Node
extension SceneManager {
    func addModelToScene(_ model: VirtualObject) {
        let scaleFactor = VirtualObject.Constants.scaleFactor
        model.scale = SCNVector3(scaleFactor, scaleFactor, scaleFactor)
        model.position = model.initialPosition ?? (box.vertexB.position + box.vertexD.position) / 2
        model.eulerAngles = box.lineAB.eulerAngles
        box.addChildNode(model)
        displayObjects.append(model)
    }
    
    func actionRotate() {
        guard let object = selectedObject else { return }
        object.rotate()
        delegate?.sceneManagerDidRotateFinish(object)
    }
    
    func actionDublicate(autosort: Bool) {
        guard
            !displayObjects.isEmpty,
            let object = selectedObject ?? displayObjects.last,
            let url = object.referenceURL,
            let newItem = VirtualObject(url: url)
        else { return }
        newItem.load()
        newItem.sku = object.sku
        stopEditing(model: object)
        
        actionAddModel(newItem, autosort: autosort) { [weak self] error in
            if let error = error {
                self?.delegate?.sceneManagerDidShowError(error.errorDescription)
                return
            }
            self?.delegate?.sceneManagerDidDublicateFinish(newItem)
        }
    }
    
    func actionUndo() {
        guard !displayObjects.isEmpty, let object = selectedObject ?? displayObjects.last else { return }
        stopEditing(model: object, shouldOverlapCheck: false)
        // remove model
        object.removeFromParentNode()
        displayObjects.removeAll(where: { $0.id == object.id })
        delegate?.sceneManagerDidUndoFinish(object)
    }
    
    func actionAddModel(_ model: VirtualObject, autosort: Bool, edit: Bool = true, completionHandler: @escaping (SceneManager.Error?) -> Void) {
        guard edit else {
            addModelToScene(model)
            completionHandler(nil)
            return
        }
        
        checkSorting(for: displayObjects + [model]) { result in
            let overlapped = result.overlappedItems
            
            if !overlapped.isEmpty {
                completionHandler(.noSpace)
                return
            } else {
                if checkOverlapping() {
                    completionHandler(.itemsOverlap)
                    return
                }
                addModelToScene(model)
            }
            if autosort {
                actionSortObjects()
            } else {
                startEditMode(model: model)
            }
            completionHandler(nil)
        }
    }
    
    func actionSortObjects() {
        guard !displayObjects.isEmpty else { return }
        
        selectedObject = nil
        displayObjects.forEach {
            $0.resetContactSides()
        }
        
        checkSorting(for: displayObjects) { (fitted, overlapped) in
            let fittedObjects = displayObjects.filter { fitted.map(\.id).contains($0.id) }
            let overlappedObjects = displayObjects.filter { overlapped.map(\.id).contains($0.id) }
            fitted.forEach { item in
               let object = displayObjects
                    .first(where: { $0.id == item.id })
                object?.align(for: item, direction: box.drawDirection)
                object?.hidePlaceholder()
            }
            resetHighlights()
            delegate?.sceneManagerDidSorted(fittedObjects, overlappedModels: overlappedObjects)
        }
    }
    
    func checkSorting(for objects: [VirtualObject], completion: (ItemPackerResult) -> Void) {
        let packer = BoxPacker(size: (box.boxSize.length, box.boxSize.width),
                               items: objects.map { $0.toPackableItem })
        
        packer.pack { result in
            switch result {
            case.failure(let error):
                print(error)
            case.success((let fitted, let overlapped)):
                completion((fitted, overlapped))
            }
        }
    }
    
    func startEditMode(model: VirtualObject) {
        model.hideHighlight()
        selectedObject = model
        displayObjects.forEach { $0 == model ? $0.showPlaceholder() : $0.hidePlaceholder() }
        delegate?.sceneManagerDidStartEdit(model)
    }
    
    func stopEditing(model: VirtualObject, shouldOverlapCheck: Bool = true) {
        if shouldOverlapCheck && checkOverlapping() {
            delegate?.sceneManagerDidShowError(Error.itemsOverlap.errorDescription)
            return
        }
        selectedObject = nil
        
        model.hidePlaceholder()
        resetHighlights()
        delegate?.sceneManagerDidFinishEdit(model)
    }
    
    func resetContactSides() {
        displayObjects.forEach { $0.resetContactSides() }
    }
    
    func checkForHighlight() {
        displayObjects.forEach { $0.checkForHighlight() }
    }
    
    func resetHighlights() {
        resetContactSides()
        sceneView.scene.physicsWorld.updateCollisionPairs()
        checkForHighlight()
    }
    
    func checkOverlapping() -> Bool {
        guard
            let object = selectedObject,
            let physicsBody = object.collider?.physicsBody
        else { return false }
        
        let contacts = sceneView.scene.physicsWorld.contactTest(with: physicsBody)
        
        let isOverlapping = contacts.contains {
            $0.nodeA.name?.contains(VirtualObject.Constants.colliderName) ?? false &&
            $0.nodeB.name?.contains(VirtualObject.Constants.colliderName) ?? false
        }
        
        guard isOverlapping else { return false }
        return true
    }
}

// MARK: - Scene
extension SceneManager {
    func setupScene() {
        isExistingProject = false
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        sceneView.session.run(configuration)
//        sceneView.debugOptions = [.showBoundingBoxes, .showPhysicsShapes]
        sceneView.delegate = self
        
        createOverlay()
    }
    
    func setupExistingScene(measurements: Measurements) {
        isExistingProject = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        
        sceneView.session.run(configuration)
//        sceneView.debugOptions = [.showBoundingBoxes, .showPhysicsShapes]
        sceneView.delegate = self
        
        box.measurements = measurements
        createOverlay()
    }
    
    func findARStartingLocation() {
        let coordinate = CGPoint(x: sceneView.center.x, y: sceneView.center.y)
        guard let result = getWorldPosition(from: coordinate) else { return }
        
        // Once the user hits a usable real-world plane, switch into line-dragging mode
        box.position = SCNVector3.positionFromTransform(result.worldTransform)
        currentAnchor = result.anchor
        state = .draggingInitialWidth
    }
    
    func findManualStartingLocation() {
        findARStartingLocation()
        box.didUpdateBox(by: box.measurements)
        coachingOverlay?.removeFromSuperview()
        
//        sceneView.scene.background.contents = UIColor.black

        let rotate = SCNAction.rotate(by: CGFloat(GLKMathDegreesToRadians(25)),
                                      around: SCNVector3(0, 1, 0),
                                      duration: 0.0)
        box.runAction(rotate)
        
        state = .done
        delegate?.sceneManagerDidOpenProjectFinish()
    }
}

// MARK: - Box
extension SceneManager {
    func actionClearBox() {
        state = .none
        delegate?.sceneManagerDidChangedDrawState(state)
    }
    
    func didUpdateBoxMeasurement() {
        box.updateLabels(camera: sceneView.session.currentFrame?.camera, distance: Constants.optimalCameraDistance)
        delegate?.sceneManagerDidUpdateMeasurements(box.boxSizeInc)
    }
    
    func actionUpdateMeasurements(_ measurements: Measurements) {
        box.didUpdateBox(by: measurements)
        resetHighlights()
    }
    
    func actionStartDraw() {
        state = DrawingState(rawValue: state.rawValue + 1) ?? .none
        delegate?.sceneManagerDidChangedDrawState(state)
    }
}

// MARK: - Plane {
extension SceneManager {
    func createPlane(anchor: ARAnchor?) -> SCNNode? {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return nil }
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x),
                           height: 0.0001,
                           length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        
        if let material = plane.firstMaterial {
            material.lightingModel = .constant
            material.transparency = 0
            material.writesToDepthBuffer = false
            material.diffuse.contents = UIColor.red
        }
        
        if currentAnchor == nil {
            state = .foundPlane
            DispatchQueue.main.async {
                self.delegate?.sceneManagerDidChangedDrawState(self.state)
            }
        }
        
        return SCNNode(geometry: plane)
    }
    
    func updatePlane(anchor: ARAnchor?, node: SCNNode) {
        guard let planeAnchor = anchor as? ARPlaneAnchor, let plane = node.geometry as? SCNBox else { return }
        
        plane.width = CGFloat(planeAnchor.extent.x)
        plane.length = CGFloat(planeAnchor.extent.z)
        
        // If this anchor is the one the box is positioned relative to, then update the box to match any corrections to the plane's observed position.
        if plane == self.currentAnchor {
            let oldPos = node.position
            let newPos = SCNVector3.positionFromTransform(planeAnchor.transform)
            let delta = newPos - oldPos
            self.box.position += delta
        }
        
        node.transform = SCNMatrix4(planeAnchor.transform)
        node.pivot = SCNMatrix4(translationByX: -planeAnchor.center.x, y: -planeAnchor.center.y, z: -planeAnchor.center.z)
    }
}

// MARK: - ARSCNViewDelegate
extension SceneManager: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard currentAnchor == nil else { return nil }
        return createPlane(anchor: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        let states: [DrawingState] = [.waitingForLocation, .draggingInitialHeight, .draggingInitialWidth, .draggingInitialLength]
        guard states.contains(state) else { return }
        
        DispatchQueue.main.async {
            switch self.state {
            case .waitingForLocation:
                if self.isExistingProject {
                    self.findManualStartingLocation()
                } else {
                    self.findARStartingLocation()
                }
                
            case .draggingInitialWidth:
                self.box.didChangeWorldPosition(self.scenekitHit(), type: .width)
                self.didUpdateBoxMeasurement()
                
            case .draggingInitialLength:
                self.box.didChangeWorldPosition(self.scenekitHit(), type: .length)
                self.didUpdateBoxMeasurement()
                
            default:
                break
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        updatePlane(anchor: anchor, node: node)
    }
}

// MARK: - SCNPhysicsContactDelegate
extension SceneManager: SCNPhysicsContactDelegate {
    func filteredModels(for contact: SCNPhysicsContact) -> [VirtualObject] {
        displayObjects.filter { [contact.nodeA.name, contact.nodeB.name].contains($0.colliderName) }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        filteredModels(for: contact).forEach { $0.physicsWorld(world, didBegin: contact) }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didUpdate contact: SCNPhysicsContact) {
        filteredModels(for: contact).forEach { $0.physicsWorld(world, didUpdate: contact) }
    }
    
    func physicsWorld(_ world: SCNPhysicsWorld, didEnd contact: SCNPhysicsContact) {
        filteredModels(for: contact).forEach { $0.physicsWorld(world, didEnd: contact) }
    }
}

// MARK: - ARCoachingOverlayViewDelegate
extension SceneManager: ARCoachingOverlayViewDelegate {
    func coachingOverlayViewWillActivate(_ coachingOverlayView: ARCoachingOverlayView) {
        //        contentView.arSceneMode = .coachingOverlay
    }
    
    func coachingOverlayViewDidDeactivate(_ coachingOverlayView: ARCoachingOverlayView) {
        
    }
    
    func coachingOverlayViewDidRequestSessionReset(_ coachingOverlayView: ARCoachingOverlayView) {
        //        restartExperience()
    }
}

// MARK: - Gesture
private extension SceneManager {
    @IBAction func actionTapOnScreen(_ gesture: UITapGestureRecognizer) {
        delegate?.sceneManagerDidTapOnScreen()

        let point = gesture.location(in: sceneView)
        let options: [SCNHitTestOption: Any] = [.categoryBitMask: RenderingCategory.model.rawValue]
        guard let model = sceneView.hitTest(point, options: options).first?.node as? VirtualObject  else { return }

        if selectedObject == nil {
            startEditMode(model: model)
        } else {
            stopEditing(model: model)
        }
    }
    
    @IBAction func actionFingerPositionDidChanged(_ gesture: ThresholdPanGesture) {
        switch gesture.state {
        case .began:
            guard let object = selectedObject else { return }
            delegate?.sceneManagerDidMove(object)
            
        case .changed where gesture.isThresholdExceeded:
            let screenPosition = gesture.location(in: sceneView)
            guard
                let object = selectedObject,
                !object.placeholder.isHidden,
                let result = getWorldPosition(from: screenPosition)
            else { return }
            var translation = result.worldTransform.translation
            if let anchor = currentAnchor {
                translation.y = anchor.transform.translation.y
                object.simdWorldTransform.translation = translation
                gesture.setTranslation(.zero, in: sceneView)
            }
            
        case .ended:
            guard let object = selectedObject else { return }
            stopEditing(model: object)
            
        default:
            break
        }
    }
}
