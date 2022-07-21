//
//  ThresholdPanGesture.swift
//  ARDesignerApp
//
//  Created by Goran Pavlovic on 3/31/22.
//

// Abstract:
// Contains `ThresholdPanGesture` - a custom `UIPanGestureRecognizer` to track a translation threshold for panning.
//
// Provides a way to delay the gesture recognizer's effect until after the gesture in progress passes a specified
// movement threshold. This sample code's `touchesMoved(with:)` method uses this class to let the user smoothly
// transition between dragging an object and rotating it during a single two-finger gesture.

import UIKit.UIGestureRecognizerSubclass

/**
 A custom `UIPanGestureRecognizer` to track when a translation threshold has been exceeded
 and panning should begin.
 
 - Tag: ThresholdPanGesture
 */
final class ThresholdPanGesture: UIPanGestureRecognizer {
    // Indicates whether the currently active gesture has exceeeded the threshold.
    private(set) var isThresholdExceeded = false
    
    override var state: UIGestureRecognizer.State {
        didSet {
            switch state {
            case .began, .changed:
                break
                
            default: // Reset threshold check.
                isThresholdExceeded = false
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        
        let translationMagnitude = translation(in: view).length()
        
        // Adjust the threshold based on the number of touches being used.
        let threshold = ThresholdPanGesture.threshold(forTouchCount: touches.count)
        
        if !isThresholdExceeded && translationMagnitude > threshold {
            isThresholdExceeded = true
            
            // Set the overall translation to zero as the gesture should now begin.
            setTranslation(.zero, in: view)
        }
    }
}

// MARK: - Private functions
private extension ThresholdPanGesture {
    // Returns the threshold value that should be used dependent on the number of touches.
    static func threshold(forTouchCount count: Int) -> CGFloat {
        switch count {
        case 1: // Use a higher threshold for gestures using more than 1 finger. This gives other gestures priority.
            return 30
            
        default:
            return 60
        }
    }
}
