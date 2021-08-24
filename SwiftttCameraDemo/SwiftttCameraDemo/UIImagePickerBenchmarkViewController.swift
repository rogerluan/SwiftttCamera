// Copyright © 2021 Roger Oba. All rights reserved.

import Accelerate
import AVFoundation
import UIKit

final class UIImagePickerBenchmarkViewController : UIViewController {
    private var counter: Int = 0
    private var startTime: TimeInterval = 0
    private var totalTakePhotoTime: TimeInterval = 0
    private var totalCropPhotoTime: TimeInterval = 0
    private var totalScalePhotoTime: TimeInterval = 0
    private var totalTimeToRender: TimeInterval = 0

    // MARK: - Content
    private lazy var imagePickerController: UIImagePickerController = {
        let result = UIImagePickerController()
        result.delegate = self
        result.sourceType = .camera
        result.showsCameraControls = false
        result.allowsEditing = false
        result.cameraCaptureMode = .photo
        result.cameraFlashMode = .off
        result.cameraDevice = .rear
        let screenBounds: CGSize = UIScreen.main.bounds.size
        let previewHeight: CGFloat = screenBounds.height
        let previewScale: CGFloat = screenBounds.height / previewHeight
        var transform: CGAffineTransform = CGAffineTransform(translationX: 0, y: UIScreen.main.bounds.height / 5)
        transform = transform.scaledBy(x: previewScale, y: previewScale)
        result.cameraViewTransform = transform
        return result
    }()

    private lazy var imageView: UIImageView = {
        let result = UIImageView()
        result.contentMode = .scaleAspectFill
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var runTestButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Run Test", comment: ""), for: .normal)
        result.addAction(UIAction(handler: { [unowned self] _ in self.runBenchmark() }), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var averageTimeLabel: UILabel = {
        let result = UILabel()
        result.textColor = .white
        result.text = NSLocalizedString("Average Time: ", comment: "")
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("UIImagePicker Benchmark", comment: "")
        tabBarItem.image = #imageLiteral(resourceName: "bar-chart")
        view.backgroundColor = .systemBackground
        imagePickerController.willMove(toParent: self)
        imagePickerController.beginAppearanceTransition(true, animated: false)
        addChild(imagePickerController)
        view.addSubview(imagePickerController.view)
        imagePickerController.didMove(toParent: self)
        imagePickerController.endAppearanceTransition()
        view.addSubview(imageView)
        view.addSubview(runTestButton)
        view.addSubview(averageTimeLabel)
        NSLayoutConstraint.activate([
            // Camera view
            imagePickerController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imagePickerController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imagePickerController.view.topAnchor.constraint(equalTo: view.topAnchor),
            imagePickerController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            // Image view
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Run test button
            runTestButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            runTestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            // Average time label
            averageTimeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            averageTimeLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        ])
    }

    // MARK: - Benchmark
    private func runBenchmark() {
        print("Will run test")
        averageTimeLabel.text = NSLocalizedString("Running...", comment: "")
        counter = 0
        totalTakePhotoTime = 0
        totalCropPhotoTime = 0
        totalScalePhotoTime = 0
        totalTimeToRender = 0
        startBenchmarkIteration()
    }

    private func startBenchmarkIteration() {
        Thread.sleep(forTimeInterval: 0.1)
        counter += 1
        startTime = CACurrentMediaTime()
        imagePickerController.takePicture()
    }

    private func takePhotoBenchmarkIteration() {
        totalTakePhotoTime += CACurrentMediaTime() - startTime
    }

    private func cropPhotoBenchmarkIteration() {
        totalCropPhotoTime += CACurrentMediaTime() - startTime
    }

    private func scalePhotoBenchmarkIteration() {
        totalScalePhotoTime += CACurrentMediaTime() - startTime
    }

    private func renderPhotoBenchmarkIteration() {
        totalTimeToRender += CACurrentMediaTime() - startTime
    }

    private func endBenchmarkIteration() {
        print("Run \(counter)")
        if counter < BenchmarkParameters.numberOfIterations {
            startBenchmarkIteration()
        } else {
            finishBenchmark()
        }
    }

    private func finishBenchmark() {
        let averageTakePhotoTime: Double = totalTakePhotoTime / Double(BenchmarkParameters.numberOfIterations)
        print("Average Run Time for UIImagePickerController Take Photo: \(averageTakePhotoTime)")
        let averageCropPhotoTime: Double = totalCropPhotoTime / Double(BenchmarkParameters.numberOfIterations)
        print("Average Run Time for UIImagePickerController Crop Photo: \(averageCropPhotoTime)")
        let averageRenderPhotoTime: Double = totalTimeToRender / Double(BenchmarkParameters.numberOfIterations)
        print("Average Run Time for UIImagePickerController Render Photo: \(averageRenderPhotoTime)")
        let averageScalePhotoTime: Double = totalScalePhotoTime / Double(BenchmarkParameters.numberOfIterations)
        print("Average Run Time for UIImagePickerController Scale Photo: \(averageScalePhotoTime)")
        averageTimeLabel.text = String(format: NSLocalizedString("Average Time: %.6f", comment: ""), averageScalePhotoTime)
    }
}

extension UIImagePickerBenchmarkViewController : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        takePhotoBenchmarkIteration()
        let image: UIImage = info[.originalImage] as! UIImage
        let cgImage: CGImage = image.cgImage!
        var previewImage: UIImage? = UIImage(cgImage: cgImage, scale: image.scale, orientation: .right)
        imageView.image = previewImage
        // Forces the image view to render now so we can see the delay
        imageView.setNeedsDisplay()
        CATransaction.flush()
        renderPhotoBenchmarkIteration()
        previewImage = nil
        let tempCroppedImage: UIImage = UIImage(byCropping: image)
        let croppedImage: UIImage = UIImage(cgImage: tempCroppedImage.cgImage!, scale: tempCroppedImage.scale, orientation: .upMirrored)
        cropPhotoBenchmarkIteration()
        // Scale image to screen size
        var screenSize: CGSize = UIScreen.main.bounds.size
        if croppedImage.size.width > croppedImage.size.height, screenSize.width < screenSize.height {
            // Screen size is in portrait while image is in landscape, so we flip the aspect ratio
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }
        // Unused because we're just benchmarking the process, not actually using the resulting scaled image.
        let _ = croppedImage.scale(toFillSize: CGSize(width: screenSize.width * UIScreen.main.scale, height: screenSize.height * UIScreen.main.scale))
        scalePhotoBenchmarkIteration()
        endBenchmarkIteration()
    }
}

