// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
import UIKit
import Foundation
@testable import SwiftttCamera

final class ZoomTests : XCTestCase {
    private var zoom: Zoom!
    private var delegate: ZoomDelegate!
    private var view: UIView!
    private var gestureRecognizer: UIPinchGestureRecognizerMock!

    private class Delegate : ZoomDelegate {
        func handlePinchZoom(withScale zoomScale: CGFloat) -> Bool {
            return true
        }
    }

    override func setUp() {
        super.setUp()
        view = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))
        delegate = Delegate()
        zoom = Zoom(view: view)
        zoom.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        zoom = nil
        view = nil
        gestureRecognizer = nil
        super.tearDown()
    }

    func testDetectsPinch_whenTrue_shouldAddGestureRecognizer() {
        zoom.detectsPinch = true
        var hasRecognizer = false
        for recognizer in (view.gestureRecognizers ?? []) where recognizer is UIPinchGestureRecognizer {
            hasRecognizer = true
        }
        XCTAssert(hasRecognizer)
    }

    func testDetectsPinch_whenFalse_shouldRemoveGestureRecognizer() {
        zoom.detectsPinch = false
        var hasRecognizer = false
        for recognizer in (view.gestureRecognizers ?? []) where recognizer is UIPinchGestureRecognizer {
            hasRecognizer = true
        }
        XCTAssertFalse(hasRecognizer)
    }

    func testPinchGesture_whenMaxScaleIsGreaterThan1_shouldChangeCurrentScale() {
        replaceExistingPinchGestureWithMockPinchGesture()
        zoom.maxScale = 10
        gestureRecognizer.pinch(location: nil, scale: 1.5, velocity: nil, state: .ended)
        XCTAssertEqual(zoom.currentScale, 1.5)
    }

    func testPinchGesture_whenScaleIsGreaterThanMaxScale_shouldSetMaxScale() {
        replaceExistingPinchGestureWithMockPinchGesture()
        zoom.maxScale = 2
        gestureRecognizer.pinch(location: nil, scale: 3, velocity: nil, state: .ended)
        XCTAssertEqual(zoom.currentScale, 2)
    }

    func testPinchGesture_whenZoomIsSetAndResetZoomIsCalled_shouldResetZoomScale() {
        replaceExistingPinchGestureWithMockPinchGesture()
        zoom.maxScale = 10
        XCTAssertEqual(zoom.maxScale, 10)
        gestureRecognizer.pinch(location: nil, scale: 1.5, velocity: nil, state: .ended)
        XCTAssertEqual(zoom.currentScale, 1.5)
        zoom.resetZoom()
        XCTAssertEqual(zoom.maxScale, 1)
        XCTAssertEqual(zoom.currentScale, 1)
    }

    // MARK: - Convenience
    private func replaceExistingPinchGestureWithMockPinchGesture() {
        guard let existingGestureRecognizer = view.gestureRecognizers?.first(where: { $0 is UIPinchGestureRecognizer }) as? UIPinchGestureRecognizer else { return }
        view.removeGestureRecognizer(existingGestureRecognizer)
        let newGestureRecognizer = UIPinchGestureRecognizerMock()
        newGestureRecognizer.action = { [unowned self, unowned newGestureRecognizer] in
            // DynamicCallable
            self.zoom(handlePinchZoom: newGestureRecognizer)
        }
        view.addGestureRecognizer(newGestureRecognizer)
        gestureRecognizer = newGestureRecognizer
    }
}
