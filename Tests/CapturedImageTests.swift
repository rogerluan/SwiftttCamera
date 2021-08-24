// Copyright © 2021 Roger Oba. All rights reserved.

import Combine
import XCTest
@testable import SwiftttCamera

final class CapturedImageTests : XCTestCase {
    private var capturedImage: CapturedImage!
    private var mirroredCapturedImage: CapturedImage!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        let image = UIImage(named: "camera-test", in: Bundle.module, with: nil)!
        capturedImage = CapturedImage(fullImage: image)
        let mirroredImageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        let mirroredImage = UIImage(cgImage: mirroredImageAsset.cgImage!, scale: mirroredImageAsset.scale, orientation: .leftMirrored)
        mirroredCapturedImage = CapturedImage(fullImage: mirroredImage)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        cancellables = nil
        capturedImage = nil
        mirroredCapturedImage = nil
        super.tearDown()
    }

    func testInitialSettings() {
        XCTAssertEqual(capturedImage.fullImage.size, CGSize(width: 400, height: 320))
        XCTAssertNil(capturedImage.userInfo)
        XCTAssertNil(capturedImage.scaledImage)
        XCTAssertNil(capturedImage.rotatedPreviewImage)
        XCTAssertFalse(capturedImage.isNormalized)
    }

    func testCropAndPreview_whenCroppingToNilRect_andReturnsPreviewIsFalse_andNeedsPreviewRotationIsFalse_shouldReturnUncroppedImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: false, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, CGSize(width: 400, height: 320))
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCroppingToNilRect_andReturnsPreviewIsTrue_andNeedsPreviewRotationIsFalse_shouldReturnUncroppedImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, CGSize(width: 400, height: 320))
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCroppingToNilRect_andReturnsPreviewIsFalse_andNeedsPreviewRotationIsTrue_shouldReturnUncroppedImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: false, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, CGSize(width: 400, height: 320))
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCroppingToNilRect_andReturnsPreviewIsTrue_andNeedsPreviewRotationIsTrue_shouldReturnUncroppedImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, CGSize(width: 400, height: 320))
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCropping_andReturnsPreviewIsFalse_andNeedsPreviewRotationIsFalse_shouldReturnNonnullCroppedImageWithCroppedSize() {
        let cropSize = CGSize(width: 80, height: 120)
        let cropRect = CGRect(origin: CGPoint(x: 10, y: 20), size: cropSize)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: false, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, cropSize)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCropping_andReturnsPreviewIsTrue_andNeedsPreviewRotationIsFalse_shouldReturnNonnullCroppedImageWithCroppedSize() {
        let cropSize = CGSize(width: 80, height: 120)
        let cropRect = CGRect(origin: CGPoint(x: 10, y: 20), size: cropSize)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, cropSize)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCropping_andReturnsPreviewIsFalse_andNeedsPreviewRotationIsTrue_shouldReturnNonnullCroppedImageWithCroppedSize() {
        let cropSize = CGSize(width: 80, height: 120)
        let cropRect = CGRect(origin: CGPoint(x: 10, y: 20), size: cropSize)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: false, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, cropSize)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenCropping_andReturnsPreviewIsTrue_andNeedsPreviewRotationIsTrue_shouldReturnNonnullCroppedImageWithCroppedSize() {
        let cropSize = CGSize(width: 80, height: 120)
        let cropRect = CGRect(origin: CGPoint(x: 10, y: 20), size: cropSize)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.fullImage.size, cropSize)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsFalse_andCropRectIsNil_andNeedsPreviewRotationIsFalse_shouldNotReturnPreviewImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: false, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsFalse_andCropRectIsNil_andNeedsPreviewRotationIsTrue_shouldNotReturnPreviewImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: false, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsFalse_andCropRectIsSet_andNeedsPreviewRotationIsFalse_shouldNotReturnPreviewImage() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: false, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsFalse_andCropRectIsSet_andNeedsPreviewRotationIsTrue_shouldNotReturnPreviewImage() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: false, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsTrue_andCropRectIsNil_andNeedsPreviewRotationIsFalse_shouldNotReturnPreviewImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNotNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsTrue_andCropRectIsNil_andNeedsPreviewRotationIsTrue_shouldNotReturnPreviewImage() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNotNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsTrue_andCropRectIsSet_andNeedsPreviewRotationIsFalse_shouldNotReturnPreviewImage() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNotNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenReturnsPreviewIsTrue_andCropRectIsSet_andNeedsPreviewRotationIsTrue_shouldNotReturnPreviewImage() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertNotNil(capturedImage.rotatedPreviewImage)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenNeedsPreviewRotationIsTrue_andCropRectIsSet_andReturnsPreviewIsTrue_shouldReturnCorrectOrientation() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .right)
        }
        expect(future: mirroredCapturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .leftMirrored)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenNeedsPreviewRotationIsTrue_andCropRectIsNil_andReturnsPreviewIsTrue_shouldReturnCorrectOrientation() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .right)
        }
        expect(future: mirroredCapturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: true, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .leftMirrored)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenNeedsPreviewRotationIsFalse_andCropRectIsSet_andReturnsPreviewIsTrue_shouldNotChangeOrientationo() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .up)
        }
        expect(future: mirroredCapturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .leftMirrored)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenNeedsPreviewRotationIsFalse_andCropRectIsNil_andReturnsPreviewIsTrue_shouldNotChangeOrientation() {
        expect(future: capturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .up)
        }
        expect(future: mirroredCapturedImage.crop(to: nil, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertEqual(capturedImage.rotatedPreviewImage?.imageOrientation, .leftMirrored)
        }
        waitForExpectations(timeout: 3)
    }

    func testCropAndPreview_whenNeedsPreviewRotationIsFalse_andCropRectIsSet_andReturnsPreviewIsTrue_shouldReturnIsNormalizedFalse() {
        let cropRect = CGRect(x: 10, y: 20, width: 80, height: 120)
        expect(future: capturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertFalse(capturedImage.isNormalized)
        }
        expect(future: mirroredCapturedImage.crop(to: cropRect, returnsPreview: true, needsPreviewRotation: false, withPreviewOrientation: .portrait)) { capturedImage in
            XCTAssertFalse(capturedImage.isNormalized)
        }
        waitForExpectations(timeout: 3)
    }

    func testScaleImageToMaxDimension_shouldReturnCorrectlyScaledImageAndNonNormalizedCapturedImage() {
        let maxDimension: CGFloat = 80
        expect(future: capturedImage.scale(to: maxDimension)) { capturedImage in
            guard let scaledImage = capturedImage.scaledImage else { return XCTFail("capturedImage.scaledImage is nil") }
            XCTAssertLessThanOrEqual(scaledImage.size.width, maxDimension)
            XCTAssertLessThanOrEqual(scaledImage.size.height, maxDimension)
            XCTAssertFalse(capturedImage.isNormalized)
        }
        expect(future: mirroredCapturedImage.scale(to: maxDimension)) { capturedImage in
            guard let scaledImage = capturedImage.scaledImage else { return XCTFail("capturedImage.scaledImage is nil") }
            XCTAssertLessThanOrEqual(scaledImage.size.width, maxDimension)
            XCTAssertLessThanOrEqual(scaledImage.size.height, maxDimension)
            XCTAssertFalse(capturedImage.isNormalized)
        }
        waitForExpectations(timeout: 3)
    }

    func testScaleImageToSize_shouldReturnCorrectlyScaledImageAndNonNormalizedCapturedImage() {
        let size = CGSize(width: 100, height: 80)
        expect(future: capturedImage.scale(to: size)) { capturedImage in
            guard let scaledImage = capturedImage.scaledImage else { return XCTFail("capturedImage.scaledImage is nil") }
            XCTAssertLessThanOrEqual(scaledImage.size.width, size.width)
            XCTAssertLessThanOrEqual(scaledImage.size.height, size.height)
            XCTAssertFalse(capturedImage.isNormalized)
        }
        expect(future: mirroredCapturedImage.scale(to: size)) { capturedImage in
            guard let scaledImage = capturedImage.scaledImage else { return XCTFail("capturedImage.scaledImage is nil") }
            XCTAssertLessThanOrEqual(scaledImage.size.width, size.width)
            XCTAssertLessThanOrEqual(scaledImage.size.height, size.height)
            XCTAssertFalse(capturedImage.isNormalized)
        }
        waitForExpectations(timeout: 3)
    }

    func testNormalizeImage_shouldReturnNormalizedImagesWithUpOrientation() {
        capturedImage.scaledImage = capturedImage.fullImage
        mirroredCapturedImage.scaledImage = mirroredCapturedImage.fullImage
        expect(future: capturedImage.normalize()) { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .up)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .up)
            XCTAssert(capturedImage.isNormalized)
        }
        expect(future: mirroredCapturedImage.normalize()) { capturedImage in
            XCTAssertNotNil(capturedImage.scaledImage)
            XCTAssertEqual(capturedImage.fullImage.imageOrientation, .up)
            XCTAssertEqual(capturedImage.scaledImage?.imageOrientation, .up)
            XCTAssert(capturedImage.isNormalized)
        }
        waitForExpectations(timeout: 3)
    }

    // MARK: - Convenience
    private func expect<T>(future: Future<T, Never>, function: StaticString = #function, line: Int = #line, asserting: @escaping (T) -> Void) {
        let expectation = self.expectation(description: "\(name) \(function):\(line)")
        future
            .sink { _ in
                expectation.fulfill()
            } receiveValue: { value in
                asserting(value)
            }
            .store(in: &cancellables)
    }
}
