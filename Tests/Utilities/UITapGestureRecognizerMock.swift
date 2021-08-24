// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit

class UITapGestureRecognizerMock : UITapGestureRecognizer {
    var action: (() -> Void)?
    var gestureState: UIGestureRecognizer.State?
    var gestureLocation: CGPoint?
    var gestureNumberOfTapsRequired: Int?
    var gestureNumberOfTouchesRequired: Int?

    init() {
        super.init(target: nil, action: nil)
    }

    override func location(in view: UIView?) -> CGPoint {
        return gestureLocation ?? super.location(in: view)
    }

    override var numberOfTapsRequired: Int {
        get { return gestureNumberOfTapsRequired ?? super.numberOfTapsRequired }
        set { super.numberOfTapsRequired = newValue }
    }

    override var numberOfTouchesRequired: Int {
        get { return gestureNumberOfTouchesRequired ?? super.numberOfTouchesRequired }
        set { super.numberOfTouchesRequired = newValue }
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

extension UITapGestureRecognizerMock {
    func tap(location: CGPoint?, numberOfTapsRequired: Int?, numberOfTouchesRequired: Int?, state: UIGestureRecognizer.State) {
        guard let action = action else { return }
        gestureState = state
        gestureLocation = location
        gestureNumberOfTapsRequired = numberOfTapsRequired
        gestureNumberOfTouchesRequired = numberOfTouchesRequired
        action()
    }
}
