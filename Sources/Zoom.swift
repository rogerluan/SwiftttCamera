// Copyright © 2021 Roger Oba. All rights reserved.

import Foundation
import UIKit

protocol ZoomDelegate : AnyObject {
    /// Called when a pinch gesture was detected, letting the delegate know to handle zooming the camera to the given degree.
    /// - Parameter zoomScale: How much to zoom, a number starting at 1.f and growing larger.
    /// - Returns: true if the current camera is able to zoom, or false otherwise.
    func handlePinchZoom(withScale zoomScale: CGFloat) -> Bool
}

/// Handles zooming. If you want to manually handle zooming, set handlesZoom = false on your SwiftttCamera instance and use its `focusAtPoint` method to manually set the zoom.
@dynamicCallable
final class Zoom {
    /// Delegate of the Zoom instance.
    weak var delegate: ZoomDelegate?
    /// Whether it should detect pinch gestures with a gesture recognizer. Set to false if handling zoom manually. Defaults to true.
    var detectsPinch: Bool = true { didSet { if oldValue != detectsPinch { handleDetectsPinchUpdated() } } }
    /// Set this to the maximum zoom scale of the current camera. Defaults to 1.0.
    var maxScale: CGFloat = 1.0
    /// Set this through CameraProtocol's `gestureDelegate` property if you need to manage custom UIGestureRecognizerDelegate settings. Defaults to nil.
    weak var gestureDelegate: UIGestureRecognizerDelegate?

    private var view: UIView
    private var pinchGestureRecognizer: UIPinchGestureRecognizer?
    var currentScale: CGFloat = 1.0
    private var lastScale: CGFloat?

    // MARK: Lifecycle
    /// Initializes an instance of Zoom.
    /// - Parameters:
    ///   - view: The view to use for receiving touch events.
    ///   - gestureDelegate: The delegate, if any, to use for the pinch gesture recognizer.
    init(view: UIView, gestureDelegate: UIGestureRecognizerDelegate? = nil) {
        self.view = view
        self.gestureDelegate = gestureDelegate
        handleDetectsPinchUpdated()
    }

    deinit {
        delegate = nil
        teardownPinchZoomRecognizerIfNeeded()
    }

    private func setUpPinchZoomRecognizer() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchZoom(recognizer:)))
        pinchGestureRecognizer.cancelsTouchesInView = true
        pinchGestureRecognizer.delegate = gestureDelegate
        self.pinchGestureRecognizer = pinchGestureRecognizer
        view.addGestureRecognizer(pinchGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    private func teardownPinchZoomRecognizerIfNeeded() {
        guard let pinchGestureRecognizer = pinchGestureRecognizer else { return }
        if view.gestureRecognizers?.contains(pinchGestureRecognizer) == true {
            view.removeGestureRecognizer(pinchGestureRecognizer)
        }
        self.pinchGestureRecognizer = nil
    }

    // MARK: Updating
    private func handleDetectsPinchUpdated() {
        if detectsPinch {
            setUpPinchZoomRecognizer()
        } else {
            teardownPinchZoomRecognizerIfNeeded()
        }
    }

    // MARK: Interactions
    /// Call this if manually handling zoom.
    /// - Parameter zoomScale: How much to zoom, a number starting at 1.f and growing larger.
    func showZoom(withScale zoomScale: CGFloat) {
        // TODO: Show some UI to show the zoom scale to the user
        // let zoomPercent = zoomPercent(fromZoomScale: currentScale)
    }

    /// Call this when switching cameras to reset the zoom state to default 1.f scale.
    func resetZoom() {
        // TODO: hide and reset zoom view, when it is implemented.
        currentScale = 1
        maxScale = 1
    }

    @objc
    private func handlePinchZoom(recognizer: UIPinchGestureRecognizer) {
        let newScale: CGFloat = (recognizer.scale * currentScale).constrained(to: 1...maxScale)
        if delegate?.handlePinchZoom(withScale: newScale) == true {
            lastScale = newScale
            showZoom(withScale: newScale)
        }
        if recognizer.state == .ended, let lastScale = lastScale {
            currentScale = lastScale
        }
    }

//    private func zoomPercent(fromZoomScale zoomScale: CGFloat) -> CGFloat {
//        // Calculate a number between 0 and 1 from a zoomScale which ranges from 1 to self.maxScale
//        return (zoomScale - 1) / (maxScale - 1)
//    }
}

// MARK: Dynamic Callable
extension Zoom {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, UIPinchGestureRecognizer>) {
        guard let gestureRecognizer = args.first?.value else { return }
        handlePinchZoom(recognizer: gestureRecognizer)
    }
}
