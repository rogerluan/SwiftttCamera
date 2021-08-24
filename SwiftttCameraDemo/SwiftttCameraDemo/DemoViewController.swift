// Copyright © 2021 Roger Oba. All rights reserved.

import SwiftttCamera
import UIKit

class DemoViewController : UIViewController {
    // MARK: - Content
    private weak var confirmationVC: ConfirmationViewController?

    private lazy var camera: SwiftttCamera = {
        let result = SwiftttCamera()
        result.delegate = self
        result.view.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var flashButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Flash Off", comment: ""), for: .normal)
        result.setTitle(NSLocalizedString("Flash On", comment: ""), for: .selected)
        result.titleLabel?.textAlignment = .center
        result.titleLabel?.numberOfLines = 0
        result.addAction(UIAction(handler: { [unowned self, unowned result] _ in
            self.setFlash(enabled: !result.isSelected)
        }), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var torchButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Torch Off", comment: ""), for: .normal)
        result.setTitle(NSLocalizedString("Torch On", comment: ""), for: .selected)
        result.titleLabel?.textAlignment = .center
        result.titleLabel?.numberOfLines = 0
        result.addAction(UIAction(handler: { [unowned self, unowned result] _ in
            self.setTorch(enabled: !result.isSelected)
        }), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var switchCameraButton: UIButton = {
        let result = UIButton()
        result.setTitle(NSLocalizedString("Switch Camera", comment: ""), for: .normal)
        result.titleLabel?.textAlignment = .center
        result.titleLabel?.numberOfLines = 0
        result.addAction(UIAction(handler: { [unowned self] _ in self.handleSwitchCameraButtonPressed() }), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var stackView: UIStackView = {
        let result = UIStackView(arrangedSubviews: [
            flashButton,
            torchButton,
            switchCameraButton,
        ])
        result.distribution = .fillProportionally
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    private lazy var shutterButton: UIButton = {
        let result = UIButton()
        result.setImage(#imageLiteral(resourceName: "shutter").withRenderingMode(.alwaysTemplate), for: .normal)
        result.tintColor = .white
        result.addAction(UIAction(handler: { [unowned self] _ in self.handleShutterButtonPressed() }), for: .touchUpInside)
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("Demo", comment: "")
        tabBarItem.image = #imageLiteral(resourceName: "aperture")
        swiftttAddChild(camera)
        view.addSubview(stackView)
        view.addSubview(shutterButton)
        NSLayoutConstraint.activate([
            // Camera view
            camera.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            camera.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            camera.view.topAnchor.constraint(equalTo: view.topAnchor),
            camera.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            // Buttons stack view
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 44),
            // Shutter button
            shutterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shutterButton.heightAnchor.constraint(equalToConstant: 88),
            shutterButton.widthAnchor.constraint(equalToConstant: 88),
            shutterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    // MARK: - Interactions
    private func setFlash(enabled: Bool) {
        print("Flash button pressed")
        flashButton.isSelected = enabled
        camera.cameraFlashMode = enabled ? .on : .off
    }

    private func setTorch(enabled: Bool) {
        print("Torch button pressed")
        let shouldEnable = enabled && camera.isTorchAvailableForCurrentDevice
        torchButton.isSelected = shouldEnable
        camera.cameraTorchMode = shouldEnable ? .on : .off
    }

    private func handleSwitchCameraButtonPressed() {
        print("Switch camera button pressed")
        let newCameraDevice: CameraDevice = camera.cameraDevice.toggling()
        guard SwiftttCamera.isCameraDeviceAvailable(newCameraDevice) else { return }
        camera.cameraDevice = newCameraDevice
        setTorch(enabled: torchButton.isSelected)
    }

    private func handleShutterButtonPressed() {
        print("Shutter button pressed")
        camera.takePicture()
        if flashButton.isSelected {
            // When both flash and torch are enabled, the torch is disabled after taking the photo
            setTorch(enabled: false)
        }
    }
}

extension DemoViewController : CameraDelegate {
    func cameraController(_ cameraController: CameraProtocol, didFinishCapturingImage capturedImage: CapturedImage) {
        let flashView: UIView = UIView()
        flashView.backgroundColor = .lightGray
        flashView.alpha = 0
        view.addSubview(flashView)
        NSLayoutConstraint.activate([
            flashView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            flashView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            flashView.topAnchor.constraint(equalTo: view.topAnchor),
            flashView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            flashView.alpha = 1
        } completion: { [weak self] _ in
            let confirmationVC = ConfirmationViewController(capturedImage: capturedImage)
            self?.confirmationVC = confirmationVC
            self?.present(UINavigationController(rootViewController: confirmationVC), animated: true)
            UIView.animate(withDuration: 0.15, delay: 0.05, options: .curveEaseOut) {
                flashView.alpha = 0
            } completion: { _ in
                flashView.removeFromSuperview()
            }
        }
    }

    func cameraController(_ cameraController: CameraProtocol, didFinishNormalizingCapturedImage capturedImage: CapturedImage) {
        print("Image has been normalized and is ready")
        confirmationVC?.markImageReady()
    }
}
