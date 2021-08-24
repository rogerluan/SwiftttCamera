// Copyright © 2021 Roger Oba. All rights reserved.

import AVFoundation
import UIKit

internal extension UIImage {
    /// Calculates a crop rect for the image fitting into the preview bounds with aspect fill.
    /// - Parameter previewBounds: The bounds of the view displaying the camera preview.
    /// - Returns: The CGRect to use for cropping the camera's captured image to match the camera preview.
    func cropRect(fromPreviewBounds previewBounds: CGRect) -> CGRect {
        let imageRatio: CGFloat = size.width / size.height
        let viewRatio: CGFloat = previewBounds.size.width / previewBounds.size.height
        if imageRatio > viewRatio {
            let width: CGFloat = viewRatio * size.height
            let height: CGFloat = size.height
            let originX: CGFloat = (size.width - width) / 2
            let originY: CGFloat = .zero
            return CGRect(x: originX, y: originY, width: width, height: height)
        } else {
            let width: CGFloat = size.width
            let height: CGFloat = size.width / viewRatio
            let originX: CGFloat = .zero
            let originY: CGFloat = (size.height - height) / 2
            return CGRect(x: originX, y: originY, width: width, height: height)
        }
    }

    /// Calculates a crop rect for cropping the captured image to the visible area of the preview layer.
    /// - Parameter previewLayer: The preview layer of the camera's live preview.
    /// - Returns: The CGRect to use for cropping the camera's captured image to match the camera preview.
    func cropRect(fromPreviewLayer previewLayer: AVCaptureVideoPreviewLayer) -> CGRect {
        let outputRect = previewLayer.metadataOutputRectConverted(fromLayerRect: previewLayer.bounds)
        return cropRect(fromOutputRect: outputRect)
    }

    /// Converts the 0-to-1-scaled output rect to a crop rect for this image.
    /// - Parameter outputRect: The 0-to-1-scaled output rect to convert
    /// - Returns: The CGRect to use to crop this image
    func cropRect(fromOutputRect outputRect: CGRect) -> CGRect {
        guard let cgImage = cgImage else { preconditionFailure(".cgImage is nil") }
        let originX: CGFloat = round(outputRect.minX * CGFloat(cgImage.width))
        let originY: CGFloat = round(outputRect.minY * CGFloat(cgImage.height))
        let width: CGFloat = round(outputRect.width * CGFloat(cgImage.width))
        let height: CGFloat = round(outputRect.height * CGFloat(cgImage.height))
        return CGRect(x: originX, y: originY, width: width, height: height)
    }

    /// Crops the image to the given output CGRect, which has its origin and dimensions scaled from 0 to 1, to match the output of AVFoundation's metadataOutputRectOfInterestForRect.
    /// - Parameter outputRect: The 0-to-1-scaled CGRect to use for cropping the image.
    /// - Returns: The cropped image.
    func croppedImage(fromOutputRect outputRect: CGRect) -> UIImage {
        let cropRect: CGRect = cropRect(fromOutputRect: outputRect)
        return croppedImage(fromCropRect: cropRect)
    }

    /// Crops the image to the given CGRect origin, width, and height.
    /// - Parameter cropRect: The CGRect to use for cropping the image.
    /// - Returns: The cropped image.
    func croppedImage(fromCropRect cropRect: CGRect) -> UIImage {
        guard let cgImage = cgImage else { preconditionFailure(".cgImage is nil") }
        guard let croppedCGImage = cgImage.cropping(to: cropRect) else { preconditionFailure("Cropped CGImage is nil") }
        return UIImage(cgImage: croppedCGImage, scale: scale, orientation: imageOrientation)
    }

    /// Scales the image to the given size.
    /// - Parameter size: The destination size of the image. Assumes that this size and the image have the same aspect ratio.
    /// - Returns: The scaled image.
    func scaledImage(ofSize size: CGSize) -> UIImage? {
        guard let cgImage = cgImage else { preconditionFailure(".cgImage is nil") }
        let newScale: CGFloat = min(size.width, size.height) / min(CGFloat(cgImage.width), CGFloat(cgImage.height))
        return scaledImage(withScale: newScale)
    }

