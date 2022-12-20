//
//  SceneDelegate.swift
//  Networking-Example
//
//  Created by Viktor Gidlöf.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = scene as? UIWindowScene else { return }

        window = UIWindow(windowScene: scene)
        let apis: [APIListData] = [.github, .pokeAPI, .httpBin, .placeholder, .reqres]
        let view = APIListViewController(data: apis)
        window?.rootViewController = UINavigationController(rootViewController: view)
        window?.makeKeyAndVisible()
    }
}
