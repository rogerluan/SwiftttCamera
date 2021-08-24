// Copyright © 2021 Roger Oba. All rights reserved.

import AVFoundation

public extension AVCaptureDevice {
    /// All camera devices available in this device currently.
    /// Devices are sorted by AVCaptureDeviceType, matching the order specified in the deviceTypes parameter of +[AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:mediaType:position:]. If a `.unspecified` position is given, the results are further ordered by position in the AVCaptureDevicePosition enum.
    static func availableCameras(position: AVCaptureDevice.Position = .unspecified) -> [AVCaptureDevice] {
        /// For apps linked against iOS 11 or later, the
        return AVCaptureDevice.DiscoverySession(deviceTypes: availableCameraTypes, mediaType: .video, position: position).devices
    }

    /// All camera types available in iOS.
    static let allCameras: [AVCaptureDevice.DeviceType] = [
        .builtInWideAngleCamera,
        .builtInTelephotoCamera,
        .builtInDualCamera,
        .builtInTrueDepthCamera,
        .builtInUltraWideCamera,
        .builtInDualWideCamera,
        .builtInTripleCamera,
    ]

    /// All camera types available in this device.
    static let availableCameraTypes: [AVCaptureDevice.DeviceType] = allCameras.filter { AVCaptureDevice.DiscoverySession(deviceTypes: [ $0 ], mediaType: .video, position: .unspecified).devices.isEmpty == false }
}

public extension AVCaptureDevice {
    /// Checks whether either point focus or point exposure is available for the given CameraDevice.
    /// - Parameter cameraDevice: The CameraDevice to check.
    /// - Returns: True if point focus or point exposure is available for the given CameraDevice. Otherwise, false.
    static func isPointFocusAvailable(for cameraDevice: CameraDevice) -> Bool {
        guard let device: AVCaptureDevice = captureDevice(from: cameraDevice) else { return false }
        return device.isFocusPointOfInterestSupported || device.isExposurePointOfInterestSupported
    }

    /// Returns the AVCaptureDevice that corresponds to the given CameraDevice position.
    /// - Parameter cameraDevice: The CameraDevice camera position to check.
    /// - Returns: The AVCaptureDevice that corresponds to the given CameraDevice position.
    static func captureDevice(from cameraDevice: CameraDevice) -> AVCaptureDevice? {
        // TODO: Handle multiple cameras?
        return AVCaptureDevice.availableCameras(position: cameraDevice.captureDevicePosition).first
    }

    /// Checks whether torch is available for the given CameraDevice.
    /// - Parameter cameraDevice: The CameraDevice to check.
    /// - Returns: True if torch is available for the device. Otherwise, false.
    static func isTorchAvailable(for cameraDevice: CameraDevice) -> Bool {
        return captureDevice(from: cameraDevice)?.isTorchModeSupported(.on) == true
    }

    /// Sets the CameraTorchMode for this AVCaptureDevice.
    /// - Parameter torchMode: The CameraTorchMode to set for this AVCaptureDevice.
    /// - Returns: True if the CameraTorchMode is supported by this AVCaptureDevice. Otherwise, false.
    @discardableResult
    func setCameraTorchMode(_ torchMode: CameraTorchMode) -> Bool {
        do {
            var didSet = false
            try lockForConfiguration()
            if isTorchModeSupported(torchMode.captureTorchMode) {
                self.torchMode = torchMode.captureTorchMode
                didSet = true
            }
            unlockForConfiguration()
            return didSet
        } catch {
            dump(error)
            return false
        }
    }
}

public extension AVCaptureDevice {
    /// Tells this AVCaptureDevice to focus and set point exposure at the given point of interest.
    /// - Parameter pointOfInterest: The point of interest in the current AVCaptureDevice's coordinate system at which to set point focus and point exposure for this device.
    /// - Returns: True if the device was able to focus. Otherwise, false.
    func focus(at pointOfInterest: CGPoint) -> Bool {
        do {
            try lockForConfiguration()
            if isFocusPointOfInterestSupported {
                focusPointOfInterest = pointOfInterest
            }
            if isExposurePointOfInterestSupported {
                exposurePointOfInterest = pointOfInterest
            }
            setFocusModeIfSupported(.continuousAutoFocus)
            setExposureModeIfSupported(.continuousAutoExposure)
            unlockForConfiguration()
            return true
        } catch {
            dump(error)
            return false
        }
    }

    /// The maximum zoom scale of this device.
    var videoMaxZoomFactor: CGFloat {
        return min(activeFormat.videoMaxZoomFactor, 4)
    }

    /// Tells this AVCaptureDevice to zoom to the given scale.
    /// - Parameter zoomScale: The scale to which to zoom the camera device.
    /// - Returns: True if zoomed successfully. Otherwise, false.
    func zoom(to zoomScale: CGFloat) -> Bool {
        do {
            var didSet = false
            try lockForConfiguration()
            if zoomScale <= videoMaxZoomFactor, zoomScale >= 1 {
                videoZoomFactor = zoomScale
                didSet = true
            }
            unlockForConfiguration()
            return didSet
        } catch {
            dump(error)
            return false
        }
    }
}

public extension AVCaptureDevice {
    /// Sets the given focus mode to this device, if it's supported.
    func setFocusModeIfSupported(_ focusMode: AVCaptureDevice.FocusMode) {
        guard isFocusModeSupported(focusMode) else { return }
        self.focusMode = focusMode
    }

    /// Sets the given exposure mode to this device, if it's supported.
    func setExposureModeIfSupported(_ exposureMode: ExposureMode) {
        guard isExposureModeSupported(exposureMode) else { return }
        self.exposureMode = exposureMode
    }
}
