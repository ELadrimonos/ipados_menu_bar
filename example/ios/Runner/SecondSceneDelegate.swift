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

        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)), name: UIWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey(_:)), name: UIWindow.didResignKeyNotification, object: nil)

        print("I'm on SecondSceneDelegate!")
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate?.currentFocusedSceneName = "SecondScene"
        print("[SecondSceneDelegate] sceneDidBecomeActive -> focused: SecondScene")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        if appDelegate?.currentFocusedSceneName == "SecondScene" {
            appDelegate?.currentFocusedSceneName = nil
        }
        print("[SecondSceneDelegate] sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[SecondSceneDelegate] sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("[SecondSceneDelegate] sceneDidEnterBackground")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.didResignKeyNotification, object: nil)
        print("[SecondSceneDelegate] sceneDidDisconnect -> observers removed")
    }

    @objc private func windowDidBecomeKey(_ notification: Notification) {
        guard let win = notification.object as? UIWindow, win === self.window else { return }
        appDelegate?.currentFocusedSceneName = "SecondScene"
        print("[SecondSceneDelegate] windowDidBecomeKey -> SecondScene")
    }

    @objc private func windowDidResignKey(_ notification: Notification) {
        guard let win = notification.object as? UIWindow, win === self.window else { return }
        if appDelegate?.currentFocusedSceneName == "SecondScene" {
            appDelegate?.currentFocusedSceneName = nil
        }
        print("[SecondSceneDelegate] windowDidResignKey")
    }
}
