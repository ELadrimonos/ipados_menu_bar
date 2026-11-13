import Flutter
import UIKit

/// Scene running the `secondMain` Dart entrypoint with the arguments chosen by
/// the window that opened it.
class SecondSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }

        let options = FlutterEngineGroupOptions()
        options.entrypoint = "secondMain"
        options.entrypointArgs = appDelegate.pendingEntrypointArgs
        appDelegate.pendingEntrypointArgs = nil

        let engine = appDelegate.engines.makeEngine(with: options)
        GeneratedPluginRegistrant.register(with: engine)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = FlutterViewController(
            engine: engine, nibName: nil, bundle: nil)
        window?.makeKeyAndVisible()
    }
}
