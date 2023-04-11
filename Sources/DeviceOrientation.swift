// Copyright © 2021 Roger Oba. All rights reserved.

import CoreMotion
import UIKit

/// Struct used to manage the device's actual orientation.
@objc
final class DeviceOrientation {
    private lazy var motionManager: CMMotionManager? = {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        #if TARGET_IPHONE_SIMULATOR
        return nil
        #else
        let result = CMMotionManager()
        result.accelerometerUpdateInterval = 0.005
        result.startAccelerometerUpdates()
        return result
        #endif
    }()

    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        #if !TARGET_IPHONE_SIMULATOR
        motionManager?.stopAccelerometerUpdates()
        #endif
        motionManager = nil
    }

    /// The current actual orientation of the device, based on accelerometer data if on a device, or [[UIDevice currentDevice] orientation] if on the simulator.
    var orientation: UIDeviceOrientation {
        #if TARGET_IPHONE_SIMULATOR
        return .portrait
        #else
        guard let acceleration: CMAcceleration = motionManager?.accelerometerData?.acceleration else { return .portrait }
        if (acceleration.z < -0.75) {
            return .faceUp
        }
        if (acceleration.z > 0.75) {
            return .faceDown
        }

        let scaling: CGFloat = CGFloat(1 / abs(acceleration.x) + abs(acceleration.y))
        let x: CGFloat = CGFloat(acceleration.x) * scaling
        let y: CGFloat = CGFloat(acceleration.y) * scaling

        if (x < -0.5) {
            return .landscapeLeft
        }
        if (x > 0.5) {
            return .landscapeRight
        }
        if (y > 0.5) {
            return .portraitUpsideDown
        }
        return .portrait
        #endif
    }

    /// Whether the physical orientation of the device matches the device's interface orientation.
    /// Expect this to return true when orientation lock is off, and false when orientation lock is on.
    /// This returns true if the device's interface orientation matches the physical device orientation, and false if the interface and physical orientation are different (when orientation lock is on).
    var deviceOrientationMatchesInterfaceOrientation: Bool {
        return orientation == UIDevice.current.orientation
    }
}
