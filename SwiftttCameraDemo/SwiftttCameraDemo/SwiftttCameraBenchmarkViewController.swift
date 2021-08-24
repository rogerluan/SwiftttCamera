// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit
import SwiftttCamera

final class SwiftttCameraBenchmarkViewController : UIViewController {
    private var counter: Int = 0
    private var cropCounter: Int = 0
    private var scaleCounter: Int = 0
    private var renderCounter: Int = 0
    private var normalizeCounter: Int = 0
    private var startTime: TimeInterval = 0
    private var totalCropPhotoTime: TimeInterval = 0
    private var totalScalePhotoTime: TimeInterval = 0
    private var totalTimeToRender: TimeInterval = 0
    private var totalTimeToNormalize: TimeInterval = 0

    // MARK: - Content
    private lazy var camera: SwiftttCamera = {
        let result = SwiftttCamera()
        result.view.translatesAutoresizingMaskIntoConstraints = false
        result.delegate = self
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
        title = NSLocalizedString("SwiftttCamera Benchmark", comment: "")
        tabBarItem.image = #imageLiteral(resourceName: "bolt")
        view.backgroundColor = .systemBackground
        camera.willMove(toParent: self)
        camera.beginAppearanceTransition(true, animated: false)
        self.addChild(camera)
        view.addSubview(camera.view)
        camera.didMove(toParent: self)
        camera.endAppearanceTransition()
        view.addSubview(imageView)
        view.addSubview(runTestButton)
        view.addSubview(averageTimeLabel)
        NSLayoutConstraint.activate([
            // Camera view
            camera.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            camera.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            camera.view.topAnchor.constraint(equalTo: view.topAnchor),
            camera.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
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
        counter = 0
        cropCounter = 0
        scaleCounter = 0
        renderCounter = 0
        normalizeCounter = 0
        totalCropPhotoTime = 0
        totalScalePhotoTime = 0
        totalTimeToRender = 0
        totalTimeToNormalize = 0
        startBenchmarkIteration()
    }

    private func startBenchmarkIteration() {
        Thread.sleep(forTimeInterval: 0.1)
        counter += 1
        startTime = CACurrentMediaTime()
        camera.takePicture()
    }

    private func cropPhotoBenchmarkIteration() {
        cropCounter += 1
        totalCropPhotoTime += CACurrentMediaTime() - startTime
    }

    private func renderPhotoBenchmarkIteration() {
        renderCounter += 1
        totalTimeToRender += CACurrentMediaTime() - startTime
    }

    private func scalePhotoBenchmarkIteration() {
        scaleCounter += 1
        totalScalePhotoTime += CACurrentMediaTime() - startTime
    }

    private func normalizePhotoBenchmarkIteration() {
        normalizeCounter += 1
        totalTimeToNormalize += CACurrentMediaTime() - startTime
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
        let averageCropPhotoTime: Double = totalCropPhotoTime / Double(cropCounter)
        print("Average Run Time for SwiftttCamera Crop Photo: \(averageCropPhotoTime)")
        let averageRenderPhotoTime: Double = totalTimeToRender / Double(renderCounter)
        print("Average Run Time for SwiftttCamera Render Photo: \(averageRenderPhotoTime)")
        let averageScalePhotoTime: Double = totalScalePhotoTime / Double(scaleCounter)
        print("Average Run Time for SwiftttCamera Scale Photo: \(averageScalePhotoTime)")
        let averageNormalizePhotoTime: Double = totalTimeToNormalize / Double(normalizeCounter)
        print("Average Run Time for SwiftttCamera Normalize Photo: \(averageNormalizePhotoTime)")
        averageTimeLabel.text = String(format: NSLocalizedString("Average Time: %.6f", comment: ""), averageNormalizePhotoTime)
    }
}

extension SwiftttCameraBenchmarkViewController : CameraDelegate {
    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImage capturedImage: CapturedImage) {
        cropPhotoBenchmarkIteration()
        imageView.image = capturedImage.rotatedPreviewImage
        // Forces the image view to render now so we can see the delay
        imageView.setNeedsDisplay()
        CATransaction.flush()
        renderPhotoBenchmarkIteration()
        capturedImage.rotatedPreviewImage = nil
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishScalingCapturedImage capturedImage: CapturedImage) {
        scalePhotoBenchmarkIteration()
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishNormalizingCapturedImage capturedImage: CapturedImage) {
        normalizePhotoBenchmarkIteration()
        endBenchmarkIteration()
    }
}
