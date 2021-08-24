// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
@testable import SwiftttCamera

final class UIImageUtilitiesPerformanceTests : XCTestCase {
    private var image: UIImage!

    override func setUp() {
        super.setUp()
        image = UIImage(named: "large-test-photo", in: Bundle.module, with: nil)
        image = UIImage(cgImage: image.cgImage!, scale: image.scale, orientation: .leftMirrored)
    }

    override func tearDown() {
        image = nil
        super.tearDown()
    }

    func testCropPerformance() {
        measure {
            let outputRect: CGRect = CGRect(x: 0.1, y: 0.05, width: 0.8, height: 0.9)
            for _ in 0..<10_000 {
                _ = image.croppedImage(fromOutputRect: outputRect)
            }
        }
    }

    func testRotatedPreviewPerformance() {
        measure {
            for _ in 0..<100_000 {
                _ = image.rotatedImageMatchingCameraView(withOrientation: .portrait)
            }
        }
    }

    func testScaleToSizePerformance() {
        measure {
            _ = image.scaledImage(ofSize: CGSize(width: 600, height: 500))
        }
    }

    func testScaleToMaxDimensionPerformance() {
        measure {
            _ = image.scaledImage(withMaxDimension: 600)
        }
    }

    func testScaleToScalePerformance() {
        measure {
            _ = image.scaledImage(withScale: 0.3)
        }
    }

    func testNormalizePerformance() {
        measure {
            _ = image.normalizingOrientation()
        }
    }
}
