// Copyright © 2021 Roger Oba. All rights reserved.

import XCTest
@testable import SwiftttCamera

final class DeviceOrientationTests : XCTestCase {
    private var deviceOrientation: DeviceOrientation!

    override func setUp() {
        super.setUp()
        deviceOrientation = DeviceOrientation()
    }

    override func tearDown() {
        deviceOrientation = nil
        super.tearDown()
    }

    func testOrientation() {
        XCTAssert(deviceOrientation.orientation == .portrait)
    }

    func testDeviceOrientationMatchesInterfaceOrientation() {
        // Because UIDevice.current.orientation == .unknown on unit tests
        XCTAssertFalse(deviceOrientation.deviceOrientationMatchesInterfaceOrientation)
    }
}
