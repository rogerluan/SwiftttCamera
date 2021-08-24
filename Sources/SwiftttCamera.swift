// Copyright © 2021 Roger Oba. All rights reserved.

import AVFoundation
import Combine
import UIKit

/// Use to create a standard SwiftttCamera.
/// - Note: The full interface for the SwiftttCamera can be found in CameraProtocol.
public class SwiftttCamera : UIViewController, CameraProtocol {
    private var deviceOrientation: DeviceOrientation!
    private var focus: Focus!
    private var zoom: Zoom!
    private var session: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var photoOutput: AVCapturePhotoOutput!
    private var deviceAuthorized: Bool = false
    private var isCapturingImage: Bool = false
    private var photoCaptureNeedsPreviewRotation: Bool = false
    private var photoCapturePreviewOrientation: UIDeviceOrientation = .portrait
    private var cancellables = Set<AnyCancellable>()

    public weak var delegate: CameraDelegate?
    public weak var gestureDelegate: UIGestureRecognizerDelegate?
    public var handlesTapFocus: Bool = true
    public var showsFocusView: Bool = true
    public var handlesZoom: Bool = true
    public var showsZoomView: Bool = true
    public var cropsImageToVisibleAspectRatio: Bool = true
    public var scalesImage: Bool = true
    public var maxScaledDimension: CGFloat?
    public var maxZoomFactor: CGFloat = 1
    public var normalizesImageOrientations: Bool = true
    public var returnsRotatedPreview: Bool = true
    public var interfaceRotatesWithOrientation: Bool = true
    public var fixedInterfaceOrientation: UIDeviceOrientation = .portrait
    public var cameraDevice: CameraDevice = .rear { didSet { handleCameraDeviceChanged(oldValue: oldValue, newValue: cameraDevice) } }
    public var cameraFlashMode: CameraFlashMode = .off
    public var cameraTorchMode: CameraTorchMode = .off { didSet { handleCameraTorchModeChanged() } }
    public var gestureView: UIView?

    // MARK: - Initializationo
    public init() {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }

    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        setUpCaptureSession()
        setUpObservers()
    }

    deinit {
        focus = nil
        zoom = nil
        teardownCaptureSession()
        teardownObservers()
    }

    private func setUpObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActive), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }


    private func teardownObservers() {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: Lifecycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        insertPreviewLayer()
        let viewForGestures: UIView = gestureView ?? view
        focus = Focus(view: viewForGestures, gestureDelegate: gestureDelegate)
        focus.delegate = self
        focus.detectsTaps = handlesTapFocus
        zoom = Zoom(view: viewForGestures, gestureDelegate: gestureDelegate)
        zoom.delegate = self
        zoom.detectsPinch = handlesZoom
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startRunning()
        insertPreviewLayer()
        setPreviewVideoOrientation()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopRunning()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .all
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        setPreviewVideoOrientation()
    }
}

// MARK: - Capture Session Management
extension SwiftttCamera {
    public func startRunning() {
        session?.startRunningIfNeeded()
    }

    public func stopRunning() {
        session?.stopRunningIfNeeded()
    }

