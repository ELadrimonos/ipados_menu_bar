import Flutter
import UIKit
import ipados_menu_bar

@main
@objc class AppDelegate: FlutterAppDelegate {
    /// Every window runs its own engine, spawned from this group.
    let engines = FlutterEngineGroup(name: "ipados_menu_bar_example", project: nil)

    /// Entrypoint arguments for the scene that is about to connect.
    var pendingEntrypointArgs: [String]?

    override func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        // The focused window decides, through its `IPadWindowMenu`, which Dart
        // entrypoint (and arguments) the new window runs.
        let entrypoint = IpadOSMenubarPlugin.focusedWindowEntrypoint
        pendingEntrypointArgs = IpadOSMenubarPlugin.focusedWindowEntrypointArguments

        let name: String
        let delegateClass: AnyClass
        switch entrypoint {
        case "secondMain":
            name = "SecondScene"
            delegateClass = SecondSceneDelegate.self
        case "thirdMain":
            name = "ThirdScene"
            delegateClass = ThirdSceneDelegate.self
        default:
            name = "MainScene"
            delegateClass = MainSceneDelegate.self
        }

        let configuration = UISceneConfiguration(
            name: name, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = delegateClass
        return configuration
    }
}
