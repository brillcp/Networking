//
//  SceneDelegate.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf on 2022-12-13.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: scene)
        window?.rootViewController = UINavigationController(rootViewController: APIViewController())
        window?.makeKeyAndVisible()
    }
}
