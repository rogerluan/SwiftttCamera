// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
@testable import SwiftttCamera

final class UIImageUtilitiesTests : XCTestCase {
    private var image: UIImage!
    private var rightImage: UIImage!
    private var mirroredImage: UIImage!

    override func setUp() {
        super.setUp()
        image = UIImage(named: "camera-test", in: Bundle.module, with: nil)
        let rightImageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        rightImage = UIImage(cgImage: rightImageAsset.cgImage!, scale: rightImageAsset.scale, orientation: .right)
        let mirroredImageAsset = UIImage(named: "camera-test-left-mirrored", in: Bundle.module, with: nil)!
        mirroredImage = UIImage(cgImage: mirroredImageAsset.cgImage!, scale: mirroredImageAsset.scale, orientation: .leftMirrored)
    }

    override func tearDown() {
        mirroredImage = nil
        rightImage = nil
        image = nil
        super.tearDown()
    }

    func testImages_shouldHaveCorrectOrientation() {
        XCTAssertEqual(image.imageOrientation, .up)
        XCTAssertEqual(rightImage.imageOrientation, .right)
        XCTAssertEqual(mirroredImage.imageOrientation, .leftMirrored)
    }

    func testImages_shouldHaveCorrectSizes() {
        let expectedSize = CGSize(width: 400, height: 320)
        XCTAssertEqual(image.size, expectedSize)
        XCTAssertEqual(rightImage.size, expectedSize)
        XCTAssertEqual(mirroredImage.size, expectedSize)
    }

    func testImageOutputRectCropping_shouldCropToCorrectSizes() {
        let outputRect = CGRect(x: 0.1, y: 0.2, width: 0.25, height: 0.75)
        let croppedImage = image.croppedImage(fromOutputRect: outputRect)
        let croppedRightImage = rightImage.croppedImage(fromOutputRect: outputRect)
        let croppedMirroredImage = mirroredImage.croppedImage(fromOutputRect: outputRect)
        XCTAssertEqual(croppedImage.size, CGSize(width: 100, height: 240))
        XCTAssertEqual(croppedRightImage.size, CGSize(width: 300, height: 80))
        XCTAssertEqual(croppedMirroredImage.size, CGSize(width: 300, height: 80))
    }

    func testImageOutputRectCropping_shouldReturnCorrectOrigin() {
        let outputRect = CGRect(x: 0.1, y: 0.2, width: 0.25, height: 0.75)
        let imageOrigin = image.cropRect(fromOutputRect: outputRect).origin
        let rightImageOrigin = rightImage.cropRect(fromOutputRect: outputRect).origin
        let mirroredImageOrigin = mirroredImage.cropRect(fromOutputRect: outputRect).origin
        XCTAssertEqual(imageOrigin, CGPoint(x: 40, y: 64))
        XCTAssertEqual(rightImageOrigin, CGPoint(x: 32, y: 80))
        XCTAssertEqual(mirroredImageOrigin, CGPoint(x: 32, y: 80))
    }

    func testImageOutputRectCropping_shouldNotChangeImageOrientationOrScale() {
        let outputRect = CGRect(x: 0.1, y: 0.2, width: 0.25, height: 0.75)
        let croppedImage = image.croppedImage(fromOutputRect: outputRect)
        let croppedRightImage = rightImage.croppedImage(fromOutputRect: outputRect)
        let croppedMirroredImage = mirroredImage.croppedImage(fromOutputRect: outputRect)
        XCTAssertEqual(croppedImage.imageOrientation, .up)
        XCTAssertEqual(croppedRightImage.imageOrientation, .right)
        XCTAssertEqual(croppedMirroredImage.imageOrientation, .leftMirrored)
        XCTAssertEqual(croppedImage.scale, image.scale)
        XCTAssertEqual(croppedRightImage.scale, rightImage.scale)
        XCTAssertEqual(croppedMirroredImage.scale, mirroredImage.scale)
    }

    func testImageCropRectCropping_shouldCropToCorrectSizes() {
        let cropRect = CGRect(x: 40, y: 64, width: 100, height: 240)
        let croppedImage = image.croppedImage(fromCropRect: cropRect)
        let croppedRightImage = rightImage.croppedImage(fromCropRect: cropRect)
        let croppedMirroredImage = mirroredImage.croppedImage(fromCropRect: cropRect)
        XCTAssertEqual(croppedImage.size, CGSize(width: 100, height: 240))
        XCTAssertEqual(croppedRightImage.size, CGSize(width: 240, height: 100))
        XCTAssertEqual(croppedMirroredImage.size, CGSize(width: 240, height: 100))
    }

