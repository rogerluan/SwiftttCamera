// Copyright © 2021 Roger Oba. All rights reserved.

import Foundation
@objc
public protocol CameraDelegate : AnyObject {
    /// Called when the camera controller has obtained the raw data containing the image and metadata.
    /// - Parameters:
    ///   - cameraController: The FastttCamera instance that captured a photo.
    ///   - rawJPEGData: The plain, raw data from the camera, ready to be written to a file if desired.
    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImageData rawJPEGData: Data)

    /// Called when the camera controller has finished capturing a photo.
    ///
    /// - Note: if you set returnsRotatedPreview = false, there will be no `previewImage` here, and if you set cropsImageToVisibleAspectRatio = false, the `fullImage` will be the raw image captured by the camera, while by default the `fullImage` will have been cropped to the visible camera preview's aspect ratio.
    ///
    /// - Parameters:
    ///   - cameraController: The CameraProtocol instance that captured a photo.
    ///   - capturedImage: The CapturedImage object, containing a full-resolution `fullImage` that has not yet had its orientation normalized (it has not yet been rotated so that its orientation is `.up`), and a `previewImage` that has its image orientation set so that it is rotated to match the camera preview's orientation as it was captured, so if the device was held landscape left, the image returned will be set to display so that landscape left is "up". This is great if your interface doesn't rotate, or if the photo was taken with orientation lock on.
    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImage capturedImage: CapturedImage)

    /// Called when the camera controller has finished scaling the captured photo.
    ///
    /// - Note: This method will not be called if `scalesImage` is set to false.
    ///
    /// - Parameters:
    ///   - cameraController: The CameraProtocol instance that captured a photo.
    ///   - capturedImage: The CapturedImage object, which now also contains a scaled `scaledImage`, that has not yet had its orientation normalized. The image by default is scaled to fit within the camera's preview window, but you can set a custom `maxScaledDimension`.
    func cameraController(_ cameraController: CameraProtocol, didFinishScalingCapturedImage capturedImage: CapturedImage)

    /// Called when the camera controller has finished normalizing the captured photo.
    ///
    /// - Note: This method will not be called if `normalizesImageOrientations` is set to false.
    ///
    /// - Parameters:
    ///   - cameraController: The CameraProtocol instance that captured a photo.
    ///   - capturedImage: The CapturedImage object, with the `fullImage` and `scaledImage` (if any) replaced by images that have been rotated so that their orientation is `.up`. This is a slower process than creating the initial images that are returned, which have varying orientations based on how the phone was held, but the normalized images are more ideal for uploading or saving as they are displayed more predictably in different browsers and applications than the initial images which have an orientation tag set that is not `.up`.
    func cameraController(_ cameraController: CameraProtocol, didFinishNormalizingCapturedImage capturedImage: CapturedImage)

    /// Called when the camera controller asks for permission to access the user's camera and is denied.
    ///
    /// Use this optional method to handle gracefully the case where the user has denied camera access, either disabling the camera if not necessary or redirecting the user to your app's Settings page where they can enable the camera permissions. Remember that iOS will only show the user an alert requesting permission in-app one time. If the user denies permission, they must change this setting in the app's permissions page within the Settings App. This method will be called every time the app launches or becomes active and finds that permission to access the camera has not been granted.
    ///
    /// - Parameter cameraController: The CameraProtocol instance that captured a photo.
    func userDeniedCameraPermissions(forCameraController cameraController: CameraProtocol)
}

public extension CameraDelegate {
    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImageData rawJPEGData: Data) {
        // Optional protocol function
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImage capturedImage: CapturedImage) {
        // Optional protocol function
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishScalingCapturedImage capturedImage: CapturedImage) {
        // Optional protocol function
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishNormalizingCapturedImage capturedImage: CapturedImage) {
        // Optional protocol function
    }

    func userDeniedCameraPermissions(forCameraController cameraController: CameraProtocol) {
        // Optional protocol function
    }
}
