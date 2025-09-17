//
//  SecondSceneDelegate 2.swift
//  Runner
//
//  Created by Adrián Primo Bernat on 17/9/25.
//


//
//  SecondSceneDelegate.swift
//  Runner
//
//  Created by Adrián Primo Bernat on 15/9/25.
//


import UIKit
import Flutter

class ThirdSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    weak var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let engine = appDelegate?.engines?.makeEngine(withEntrypoint: "thirdMain", libraryURI: nil) else { return }
        GeneratedPluginRegistrant.register(with: engine)

        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        print("I'm on ThirdSceneDelegate!")
    }
}
