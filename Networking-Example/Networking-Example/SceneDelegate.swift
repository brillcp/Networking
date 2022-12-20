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

        let apis = [
            APIListData(name: "GitHub API", url: "https://api.github.com", endpoints: GitHub.GetRequest.allCases),
            APIListData(name: "Pokemon API", url: "https://pokeapi.co/api/v2", endpoints: PokeAPI.GetRequest.allCases),
            APIListData(name: "HTTPBin API", url: "https://httpbin.org", endpoints: HTTPBin.GetRequest.allCases)
        ]

        let view = APIListViewController(data: apis)
        window?.rootViewController = UINavigationController(rootViewController: view)
        window?.makeKeyAndVisible()
    }
}
