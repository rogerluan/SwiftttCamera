// Copyright © 2021 Roger Oba. All rights reserved.

import UIKit

class SceneDelegate : UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let tabBarController = UITabBarController()
        let demoVC = DemoViewController()
        #if targetEnvironment(simulator)
        tabBarController.viewControllers = [ demoVC ]
        #else
        let swiftttCameraBenchmarkVC = SwiftttCameraBenchmarkViewController()
        let uiImagePickerBenchmarkVC = UIImagePickerBenchmarkViewController()
        tabBarController.viewControllers = [
            demoVC,
            swiftttCameraBenchmarkVC,
            uiImagePickerBenchmarkVC,
        ]
        #endif
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
        self.window = window
    }
}
