// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit
import SwiftttCamera

final class ConfirmationViewController : UIViewController {
    private let capturedImage: CapturedImage

    private lazy var imageView: UIImageView = {
        let result = UIImageView(image: capturedImage.rotatedPreviewImage)
        result.translatesAutoresizingMaskIntoConstraints = false
        result.contentMode = .scaleAspectFit
        return result
    }()

    init(capturedImage: CapturedImage) {
        self.capturedImage = capturedImage
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: UIAction { [unowned self] _ in
            self.presentingViewController?.dismiss(animated: true)
        })
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .action, primaryAction: UIAction { [unowned self] _ in
            self.share()
        })
        if !capturedImage.isNormalized {
            navigationItem.rightBarButtonItem?.isEnabled = false
        }
    }

    func markImageReady() {
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func share() {
        let items = [ capturedImage.fullImage ]
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