    private func setUpCaptureSession() {
        guard session == nil else { return }
        #if targetEnvironment(simulator)
        deviceAuthorized = true
        handleDeviceAuthorization(deviceAuthorized)
        #else
        checkDeviceAuthorization()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] authorized in
                guard let self = self else { return }
                self.deviceAuthorized = authorized
                self.handleDeviceAuthorization(authorized)
            }
            .store(in: &cancellables)
        #endif
    }

    private func handleDeviceAuthorization(_ authorized: Bool) {
        if authorized {
            session = AVCaptureSession()
            session.setSessionPresetIfPossible(.photo)
            let device: AVCaptureDevice? = AVCaptureDevice.captureDevice(from: cameraDevice) ?? AVCaptureDevice.default(for: .video) // It's nil only in Simulator
            do {
                try device?.lockForConfiguration()
                device?.setFocusModeIfSupported(.continuousAutoFocus)
                device?.setExposureModeIfSupported(.continuousAutoExposure)
                device?.unlockForConfiguration()
                #if !targetEnvironment(simulator)
                let deviceInput: AVCaptureDeviceInput = try  AVCaptureDeviceInput(device: device!)
                session.addInputIfPossible(deviceInput)
                switch device!.position {
                case .back: cameraDevice = .rear
                case .front: cameraDevice = .front
                default: break
                }
                #endif
                photoOutput = AVCapturePhotoOutput()
                session.addOutputIfPossible(photoOutput)
                deviceOrientation = DeviceOrientation()
                if isViewLoaded && view.window != nil {
                    startRunning()
                    insertPreviewLayer()
                    setPreviewVideoOrientation()
                    resetZoom()
                }
            } catch {
                dump(error)
            }
        } else {
            delegate?.userDeniedCameraPermissions(forCameraController: self)
        }
    }

    private func teardownCaptureSession() {
        guard session != nil else { return }
        deviceOrientation = nil
        session.stopRunningIfNeeded()
        for input in session.inputs {
            session.removeInput(input)
        }
        session.removeOutput(photoOutput)
        photoOutput = nil
        removePreviewLayer()
        session = nil
    }

    private func insertPreviewLayer() {
        guard deviceAuthorized, session != nil else { return }
        if previewLayer?.superlayer === view.layer && previewLayer?.session === session {
            return
        }
        removePreviewLayer()
        let rootLayer: CALayer = view.layer
        rootLayer.masksToBounds = true
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.frame = rootLayer.bounds
        rootLayer.insertSublayer(previewLayer, at: 0)
    }

    private func removePreviewLayer() {
        previewLayer?.removeFromSuperlayer()
        previewLayer = nil
    }
}

// MARK: - Camera State
extension SwiftttCamera {
    public var isTorchAvailableForCurrentDevice: Bool {
        guard let device = currentCameraDevice() else { return false }
        return device.isTorchModeSupported(.on)
    }

    public static func isTorchAvailable(forCameraDevice cameraDevice:   CameraDevice) -> Bool {
        return AVCaptureDevice.isTorchAvailable(for: cameraDevice)
    }

    public static func isPointFocusAvailable(forCameraDevice cameraDevice: CameraDevice) -> Bool {
        return AVCaptureDevice.isPointFocusAvailable(for: cameraDevice)
    }

    public static func isCameraDeviceAvailable(_ cameraDevice: CameraDevice) -> Bool {
        return AVCaptureDevice.captureDevice(from: cameraDevice) != nil
    }

    public func focus(at touchPoint: CGPoint) -> Bool {
        let pointOfInterest: CGPoint = focusPointOfInterest(forTouchPoint: touchPoint)
        return focus(atPointOfInterest: pointOfInterest)
    }

    public func zoom(to zoomScale: CGFloat) -> Bool {
        return currentCameraDevice()?.zoom(to: zoomScale) == true
    }

    private func handleCameraDeviceChanged(oldValue: CameraDevice, newValue: CameraDevice) {
        guard let device: AVCaptureDevice = AVCaptureDevice.captureDevice(from: cameraDevice) else { return }
        if oldValue != newValue {
            do {
                let oldInput: AVCaptureInput? = session.inputs.last
                let newInput: AVCaptureDeviceInput = try AVCaptureDeviceInput(device: device)
                session.beginConfiguration()
                if let oldInput = oldInput {
                    session.removeInput(oldInput)
                }
                session.addInputIfPossible(newInput)
                session.commitConfiguration()
            } catch {
                dump(error)
            }
        }
        resetZoom()
    }

    private func handleCameraTorchModeChanged() {
        let device: AVCaptureDevice? = currentCameraDevice()
        if AVCaptureDevice.isTorchAvailable(for: cameraDevice) {
            device?.setCameraTorchMode(cameraTorchMode)
        } else {
            guard cameraTorchMode != .off else { return }
            cameraTorchMode = .off
        }
    }
}

// MARK: - Photo Capturing
extension SwiftttCamera {
    public var isReadyToCapturePhoto: Bool {
        return !isCapturingImage
    }

