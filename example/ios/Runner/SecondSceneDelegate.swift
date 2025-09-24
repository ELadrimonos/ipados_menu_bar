//
//  SecondSceneDelegate.swift
//  Runner
//
//  Created by Adrián Primo Bernat on 15/9/25.
//

import UIKit
import Flutter

class SecondSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    weak var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let engineOptions: FlutterEngineGroupOptions = FlutterEngineGroupOptions()
        engineOptions.entrypoint = "secondMain"
        engineOptions.libraryURI = nil
        engineOptions.entrypointArgs = appDelegate?.currentEntrypointArgs
        
        print("Entrypoint args sent: \(String(describing: engineOptions.entrypointArgs))")
        
        guard let engine = appDelegate?.engines?.makeEngine(with: engineOptions) else { return }
        GeneratedPluginRegistrant.register(with: engine)

        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()

        print("I'm on SecondSceneDelegate!")
    }
}