    /// Scales the image to the given maximum dimension.
    /// - Parameter maxDimension: The destination maximum dimension of the image.
    /// - Returns: The scaled image.
    func scaledImage(withMaxDimension maxDimension: CGFloat) -> UIImage? {
        guard let cgImage = cgImage else { preconditionFailure(".cgImage is nil") }
        let newScale: CGFloat = maxDimension / max(CGFloat(cgImage.width), CGFloat(cgImage.height))
        return scaledImage(withScale: newScale)
    }

    /// Scales the image to the given scale.
    /// - Parameter newScale: The scale for the image.
    /// - Returns: The scaled image.
    func scaledImage(withScale newScale: CGFloat) -> UIImage? {
        guard let cgImage = cgImage else { preconditionFailure(".cgImage is nil") }
        let scale: CGFloat = UIScreen.main.scale
        let width: CGFloat = round(CGFloat(cgImage.width) * newScale * scale)
        let height: CGFloat = round(CGFloat(cgImage.height) * newScale * scale)
        let newRect: CGRect = CGRect(origin: .zero, size: CGSize(width: width, height: height))
        let bitsPerComponent: Int = cgImage.bitsPerComponent
        let colorSpace: CGColorSpace = cgImage.colorSpace!
        let bitmapInfo: CGBitmapInfo = cgImage.bitmapInfo
        guard let context = CGContext(data: nil, width: Int(newRect.width), height: Int(newRect.height), bitsPerComponent: bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue) else { return nil }
        context.interpolationQuality = .high
        context.draw(cgImage, in: newRect)
        guard let scaledCGImage: CGImage = context.makeImage() else { return nil }
        return UIImage(cgImage: scaledCGImage, scale: scale, orientation: imageOrientation)
    }

    /// Normalizes the orientation of the image, redrawing it so that its orientation is `.up`.
    /// - Returns: A new image drawn so that the orientation is `.up`.
    func normalizingOrientation() -> UIImage {
        guard imageOrientation != .up else { return self }
        let newRect: CGRect = CGRect(origin: .zero, size: CGSize(width: round(size.width), height: round(size.height)))
        UIGraphicsBeginImageContextWithOptions(newRect.size, true, scale)
        draw(in: newRect)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result ?? self
    }

    /// Sets the image orientation so that the image displays in the same orientation as the camera preview when the image was taken. So, if the device was held landscape left, the image returned will be set to display so that landscape left is "up". This is great if your interface doesn't rotate, or if the photo was taken with orientation lock on.
    /// - Parameter deviceOrientation: The orientation of the preview view.
    /// - Returns: The image that has been rotated to match the camera preview.
    func rotatedImageMatchingCameraView(withOrientation deviceOrientation: UIDeviceOrientation) -> UIImage {
        let isMirrored: Bool = {
            switch imageOrientation {
            case .rightMirrored, .leftMirrored, .upMirrored, .downMirrored: return true
            default: return false
            }
        }()
        func previewImageOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation, isMirrored: Bool) -> UIImage.Orientation {
            switch deviceOrientation {
            case .landscapeLeft: return isMirrored ? .upMirrored : .up
            case .landscapeRight: return isMirrored ? .downMirrored : .down
            default: return isMirrored ? .leftMirrored : .right
            }
        }
        let orientation: UIImage.Orientation = previewImageOrientation(forDeviceOrientation: deviceOrientation, isMirrored: isMirrored)
        return rotatedImage(matchingOrientation: orientation)
    }

    /// Moves the image orientation tag of the image to the given image orientation. The pixels of the image stay as-is.
    /// - Parameter orientation: The image orientation tag to set.
    /// - Returns: The image that has had its new orientation tag set.
    func rotatedImage(matchingOrientation orientation: UIImage.Orientation) -> UIImage {
        guard imageOrientation != orientation else { return self }
        guard let cgImage = cgImage else { return self }
        return UIImage(cgImage: cgImage, scale: scale, orientation: orientation)
    }

    /// Creates a fake image for testing.
    /// - Returns: The fake image.
    static func fakeTestImage() -> UIImage {
        let size = CGSize(width: 2000, height: 1500)
        UIGraphicsBeginImageContextWithOptions(size, true, 0)
        UIColor.systemGreen.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result!
    }
}
