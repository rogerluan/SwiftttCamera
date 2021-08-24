// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
@testable import SwiftttCamera

final class SwiftttCameraTests : XCTestCase {
    private var camera: SwiftttCamera!
    private var delegate: Delegate!

    private class Delegate : CameraDelegate {
        var didFinishCapturingImage: ((CapturedImage) -> Void)?
        var didFinishScalingCapturedImage: ((CapturedImage) -> Void)?
        var didFinishNormalizingCapturedImage: ((CapturedImage) -> Void)?

        func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImage capturedImage: CapturedImage) {
            didFinishCapturingImage?(capturedImage)
        }

        func cameraController(_ cameraController: CameraProtocol, didFinishScalingCapturedImage capturedImage: CapturedImage) {
            didFinishScalingCapturedImage?(capturedImage)
        }

        func cameraController(_ cameraController: CameraProtocol, didFinishNormalizingCapturedImage capturedImage: CapturedImage) {
            didFinishNormalizingCapturedImage?(capturedImage)
        }
    }

    override func setUp() {
        super.setUp()
        delegate = Delegate()
        camera = SwiftttCamera()
        camera.loadView()
        camera.view.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
        camera.beginAppearanceTransition(true, animated: false)
        camera.endAppearanceTransition()
        camera.delegate = delegate
    }

    override func tearDown() {
        delegate = nil
        camera = nil
        super.tearDown()
    }

    func testProcessRearCameraPortraitPhoto_shouldReturnFullImage() {
        let imageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .right)
        camera.cropsImageToVisibleAspectRatio = false
        camera.returnsRotatedPreview = false
        camera.scalesImage = false
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        delegate.didFinishCapturingImage = { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size.width, 400)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .right)
            XCTAssertNil(capturedImage.rotatedPreviewImage)
            XCTAssertNil(capturedImage.scaledImage)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: nil, withMaxDimension: nil)
        waitForExpectations(timeout: 3)
    }

    func testProcessRearCameraPortraitPhoto_shouldReturnCroppedImage() {
        let imageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .right)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = false
        camera.scalesImage = false
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        delegate.didFinishCapturingImage = { capturedImage in
            XCTAssertLessThan(capturedImage.fullImage.size.width, 400)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .right)
            XCTAssertNil(capturedImage.rotatedPreviewImage)
            XCTAssertNil(capturedImage.scaledImage)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: CGRect(x: 10, y: 20, width: 100, height: 200), withMaxDimension: nil)
        waitForExpectations(timeout: 3)
    }

    func testProcessRearCameraPortraitPhoto_shouldReturnScaledImage() {
        let imageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .right)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = true
        camera.scalesImage = true
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        expectation.expectedFulfillmentCount = 2
        delegate.didFinishCapturingImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishScalingCapturedImage = { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .right)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .right)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: nil, withMaxDimension: 100)
        waitForExpectations(timeout: 3)
    }

    func testProcessRearCameraPortraitPhoto_shouldReturnNormalizedImages() {
        let imageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .right)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = true
        camera.scalesImage = true
        camera.normalizesImageOrientations = true
        let expectation = self.expectation(description: name)
        expectation.expectedFulfillmentCount = 3
        delegate.didFinishCapturingImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishScalingCapturedImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishNormalizingCapturedImage = { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .up)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .up)
            XCTAssert(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: CGRect(x: 10, y: 20, width: 100, height: 200), withMaxDimension: 100)
        waitForExpectations(timeout: 3)
    }

    func testProcessFrontCameraPortraitPhoto_shouldReturnFullImage() {
        let imageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .leftMirrored)
        camera.cropsImageToVisibleAspectRatio = false
        camera.returnsRotatedPreview = false
        camera.scalesImage = false
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        delegate.didFinishCapturingImage = { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size.width, 400)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .leftMirrored)
            XCTAssertNil(capturedImage.rotatedPreviewImage)
            XCTAssertNil(capturedImage.scaledImage)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: nil, withMaxDimension: nil)
        waitForExpectations(timeout: 3)
    }

    func testProcessFrontCameraPortraitPhoto_shouldReturnCroppedImage() {
        let imageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .leftMirrored)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = false
        camera.scalesImage = false
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        delegate.didFinishCapturingImage = { capturedImage in
            XCTAssertLessThan(capturedImage.fullImage.size.width, 400)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .leftMirrored)
            XCTAssertNil(capturedImage.rotatedPreviewImage)
            XCTAssertNil(capturedImage.scaledImage)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: CGRect(x: 10, y: 20, width: 100, height: 200), withMaxDimension: nil)
        waitForExpectations(timeout: 3)
    }

    func testProcessFrontCameraPortraitPhoto_shouldReturnScaledImage() {
        let imageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .leftMirrored)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = true
        camera.scalesImage = true
        camera.normalizesImageOrientations = false
        let expectation = self.expectation(description: name)
        expectation.expectedFulfillmentCount = 2
        delegate.didFinishCapturingImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishScalingCapturedImage = { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .leftMirrored)
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .leftMirrored)
            XCTAssertFalse(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: nil, withMaxDimension: 100)
        waitForExpectations(timeout: 3)
    }

    func testProcessFrontCameraPortraitPhoto_shouldReturnNormalizedImages() {
        let imageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        let image = UIImage(cgImage: imageAsset.cgImage!, scale: imageAsset.scale, orientation: .leftMirrored)
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = true
        camera.scalesImage = true
        camera.normalizesImageOrientations = true
        let expectation = self.expectation(description: name)
        expectation.expectedFulfillmentCount = 3
        delegate.didFinishCapturingImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishScalingCapturedImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishNormalizingCapturedImage = { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .up)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .up)
            XCTAssert(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.process(image: image, withCropRect: CGRect(x: 10, y: 20, width: 100, height: 200), withMaxDimension: 100)
        waitForExpectations(timeout: 3)
    }

    func testPhotoTaking_shouldTakePhoto() {
        camera.cropsImageToVisibleAspectRatio = true
        camera.returnsRotatedPreview = true
        camera.scalesImage = true
        camera.normalizesImageOrientations = true
        let expectation = self.expectation(description: name)
        expectation.expectedFulfillmentCount = 3
        delegate.didFinishCapturingImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishScalingCapturedImage = { _ in
            expectation.fulfill()
        }
        delegate.didFinishNormalizingCapturedImage = { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .up)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .up)
            XCTAssert(capturedImage.isNormalized)
            expectation.fulfill()
        }
        camera.takePicture()
        waitForExpectations(timeout: 3)
    }
}
