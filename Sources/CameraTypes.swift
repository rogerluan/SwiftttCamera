// Copyright © 2021 Roger Oba. All rights reserved.

import AVFoundation

/// Constants indicating the physical position of an AVCaptureDevice's hardware on the system.
@objc
public enum CameraDevice {
    /// Indicates that the device is physically located on the front of the system hardware.
    case front
    /// Indicates that the device is physically located on the back of the system hardware.
    case rear

    var captureDevicePosition: AVCaptureDevice.Position {
        switch self {
        case .front: return .front
        case .rear: return .back
        }
    }

    /// Switches the receiver: if it was `front`, it will change to `rear`; if it was `rear`, it will change to `front`.
    public mutating func toggle() {
        switch self {
        case .front: self = .rear
        case .rear: self = .front
        }
    }

    /// Switches the receiver: when `front`, it will return `rear`; when `rear`, it will return `front`.
    public func toggling() -> Self {
        switch self {
        case .front: return .rear
        case .rear: return .front
        }
    }
}

/// Constants indicating the mode of the flash on the receiver's device, if it has one.
public enum CameraFlashMode {
    /// Indicates that the flash should always be on.
    case on
    /// Indicates that the flash should always be off.
    case off
    /// Indicates that the flash should be used automatically depending on ambient light conditions.
    case auto

    var captureFlashMode: AVCaptureDevice.FlashMode {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}

/// Constants indicating the mode of the torch on the receiver's device, if it has one.
public enum CameraTorchMode {
    /// Indicates that the torch should always be on.
    case on
    /// Indicates that the torch should always be off.
    case off
    /// Indicates that the torch should be used automatically depending on ambient light conditions.
    case auto

    var captureTorchMode: AVCaptureDevice.TorchMode {
        switch self {
        case .on: return .on
        case .off: return .off
        case .auto: return .auto
        }
    }
}
