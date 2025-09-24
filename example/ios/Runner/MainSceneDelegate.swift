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
        guard let windowScene = (scene as? UIWindowScene) else {return}
        guard let engine = appDelegate?.engines?.makeEngine(withEntrypoint: nil, libraryURI: nil) else {return}
        GeneratedPluginRegistrant.register(with: engine)

        let flutterViewController = FlutterViewController(engine: engine, nibName: nil, bundle: nil)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = flutterViewController

        NotificationCenter.default.addObserver(self, selector: #selector(windowDidBecomeKey(_:)), name: UIWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(windowDidResignKey(_:)), name: UIWindow.didResignKeyNotification, object: nil)

        window?.makeKeyAndVisible()
        print("I'm on MainSceneDelegate!")

    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate?.currentFocusedSceneName = "MainScene"
        print("[MainSceneDelegate] sceneDidBecomeActive -> focused: MainScene")
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Only clear if this scene was the one focused
        if appDelegate?.currentFocusedSceneName == "MainScene" {
            appDelegate?.currentFocusedSceneName = nil
        }
        print("[MainSceneDelegate] sceneWillResignActive")
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("[MainSceneDelegate] sceneWillEnterForeground")
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        print("[MainSceneDelegate] sceneDidEnterBackground")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        NotificationCenter.default.removeObserver(self, name: UIWindow.didBecomeKeyNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIWindow.didResignKeyNotification, object: nil)
        print("[MainSceneDelegate] sceneDidDisconnect -> observers removed")
    }

    @objc private func windowDidBecomeKey(_ notification: Notification) {
        guard let win = notification.object as? UIWindow, win === self.window else { return }
        appDelegate?.currentFocusedSceneName = "MainScene"
        print("[MainSceneDelegate] windowDidBecomeKey -> MainScene")
    }

    @objc private func windowDidResignKey(_ notification: Notification) {
        guard let win = notification.object as? UIWindow, win === self.window else { return }
        if appDelegate?.currentFocusedSceneName == "MainScene" {
            appDelegate?.currentFocusedSceneName = nil
        }
        print("[MainSceneDelegate] windowDidResignKey")
    }
}
