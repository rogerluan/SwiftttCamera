// Copyright © 2021 Roger Oba. All rights reserved.

import AVFoundation
import Foundation

public extension AVCaptureSession {
    /// Adds the given AVCaptureInput to the session, if possible.
    func addInputIfPossible(_ input: AVCaptureInput) {
        guard canAddInput(input) else { return }
        addInput(input)
    }

    /// Adds the given AVCaptureOutput to the session, if possible.
    func addOutputIfPossible(_ output: AVCaptureOutput) {
        guard canAddOutput(output) else { return }
        addOutput(output)
    }

    /// Configures the receiver with the given preset, if possible.
    func setSessionPresetIfPossible(_ preset: AVCaptureSession.Preset) {
        guard canSetSessionPreset(preset) else { return }
        sessionPreset = preset
    }

    /// Starts running the session, if it's not running already.
    func startRunningIfNeeded() {
        guard !isRunning else { return }
        startRunning()
    }

    /// Stops running the session, if it's running.
    func stopRunningIfNeeded() {
        guard isRunning else { return }
        stopRunning()
    }
}