    func testImageCropRectCropping_shouldNotChangeImageOrientationOrScale() {
        let cropRect = CGRect(x: 40, y: 64, width: 100, height: 240)
        let croppedImage = image.croppedImage(fromCropRect: cropRect)
        let croppedRightImage = rightImage.croppedImage(fromCropRect: cropRect)
        let croppedMirroredImage = mirroredImage.croppedImage(fromCropRect: cropRect)
        XCTAssertEqual(croppedImage.imageOrientation, .up)
        XCTAssertEqual(croppedRightImage.imageOrientation, .right)
        XCTAssertEqual(croppedMirroredImage.imageOrientation, .leftMirrored)
        XCTAssertEqual(croppedImage.scale, image.scale)
        XCTAssertEqual(croppedRightImage.scale, rightImage.scale)
        XCTAssertEqual(croppedMirroredImage.scale, mirroredImage.scale)
    }

    func testImageScaleToSize_shouldScaleToCorrectSizes() {
        let scaledSize = CGSize(width: 100, height: 80)
        let scaledImage = image.scaledImage(ofSize: scaledSize)!
        let scaledRightImage = rightImage.scaledImage(ofSize: scaledSize)!
        let scaledMirroredImage = mirroredImage.scaledImage(ofSize: scaledSize)!
        let expectedSize = CGSize(width: 100, height: 80)
        XCTAssertEqual(scaledImage.size, expectedSize)
        XCTAssertEqual(scaledRightImage.size, expectedSize)
        XCTAssertEqual(scaledMirroredImage.size, expectedSize)
    }

    func testImageScaleToSize_shouldNotChangeImageOrientation() {
        let scaledSize = CGSize(width: 100, height: 80)
        let scaledImage = image.scaledImage(ofSize: scaledSize)!
        let scaledRightImage = rightImage.scaledImage(ofSize: scaledSize)!
        let scaledMirroredImage = mirroredImage.scaledImage(ofSize: scaledSize)!
        XCTAssertEqual(scaledImage.imageOrientation, .up)
        XCTAssertEqual(scaledRightImage.imageOrientation, .right)
        XCTAssertEqual(scaledMirroredImage.imageOrientation, .leftMirrored)
    }

    func testImageScaleToSize_shouldSetScaleToScreenScale() {
        let scaledSize = CGSize(width: 100, height: 80)
        let scaledImage = image.scaledImage(ofSize: scaledSize)!
        let scaledRightImage = rightImage.scaledImage(ofSize: scaledSize)!
        let scaledMirroredImage = mirroredImage.scaledImage(ofSize: scaledSize)!
        let expectedScale = UIScreen.main.scale
        XCTAssertEqual(scaledImage.scale, expectedScale)
        XCTAssertEqual(scaledRightImage.scale, expectedScale)
        XCTAssertEqual(scaledMirroredImage.scale, expectedScale)
    }

    func testImageScaleToMaxDimension_shouldScaleToCorrectSizes() {
        let maxDimension: CGFloat = 100
        let scaledImage = image.scaledImage(withMaxDimension: maxDimension)!
        let scaledRightImage = rightImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledMirroredImage = mirroredImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledTallImageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let scaledTallImage = scaledTallImageAsset.scaledImage(withMaxDimension: maxDimension)!
        XCTAssertEqual(scaledImage.size, CGSize(width: 100, height: 80))
        XCTAssertEqual(scaledRightImage.size, CGSize(width: 100, height: 80))
        XCTAssertEqual(scaledMirroredImage.size, CGSize(width: 100, height: 80))
        XCTAssertEqual(scaledTallImage.size, CGSize(width: 80, height: 100))
    }

    func testImageScaleToMaxDimension_shouldNotChangeImageOrientation() {
        let maxDimension: CGFloat = 100
        let scaledImage = image.scaledImage(withMaxDimension: maxDimension)!
        let scaledRightImage = rightImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledMirroredImage = mirroredImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledTallImageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let scaledTallImage = scaledTallImageAsset.scaledImage(withMaxDimension: maxDimension)!
        XCTAssertEqual(scaledImage.imageOrientation, .up)
        XCTAssertEqual(scaledRightImage.imageOrientation, .right)
        XCTAssertEqual(scaledMirroredImage.imageOrientation, .leftMirrored)
        XCTAssertEqual(scaledTallImage.imageOrientation, .up)
    }

    func testImageScaleToMaxDimension_shouldSetScaleToScreenScale() {
        let maxDimension: CGFloat = 100
        let scaledImage = image.scaledImage(withMaxDimension: maxDimension)!
        let scaledRightImage = rightImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledMirroredImage = mirroredImage.scaledImage(withMaxDimension: maxDimension)!
        let scaledTallImageAsset = UIImage(named: "camera-test-right", in: Bundle.module, with: nil)!
        let scaledTallImage = scaledTallImageAsset.scaledImage(withMaxDimension: maxDimension)!
        let expectedScale = UIScreen.main.scale
        XCTAssertEqual(scaledImage.scale, expectedScale)
        XCTAssertEqual(scaledRightImage.scale, expectedScale)
        XCTAssertEqual(scaledMirroredImage.scale, expectedScale)
        XCTAssertEqual(scaledTallImage.scale, expectedScale)
    }

