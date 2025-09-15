//
//  MainSceneDelegate.swift
//  Runner
//
//  Created by Adrián Primo Bernat on 15/9/25.
//


import UIKit
import Flutter

class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    weak var appDelegate: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        guard let engine = appDelegate?.engines?.makeEngine(withEntrypoint: nil, libraryURI: nil) else { return }
        GeneratedPluginRegistrant.register(with: engine)

        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)
        
        // Configura un canal de métodos para que Dart pida nuevas escenas
        let channel = FlutterMethodChannel(name: "app/scenes", binaryMessenger: flutterViewController.binaryMessenger)
        channel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) in
            if call.method == "createScene" {
                let activity = NSUserActivity(activityType: "app.createscene") // Tipo de actividad para escena secundaria
                UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { (error: Error?) in
                    if let error = error {
                        result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
                    } else {
                        result(nil)
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }
        
        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController
        window?.makeKeyAndVisible()
    }
}