    public func takePicture() {
        guard deviceAuthorized, !isCapturingImage else { return }
        isCapturingImage = true
        photoCaptureNeedsPreviewRotation = !deviceOrientation.deviceOrientationMatchesInterfaceOrientation
        #if targetEnvironment(simulator)
        insertPreviewLayer()
        let fakeImage = UIImage.fakeTestImage()
        process(cameraPhoto: fakeImage, needsPreviewRotation: photoCaptureNeedsPreviewRotation, previewOrientation: .portrait)
        #else
        guard let videoConnection: AVCaptureConnection = currentCaptureConnection() else { preconditionFailure("videoConnection is nil in physical device") }
        if videoConnection.isVideoOrientationSupported {
            videoConnection.videoOrientation = currentCaptureVideoOrientationForDevice()
        }
        if videoConnection.isVideoMirroringSupported {
            videoConnection.isVideoMirrored = cameraDevice == .front
        }
        photoCapturePreviewOrientation = currentPreviewDeviceOrientation()
        let settings: AVCapturePhotoSettings = AVCapturePhotoSettings(format: [
            AVVideoCodecKey : AVVideoCodecType.jpeg,
        ])
        settings.flashMode = cameraFlashMode.captureFlashMode
        photoOutput.capturePhoto(with: settings, delegate: self)
        #endif
    }
}

// MARK: - Photo Processing
extension SwiftttCamera {
    public func process(image: UIImage, withCropRect cropRect: CGRect?, withMaxDimension maxDimension: CGFloat?) {
        self.process(image: image, withCropRect: cropRect, maxDimension: maxDimension, fromCamera: false, needsPreviewRotation: false, previewOrientation: .unknown)
    }

    public func cancelImageProcessing() {
        isCapturingImage = false
    }

    private func process(cameraPhoto image: UIImage, needsPreviewRotation: Bool, previewOrientation: UIDeviceOrientation) {
        let cropRect: CGRect? = cropsImageToVisibleAspectRatio ? image.cropRect(fromPreviewLayer: previewLayer) : nil
        self.process(image: image, withCropRect: cropRect, maxDimension: maxScaledDimension, fromCamera: true, needsPreviewRotation: needsPreviewRotation || !interfaceRotatesWithOrientation, previewOrientation: previewOrientation)
    }

    private func process(image: UIImage, withCropRect cropRect: CGRect?, maxDimension: CGFloat?, fromCamera: Bool, needsPreviewRotation: Bool, previewOrientation: UIDeviceOrientation) {
        // This function has multiple guard statements that seem redundant, but they're not: the user may cancel image processing via `cancelImageProcessing()` at at time, which sets `isCapturingImage = false`, so those guard statements make that happen.
        guard !fromCamera || isCapturingImage else { return }
        let capturedImage: CapturedImage = CapturedImage(fullImage: image)
        var numberOfTasks = 0
        numberOfTasks += 1
        let callDelegateIfNeeded: (((CameraProtocol) -> Void) -> Void) = { [weak self] delegateMethod in
            let finishCapturingImageIfPossible = {
                numberOfTasks -= 1
                guard numberOfTasks == 0 else { return }
                self?.isCapturingImage = false
            }
            if let self = self, !fromCamera || self.isCapturingImage {
                finishCapturingImageIfPossible() // Must be called before the delegate
                delegateMethod(self)
            } else {
                finishCapturingImageIfPossible()
            }
        }
        capturedImage.crop(to: cropRect, returnsPreview: fromCamera && returnsRotatedPreview, needsPreviewRotation: needsPreviewRotation, withPreviewOrientation: previewOrientation)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] capturedImage in
                callDelegateIfNeeded { cameraController in
                    self?.delegate?.cameraController(cameraController, didFinishCapturingImage: capturedImage)
                }
            }
            .store(in: &cancellables)
        guard !fromCamera || isCapturingImage else { return }
        let future: Future<CapturedImage, Never> = {
            if let maxDimension = maxDimension {
                return capturedImage.scale(to: maxDimension)
            } else {
                return capturedImage.scale(to: view.bounds.size)
            }
        }()
        numberOfTasks += 1
        future
            .receive(on: DispatchQueue.main)
            .sink { [weak self] capturedImage in
                callDelegateIfNeeded { cameraController in
                    self?.delegate?.cameraController(cameraController, didFinishScalingCapturedImage: capturedImage)
                }
            }
            .store(in: &cancellables)
        guard !fromCamera || isCapturingImage else { return }
        if normalizesImageOrientations {
            numberOfTasks += 1
            capturedImage.normalize()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] capturedImage in
                    callDelegateIfNeeded { cameraController in
                        self?.delegate?.cameraController(cameraController, didFinishNormalizingCapturedImage: capturedImage)
                    }
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - Observers
extension SwiftttCamera {
    @objc
    private func applicationWillEnterForeground(_ notification: Notification) {
        setUpCaptureSession()
    }

