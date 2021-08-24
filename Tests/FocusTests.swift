// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
import UIKit
import Foundation
@testable import SwiftttCamera

final class FocusTests : XCTestCase {
    private var focus: Focus!
    private var delegate: FocusDelegate!
    private var view: UIView!
    private var gestureRecognizer: UITapGestureRecognizerMock!

    private class Delegate : FocusDelegate {
        func handleTapFocus(atPoint touchPoint: CGPoint) -> Bool {
            return true
        }
    }

    override func setUp() {
        super.setUp()
        view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        delegate = Delegate()
        focus = Focus(view: view)
        focus.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        focus = nil
        view = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testDetectsTaps_whenTrue_shouldAddGestureRecognizer() {
        focus.detectsTaps = true
        var hasRecognizer = false
        for recognizer in (view.gestureRecognizers ?? []) where recognizer is UITapGestureRecognizer {
            hasRecognizer = true
        }
        XCTAssert(hasRecognizer)
    }

    func testDetectsTaps_whenFalse_shouldRemoveGestureRecognizer() {
        focus.detectsTaps = false
        var hasRecognizer = false
        for recognizer in (view.gestureRecognizers ?? []) where recognizer is UITapGestureRecognizer {
            hasRecognizer = true
        }
        XCTAssertFalse(hasRecognizer)
    }

    func testShowFocusView_shouldHaveSubviews() {
        focus.detectsTaps = true
        focus.showFocusView(atPoint: CGPoint(x: 20, y: 30))
        XCTAssertGreaterThan(view.subviews.count, 0)
    }

    func testTapGesture_whenReceiveOneTap_shouldShowFocusView() {
        replaceExistingTapGestureWithMockTapGesture()
        gestureRecognizer.tap(location: nil, numberOfTapsRequired: nil, numberOfTouchesRequired: nil, state: .ended)
        XCTAssertGreaterThan(view.subviews.count, 0)
    }

    // MARK: - Convenience
    private func replaceExistingTapGestureWithMockTapGesture() {
        guard let existingGestureRecognizer = view.gestureRecognizers?.first(where: { $0 is UITapGestureRecognizer }) as? UITapGestureRecognizer else { return }
        view.removeGestureRecognizer(existingGestureRecognizer)
        let newGestureRecognizer = UITapGestureRecognizerMock()
        newGestureRecognizer.action = { [unowned self, unowned newGestureRecognizer] in
            // DynamicCallable
            self.focus(handleTapFocus: newGestureRecognizer)
        }
        view.addGestureRecognizer(newGestureRecognizer)
        gestureRecognizer = newGestureRecognizer
    }
}
