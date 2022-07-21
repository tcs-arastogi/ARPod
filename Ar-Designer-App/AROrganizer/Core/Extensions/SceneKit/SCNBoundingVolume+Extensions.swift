//
//  SCNNode+Extensions.swift
//  ARDesignerApp
//
//  Created by Vitalii Yaremchuk on 2/6/22.
//

import SceneKit

extension SCNBoundingVolume {
	// Returns a point at a specified normalized location within the bounds of the volume, where 0 is min and 1 is max.
	func pointInBounds(at normalizedLocation: SCNVector3) -> SCNVector3 {
		let boundsSize = boundingBox.max - boundingBox.min
		let locationInPoints = boundsSize * normalizedLocation
		return locationInPoints + boundingBox.min
	}
}