// MARK: - Utilities
extension UIImage {
    convenience init(byCropping image: UIImage) {
        let rotatedImage: UIImage = image.rotate(inDegrees: image.imageOrientation.degrees)!
        let fixedImage: UIImage = UIImage(cgImage: rotatedImage.cgImage!, scale: rotatedImage.scale, orientation: .up)
        var screenSize: CGSize = UIScreen.main.bounds.size
        if fixedImage.size.width > fixedImage.size.height, screenSize.width < screenSize.height {
            // Screen size is in portrait while image is in landscape, so we flip the aspect ratio
            screenSize = CGSize(width: screenSize.height, height: screenSize.width)
        }
        let cropRect: CGRect = AVMakeRect(aspectRatio: screenSize, insideRect: CGRect(x: 0, y: 0, width: fixedImage.size.width, height: fixedImage.size.height)).integral
        // Crop the captured image to an aspect ratio matching the physical screen size
        self.init(byCropping: rotatedImage, to: cropRect)
    }

    convenience init(byCropping image: UIImage, to rect: CGRect) {
        let scale: CGFloat = image.scale
        let cropRect: CGRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        let cgImage: CGImage = image.cgImage!.cropping(to: cropRect)!
        self.init(cgImage: cgImage)
    }

    func scale(toFillSize newSize: CGSize) -> UIImage? {
        let (newWidth, newHeight): (CGFloat, CGFloat) = {
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                return (newSize.height * scale, newSize.width * scale)
            default:
                return (newSize.width * scale, newSize.height * scale)
            }
        }()
        // Create an ARGB bitmap context
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: Int(newWidth), height: Int(newHeight), bitsPerComponent: 8, bytesPerRow: Int(newWidth * 4), space: colorSpace, bitmapInfo: CGImageByteOrderInfo.orderDefault.rawValue |  CGImageAlphaInfo.noneSkipFirst.rawValue) else { return nil }
        // Image quality
        context.setShouldAntialias(true)
        context.setAllowsAntialiasing(true)
        context.interpolationQuality = .high
        // Draw the image in the bitmap context
        UIGraphicsPushContext(context)
        context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: newWidth, height: newHeight))
        UIGraphicsPopContext()
        // Create an image object from the context
        let scaledCGImage: CGImage = context.makeImage()!
        return UIImage(cgImage: scaledCGImage, scale: scale, orientation: imageOrientation)
    }

    func rotate(inDegrees degrees: Float) -> UIImage? {
        return rotate(byPixelsInRadians: degrees * 0.017453293)
    }

    func rotate(byPixelsInRadians radians: Float) -> UIImage? {
        // Create an ARGB bitmap context
        let width: CGFloat = size.width * scale
        let height: CGFloat = size.height * scale
        let bytesPerRow: Int = Int(width) * 4
        let colorspace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorspace, bitmapInfo: CGImageByteOrderInfo.orderDefault.rawValue |  CGImageAlphaInfo.premultipliedFirst.rawValue) else { return nil }
        // Draw the image in the bitmap context
        context.draw(cgImage!, in: CGRect(x: 0.0, y: 0.0, width: width, height: height))
        // Grab the image raw data
        guard let data = context.data else { return nil }
        var source: vImage_Buffer = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
        var destination: vImage_Buffer = vImage_Buffer(data: data, height: vImagePixelCount(height), width: vImagePixelCount(width), rowBytes: bytesPerRow)
        var backgroundColor: Pixel_8 = 0
        vImageRotate_ARGB8888(&source, &destination, nil, radians, &backgroundColor, vImage_Flags(kvImageBackgroundColorFill))
        let rotatedCGImage: CGImage = context.makeImage()!
        let rotatedUIImage: UIImage = UIImage(cgImage: rotatedCGImage, scale: scale, orientation: imageOrientation)
        return rotatedUIImage
    }
}

extension UIImage.Orientation {
    var degrees: Float {
        // iOS treats "Up" as the up if the phone were landscape left.
        // So, the right side of the screen is "up" when a photo is taken.
        // Here, we correct that to the actual direction that should be "up".
        switch self {
        case .up: return 0 // Image captured in landscape left
        case .down: return 180 // Image captured in landscape right
        case .left: return -90 // Image captured in portrait upside down
        case .right: return 90 // Image captured in portrait
        default: return 0
        }
    }
}
