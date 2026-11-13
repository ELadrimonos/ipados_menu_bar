import Flutter
import UIKit

/// Scene running the default `main` Dart entrypoint.
class MainSceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene, willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene,
            let appDelegate = UIApplication.shared.delegate as? AppDelegate
        else { return }

        let engine = appDelegate.engines.makeEngine(withEntrypoint: nil, libraryURI: nil)
        GeneratedPluginRegistrant.register(with: engine)

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = FlutterViewController(
            engine: engine, nibName: nil, bundle: nil)
        window?.makeKeyAndVisible()
    }
}
