// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit

public protocol CameraProtocol : AnyObject {
    /// The delegate of the SwiftttCamera instance.
    var delegate: CameraDelegate? { get set }

    // MARK: - Advanced Configurations Options

    /// Set this to false if you don't want to enable SwiftttCamera to manage tap-to-focus with its internal tap gesture recognizer.
    /// You can still send it manual focusAtPoint: calls from your own gesture recognizer. Defaults to true.
    var handlesTapFocus: Bool { get set }

    /// Set this to false if you don't want the focus square to show when the camera is focusing at a point. Defaults to true.
    var showsFocusView: Bool { get set }

    /// Set this to false if you don't want to enable SwiftttCamera to manage pinch-to-zoom with its internal pinch gesture recognizer. You can still send it manual `zoom(to:)` calls from your own gesture recognizer. Defaults to true.
    var handlesZoom: Bool { get set }

    /// Set this to false if you don't want the zoom indicator to show when the camera is zoomed in. Defaults to true.
    var showsZoomView: Bool { get set }

    /// Returns the maximum zoom factor for the current device. Useful if you are handling zooming manually.
    var maxZoomFactor: CGFloat { get set }

    /// Set this if you need to manage custom UIGestureRecognizerDelegate settings for tap-to-focus and pinch-zoom. This will only have an effect if `handlesTapFocus` or `handlesZoom` is true. Defaults to nil.
    var gestureDelegate: UIGestureRecognizerDelegate? { get set }

    /// Set this if you have an overlay with additional gesture recognizers that would conflict with SwiftttCamera's tap-to-focus gesture recognizer and pinch-to-zoom gesture recognizer. Defaults to SwiftttCamera's view.
    var gestureView: UIView? { get set }

    /// Set this to false if you want SwiftttCamera to return the full image captured by the camera instead of an image cropped to the view's aspect ratio. The image will be returned by the `cameraController(:didFinishCapturingImage:)` delegate method, in the `fullImage` property of the CapturedImage object `cameraController(:didFinishNormalizingCapturedImage:)` is the only other method that will be called, and only if normalizesImageOrientations == true. Defaults to true.
    var cropsImageToVisibleAspectRatio: Bool { get set }

    /// Set this to false if you don't want SwiftttCamera to return a scaled version of the full captured image. The scaled image will be returned in the `scaledImage` property of the CapturedImage object, and will trigger the `cameraController(:didFinishScalingCapturedImage:)` delegate method when it is available. Defaults to true.
    var scalesImage: Bool { get set }

    /// If you'd like to set an explicit max dimension for scaling the image, set it here. This can be useful if you have specific requirements for uploading the image. Defaults to scaling the cropped image to fit within the size of the camera preview.
    var maxScaledDimension: CGFloat? { get set }

    /// Set this to false if you would like to only use the images initially returned by SwiftttCamera and don't need the versions returned that have been rotated so that their orientation is `.up`.
    /// If true, normalized images will replace the initial images in the CapturedImage object when they have finished processing in the background, and the `cameraController(:didFinishNormalizingCapturedImage:)` delegate method will notify you that they are ready. Defaults to true.
    var normalizesImageOrientations: Bool { get set }

    /// Set this to false if you don't want to display the captured image preview to the user in the same orientation that it was captured, or if you are already rotating your interface to account for this. Defaults to true.
    var returnsRotatedPreview: Bool { get set }

    /// Set this to false if your interface does not autorotate with device orientation to make sure that preview images are still displayed correctly when orientation lock is off but your interface stays in portrait. Defaults to true.
    var interfaceRotatesWithOrientation: Bool { get set }

    /// Set this to `.landscapeLeft` or `.landscapeRight` if your interface does not autorotate with device orientation and sticks to a landscape interface, to make sure that preview images are still displayed correctly when orientation lock is off but your interface stays in landscape mode.
    /// Make sure to also set interfaceRotatesWithOrientation = true, otherwise this property will be ignored. Defaults to `.portrait`.
    var fixedInterfaceOrientation: UIDeviceOrientation { get set }

    // MARK: - Camera State

    /// The current camera device.
    var cameraDevice: CameraDevice { get set }

    /// The current flash mode.
    var cameraFlashMode: CameraFlashMode { get set }