    func testImageScaleToScale_shouldScaleToCorrectSizes() {
        let scale: CGFloat = 0.25
        let scaledImage = image.scaledImage(withScale: scale)!
        let scaledRightImage = rightImage.scaledImage(withScale: scale)!
        let scaledMirroredImage = mirroredImage.scaledImage(withScale: scale)!
        let expectedSize = CGSize(width: 100, height: 80)
        XCTAssertEqual(scaledImage.size, expectedSize)
        XCTAssertEqual(scaledRightImage.size, expectedSize)
        XCTAssertEqual(scaledMirroredImage.size, expectedSize)
    }

    func testImageScaleToScale_shouldNotChangeImageOrientation() {
        let scale: CGFloat = 0.25
        let scaledImage = image.scaledImage(withScale: scale)!
        let scaledRightImage = rightImage.scaledImage(withScale: scale)!
        let scaledMirroredImage = mirroredImage.scaledImage(withScale: scale)!
        XCTAssertEqual(scaledImage.imageOrientation, .up)
        XCTAssertEqual(scaledRightImage.imageOrientation, .right)
        XCTAssertEqual(scaledMirroredImage.imageOrientation, .leftMirrored)
    }

    func testImageScaleToScale_shouldSetScaleToScreenScale() {
        let scale: CGFloat = 0.25
        let scaledImage = image.scaledImage(withScale: scale)!
        let scaledRightImage = rightImage.scaledImage(withScale: scale)!
        let scaledMirroredImage = mirroredImage.scaledImage(withScale: scale)!
        let expectedScale = UIScreen.main.scale
        XCTAssertEqual(scaledImage.scale, expectedScale)
        XCTAssertEqual(scaledRightImage.scale, expectedScale)
        XCTAssertEqual(scaledMirroredImage.scale, expectedScale)
    }

    func testImageOrientationNormalization_shouldNormalizeToCorrectSizes() {
        let normalizedImage = image.normalizingOrientation()
        let normalizedRightImage = rightImage.normalizingOrientation()
        let normalizedMirroredImage = mirroredImage.normalizingOrientation()
        let expectedSize = CGSize(width: 400, height: 320)
        XCTAssertEqual(normalizedImage.size, expectedSize)
        XCTAssertEqual(normalizedRightImage.size, expectedSize)
        XCTAssertEqual(normalizedMirroredImage.size, expectedSize)
    }

    func testImageOrientationNormalization_shouldChangeImageOrientationToUp() {
        let normalizedImage = image.normalizingOrientation()
        let normalizedRightImage = rightImage.normalizingOrientation()
        let normalizedMirroredImage = mirroredImage.normalizingOrientation()
        XCTAssertEqual(normalizedImage.imageOrientation, .up)
        XCTAssertEqual(normalizedRightImage.imageOrientation, .up)
        XCTAssertEqual(normalizedMirroredImage.imageOrientation, .up)
    }

    func testImageOrientationNormalization_shouldNotChangeScale() {
        let normalizedImage = image.normalizingOrientation()
        let normalizedRightImage = rightImage.normalizingOrientation()
        let normalizedMirroredImage = mirroredImage.normalizingOrientation()
        XCTAssertEqual(normalizedImage.scale, image.scale)
        XCTAssertEqual(normalizedRightImage.scale, rightImage.scale)
        XCTAssertEqual(normalizedMirroredImage.scale, mirroredImage.scale)
    }

    func testImageRotateToMatchCameraView_shouldRotateToCorrectSizes() {
        let rotatedImage = image.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedRightImage = rightImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedMirroredImage = mirroredImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        XCTAssertEqual(rotatedImage.size, CGSize(width: 320, height: 400))
        XCTAssertEqual(rotatedRightImage.size, CGSize(width: 400, height: 320))
        XCTAssertEqual(rotatedMirroredImage.size, CGSize(width: 400, height: 320))
    }

    func testImageRotateToMatchCameraView_shouldChangeImageOrientationToMatchCameraPreview() {
        let rotatedImage = image.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedRightImage = rightImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedMirroredImage = mirroredImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        XCTAssertEqual(rotatedImage.imageOrientation, .right)
        XCTAssertEqual(rotatedRightImage.imageOrientation, .right)
        XCTAssertEqual(rotatedMirroredImage.imageOrientation, .leftMirrored)
    }

    func testImageRotateToMatchCameraView_shouldNotChangeScale() {
        let rotatedImage = image.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedRightImage = rightImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        let rotatedMirroredImage = mirroredImage.rotatedImageMatchingCameraView(withOrientation: .portrait)
        XCTAssertEqual(rotatedImage.scale, image.scale)
        XCTAssertEqual(rotatedRightImage.scale, rightImage.scale)
        XCTAssertEqual(rotatedMirroredImage.scale, mirroredImage.scale)
    }
}
