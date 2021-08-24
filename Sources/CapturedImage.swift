// Copyright © 2021 Roger Oba. All rights reserved.

import Combine
import UIKit

/// Hold a captured image object, used in CameraDelegate promises as the image is being cropped, scaled, and normalized.
public final class CapturedImage {
    private lazy var serialQueue = DispatchQueue(label: String(describing: self), qos: .userInitiated)


    /// Customizable object for you to use to hold any data specific to your app.
    public var userInfo: Any?

    /// The full-resolution cropped image that was captured by the camera.
    public var fullImage: UIImage

    /// The captured image scaled to the size of the camera preview viewport.
    public var scaledImage: UIImage?

    /// The scaled image rotated to match the camera preview. The image's orientation has been set so that it image displays in the same orientation as the camera preview when the image was taken. So, if the device was held landscape left, the image returned will be set to display so that landscape left is "up". This is great if your interface doesn't rotate, or if the photo was taken with orientation lock on.
    public var rotatedPreviewImage: UIImage?

    /// Whether the images have finished being redrawn so that their orientations are UIImageOrientationUp.
    /// This is a slower process than the initial images that are returned which have varying orientations, but they are more ideal for uploading or saving as they are displayed more predictably in different browsers and applications than rotated images with an orientation tag set that is not UIImageOrientationUp.
    public var isNormalized: Bool = false

    /// The orientation that the image was captured with, useful if you are doing additional image editing using the rotated preview image.
    public var capturedImageOrientation: UIImage.Orientation?

    /// Initialize a CapturedImage object.
    /// - Parameter fullImage: The full-resolution cropped image that was captured by the camera.
    public init(fullImage: UIImage) {
        self.fullImage = fullImage
    }

    /// Processes the captured image by cropping and returning a rotated preview as necessary.
    /// - Parameters:
    ///   - cropRect: The CGRect to use for cropping. Pass `nil` for no cropping.
    ///   - returnsPreview: Whether the CapturedImage should set its `rotatedPreviewImage` property.
    ///   - needsPreviewRotation: Whether the image needs its `imageOrientation` tag changed for displaying a preview.
    ///   - previewOrientation: The orientation to use for the preview view (usually `.portrait`)
    /// - Returns: A Future that resolves when the image cropping and preview completes and the CapturedImage `fullImage` and `rotatedPreviewImage` properties have been set as needed.
    internal func crop(to cropRect: CGRect?, returnsPreview: Bool, needsPreviewRotation: Bool, withPreviewOrientation previewOrientation: UIDeviceOrientation) -> Future<CapturedImage, Never> {
        return Future<CapturedImage, Never> { promise in
            self.serialQueue.async {
                if let cropRect = cropRect, cropRect != .zero {
                    self.fullImage = self.fullImage.croppedImage(fromCropRect: cropRect)
                }
                self.capturedImageOrientation = self.fullImage.imageOrientation
                if returnsPreview {
                    self.rotatedPreviewImage = {
                        if needsPreviewRotation {
                            return self.fullImage.rotatedImageMatchingCameraView(withOrientation: previewOrientation)
                        } else {
                            return self.fullImage
                        }
                    }()
                }
                promise(.success(self))
            }
        }
    }

    /// Processes the captured image by scaling to the given maximum dimension.
    /// - Parameter maxDimension: The maximum dimension to use for scaling the image.
    /// - Returns: A Future that resolves when the image scaling completes and the CapturedImage `scaledImage` property has been set.
    internal func scale(to maxDimension: CGFloat) -> Future<CapturedImage, Never> {
        return Future { promise in
            self.serialQueue.async {
                self.scaledImage = self.fullImage.scaledImage(withMaxDimension: maxDimension)
                promise(.success(self))
            }
        }
    }

    /// Processes the captured image by scaling to the given size.
    /// - Parameter size: The output size to use for scaling the image. Assumes that this size and the image have the same aspect ratio.
    /// - Returns: A Future that resolves when the image scaling completes and the CapturedImage `scaledImage` property has been set.
    internal func scale(to size: CGSize) -> Future<CapturedImage, Never> {
        return Future { promise in
            self.serialQueue.async {
                self.scaledImage = self.fullImage.scaledImage(ofSize: size)
                promise(.success(self))
            }
        }
    }

    /// Processes the captured image by normalizing the `fullImage` and `scaledImage` to have `UIImage.Orientation.up`.
    /// - Returns: A Future that resolves when the image normalization completes and the CapturedImage `scaledImage`, `fullImage`, and `isNormalized` properties have been set appropriately.
    internal func normalize() -> Future<CapturedImage, Never> {
        return Future { promise in
            self.serialQueue.async {
                self.fullImage = self.fullImage.normalizingOrientation()
                self.scaledImage = self.scaledImage?.normalizingOrientation()
                self.isNormalized = true
                promise(.success(self))
            }
        }
    }
}
