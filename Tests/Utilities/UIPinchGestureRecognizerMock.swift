// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit

class UIPinchGestureRecognizerMock : UIPinchGestureRecognizer {
    var action: (() -> Void)?
    var gestureState: UIGestureRecognizer.State?
    var gestureLocation: CGPoint?
    var gestureScale: CGFloat?
    var gestureVelocity: CGFloat?

    init() {
        super.init(target: nil, action: nil)
    }

    override func location(in view: UIView?) -> CGPoint {
        return gestureLocation ?? super.location(in: view)
    }

    override var scale: CGFloat {
        get { return gestureScale ?? super.scale }
        set { super.scale = newValue }
    }

    override var velocity: CGFloat {
        return gestureVelocity ?? super.velocity
    }

    override var state: UIGestureRecognizer.State {
        get { return gestureState ?? super.state }
        set { super.state = newValue }
    }

    @objc
    private func execute() {
        action?()
    }
}

extension UIPinchGestureRecognizerMock {
    func pinch(location: CGPoint?, scale: CGFloat?, velocity: CGFloat?, state: UIGestureRecognizer.State) {
        guard let action = action else { return }
        gestureState = state
        gestureLocation = location
        gestureScale = scale
        gestureVelocity = velocity
        action()
    }
}
