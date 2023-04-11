// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit
@objc
protocol FocusDelegate : AnyObject {
    /// Called when a tap gesture was detected, letting the delegate know to handle focusing the camera at the given point.
    /// - Parameter touchPoint: The point in the view where a tap was detected.
    /// - Returns: true if the current camera is able to focus, false otherwise.
    func handleTapFocus(atPoint touchPoint: CGPoint) -> Bool
}

@dynamicCallable
final class Focus {
    /// The delegate of the Focus instance.
    weak var delegate: FocusDelegate?
    /// Whether it should detect taps with a gesture recognizer. False if handling focus manually. Defaults to YES.
    var detectsTaps: Bool = true { didSet { if oldValue != detectsTaps { handleDetectsTapsChanged() } } }
    /// Set this through CameraProtocol's `gestureDelegate` property if you need to manage custom UIGestureRecognizerDelegate settings. Defaults to nil.
    weak var gestureDelegate: UIGestureRecognizerDelegate?

    private static let focusSquareSize: CGFloat = 50
    private var view: UIView
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var isFocusing: Bool = false

    // MARK: Lifecycle
    /// Initializes an instance of Focus.
    /// - Parameters:
    ///   - view: The view to use for receiving touch events.
    ///   - gestureDelegate: The delegate, if any, to use for the tap gesture recognizer.
    init(view: UIView, gestureDelegate: UIGestureRecognizerDelegate? = nil) {
        self.view = view
        self.gestureDelegate = gestureDelegate
        handleDetectsTapsChanged()
    }

    deinit {
        delegate = nil
        teardownTapFocusRecognizerIfNeeded()
    }

    private func setUpTapFocusRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTapFocus(recognizer:)))
        tapGestureRecognizer.delegate = gestureDelegate
        self.tapGestureRecognizer = tapGestureRecognizer
        view.addGestureRecognizer(tapGestureRecognizer)
        view.isUserInteractionEnabled = true
    }

    private func teardownTapFocusRecognizerIfNeeded() {
        guard let tapGestureRecognizer = tapGestureRecognizer else { return }
        if view.gestureRecognizers?.contains(tapGestureRecognizer) == true {
            view.removeGestureRecognizer(tapGestureRecognizer)
        }
        self.tapGestureRecognizer = nil
    }

    // MARK: Updating
    private func handleDetectsTapsChanged() {
        if detectsTaps {
            setUpTapFocusRecognizer()
        } else {
            teardownTapFocusRecognizerIfNeeded()
        }
    }

    // MARK: Interactions
    /// Call this if manually handling focus.
    /// - Parameter location: The location of the tap in the view.
    func showFocusView(atPoint location: CGPoint) {
        guard !isFocusing else { return }
        isFocusing = true
        let focusView = UIView()
        focusView.layer.borderColor = UIColor.systemYellow.cgColor
        focusView.layer.borderWidth = 2
        focusView.frame = centeredRect(forSize: CGSize(width: Self.focusSquareSize * 2, height: Self.focusSquareSize * 2), atCenterPoint: location)
        focusView.alpha = 0
        view.addSubview(focusView)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            focusView.frame = self.centeredRect(forSize: CGSize(width: Self.focusSquareSize, height: Self.focusSquareSize), atCenterPoint: location)
            focusView.alpha = 1
        } completion: { [weak self] _ in
            UIView.animate(withDuration: 0.2) {
                focusView.alpha = 0
            } completion: { _ in
                focusView.removeFromSuperview()
                self?.isFocusing = false
            }
        }
    }

    @objc
    private func handleTapFocus(recognizer: UITapGestureRecognizer) {
        guard !isFocusing else { return }
        let location: CGPoint = recognizer.location(in: view)
        if delegate?.handleTapFocus(atPoint: location) == true {
            showFocusView(atPoint: location)
        }
    }

    private func centeredRect(forSize size: CGSize, atCenterPoint center: CGPoint) -> CGRect {
        return CGRect(x: center.x, y: center.y, width: .zero, height: .zero).insetBy(dx: -size.width / 2, dy: -size.height / 2)

    }
}

// MARK: Dynamic Callable
extension Focus {
    func dynamicallyCall(withKeywordArguments args: KeyValuePairs<String, UITapGestureRecognizer>) {
        guard let gestureRecognizer = args.first?.value else { return }
        handleTapFocus(recognizer: gestureRecognizer)
    }
}