    @objc
    private func applicationDidBecomeActive(_ notification: Notification) {
        guard isViewLoaded, view.window != nil else { return }
        startRunning()
        insertPreviewLayer()
        setPreviewVideoOrientation()
    }

    @objc
    private func applicationWillResignActive(_ notification: Notification) {
        stopRunning()
    }

    @objc
    private func applicationDidEnterBackground(_ notification: Notification) {
        teardownCaptureSession()
    }
}

// MARK: - AV Orientation
extension SwiftttCamera {
    private func setPreviewVideoOrientation() {
        guard let videoConnection: AVCaptureConnection = previewLayer?.connection else { return }
        guard videoConnection.isVideoOrientationSupported else { return }
        videoConnection.videoOrientation = currentPreviewVideoOrientationForDevice()
    }

    private func currentCaptureVideoOrientationForDevice() -> AVCaptureVideoOrientation {
        let actualOrientation: UIDeviceOrientation = deviceOrientation.orientation
        switch actualOrientation {
        case .faceDown, .faceUp, .unknown: return currentPreviewVideoOrientationForDevice()
        default: return Self.videoOrientation(forDeviceOrientation: actualOrientation)
        }
    }

    private func currentPreviewDeviceOrientation() -> UIDeviceOrientation {
        return interfaceRotatesWithOrientation ? UIDevice.current.orientation : fixedInterfaceOrientation
    }

    private func currentPreviewVideoOrientationForDevice() -> AVCaptureVideoOrientation {
        let deviceOrientation: UIDeviceOrientation = currentPreviewDeviceOrientation()
        return Self.videoOrientation(forDeviceOrientation: deviceOrientation)
    }

    private static func videoOrientation(forDeviceOrientation deviceOrientation: UIDeviceOrientation) -> AVCaptureVideoOrientation {
        switch deviceOrientation {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .portrait
        }
    }
}

// MARK: - Camera Permission
extension SwiftttCamera {
    private func checkDeviceAuthorization() -> Future<Bool, Never> {
        return Future { promise in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                promise(.success(granted))
            }
        }
    }
}

// MARK: - CameraDevice
extension SwiftttCamera {
    private func currentCameraDevice() -> AVCaptureDevice? {
        return (session.inputs.last as? AVCaptureDeviceInput)?.device
    }

    private func currentCaptureConnection() -> AVCaptureConnection? {
        return photoOutput.connections.first { $0.inputPorts.contains { $0.mediaType == .video } }
    }

    private func focusPointOfInterest(forTouchPoint touchPoint: CGPoint) -> CGPoint {
        return previewLayer.captureDevicePointConverted(fromLayerPoint: touchPoint)
    }

    private func focus(atPointOfInterest pointOfInterest: CGPoint) -> Bool {
        return currentCameraDevice()?.focus(at: pointOfInterest) == true
    }

    private func resetZoom() {
        zoom?.resetZoom()
        if let videoMaxZoomFactor = currentCameraDevice()?.videoMaxZoomFactor {
            zoom?.maxScale = videoMaxZoomFactor
        }
        maxZoomFactor = zoom?.maxScale ?? maxZoomFactor
    }
}

extension SwiftttCamera : FocusDelegate {
    func handleTapFocus(atPoint touchPoint: CGPoint) -> Bool {
        guard AVCaptureDevice.isPointFocusAvailable(for: cameraDevice) else { return false }
        let pointOfInterest: CGPoint = focusPointOfInterest(forTouchPoint: touchPoint)
        return focus(atPointOfInterest: pointOfInterest) && showsFocusView
    }
}

extension SwiftttCamera : ZoomDelegate {
    func handlePinchZoom(withScale zoomScale: CGFloat) -> Bool {
        return zoom(to: zoomScale) && showsZoomView
    }
}

extension SwiftttCamera : AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard isCapturingImage else { return }
        guard let imageData: Data = photo.fileDataRepresentation() else { isCapturingImage = false; return }
        delegate?.cameraController(self, didFinishCapturingImageData: imageData)
        DispatchQueue.global().async { [weak self, photoCaptureNeedsPreviewRotation, photoCapturePreviewOrientation] in
            guard let image = UIImage(data: imageData) else { self?.isCapturingImage = false; return }
            DispatchQueue.main.async {
                self?.process(cameraPhoto: image, needsPreviewRotation: photoCaptureNeedsPreviewRotation, previewOrientation: photoCapturePreviewOrientation)
            }
        }
    }
}