    /// The current torch mode.
    var cameraTorchMode: CameraTorchMode { get set }

    /// Whether flash is available.
    ///
    /// Since iOS 10, when the `supportedFlashModes` API was introduced (deprecating `AVCaptureDevice.isFlashModeSupported`), the flash became available for all camera devices. The only case when the flash won't be available is when the device becomes too hot. However, in such cases, it's documented that the API will still tell us the flash is available, hence not being too helpful. For simplicity sake, this property will _always_ return true, and it exists mostly as a formality, or in case Apple decides to improve their API in the future.
    ///
    /// - Note: This property is _always_ true. See the discussion above for details.
    var isFlashAvailable: Bool { get }

    /// Whether torch is available for the current camera device.
    var isTorchAvailableForCurrentDevice: Bool { get }

    /// Checks if torch is available for the specified camera device.
    /// - Parameter cameraDevice: The camera device to check for torch availability.
    /// - Returns: Whether torch is available on the specified device.
    static func isTorchAvailable(forCameraDevice cameraDevice: CameraDevice) -> Bool

    /// Checks if point focus is available for the specified camera device.
    /// - Parameter cameraDevice: The camera device to check for point focus availability.
    /// - Returns: Whether point focus is available on the specified device.
    static func isPointFocusAvailable(forCameraDevice cameraDevice: CameraDevice) -> Bool

    /// Checks if the specified camera device is available on this device.
    /// - Parameter cameraDevice: The camera device to check for availability.
    /// - Returns: Whether the specified camera is available.
    static func isCameraDeviceAvailable(_ cameraDevice: CameraDevice) -> Bool

    /// Focuses the camera at the specified point, if focus at point is available on the current camera device. You only need to worry about this if you set `handlesTapFocus` to false, and want to manually control tap-to-focus.
    /// - Parameter touchPoint: The point at which to focus the camera, if point focus is available.
    /// - Returns: Whether the camera was able to focus. You can use this response to decide whether or not to show a custom UI indication that the camera is focusing.
    func focus(at touchPoint: CGPoint) -> Bool

    /// Zooms the camera to the specified scale, if zooming is available on the current camera device.
    /// You only need to worry about this if you set `handlesZoom` to false, and want to manually control pinch-to-zoom.
    /// - Parameter zoomScale: The scale to which to zoom the camera. The camera will not zoom past its maximum zoom scale.
    /// - Returns: Whether the camera was able to zoom. You can use this response to decide whether or not to show a custom UI indication that the camera is zooming.
    func zoom(to zoomScale: CGFloat) -> Bool

    // MARK: - Photo Capturing

    /// Whether the last photo has finished processing and it is ready to capture a new photo.
    var isReadyToCapturePhoto: Bool { get }

    /// Triggers the camera to take a photo.
    func takePicture()

    // MARK: - Photo Processing

    /// Crops the image to the given crop rect and scale the image to the given max dimension, and triggers the delegate callbacks with a `capturedImage` object (similarly to `takePicture()`).
    ///
    /// - Note: This will always trigger `cameraController(:didFinishCapturingImage:)` and `cameraController(:didFinishScalingCapturedImage:)`, and will trigger `cameraController(:didFinishNormalizingCapturedImage:)` if `normalizesImageOrientations` is set to true.
    ///
    /// - Parameters:
    ///   - image: The image to process.
    ///   - cropRect: The CGRect to use for cropping the image.
    ///   - maxDimension: The maximum dimension of the target size for aspect scaling the image.
    func process(image: UIImage, withCropRect cropRect: CGRect?, withMaxDimension maxDimension: CGFloat?)

    /// Cancels the in-process image capture and processing to free up memory and make the camera ready to capture a new photo.
    func cancelImageProcessing()

    // MARK: - Manage Capture Session

    /// Starts the capture session if it is currently paused.
    /// - Note: This is managed internally by SwiftttCamera. Advanced use cases can trigger it manually using this method.
    func startRunning()

    /// Pauses the capture session if it is currently running.
    /// - Note: This is managed internally by SwiftttCamera. Advanced use cases can trigger it manually using this method.
    func stopRunning()
}

public extension CameraProtocol {
    var isFlashAvailable: Bool {
        return true
    }
}
