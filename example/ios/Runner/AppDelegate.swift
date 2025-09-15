import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  var engines: FlutterEngineGroup!

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Inicializa el grupo de engines
    engines = FlutterEngineGroup(name: "myEngineGroup", project: nil)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Maneja la configuración de escenas (requerido para múltiples ventanas)
  override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    let config = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
    switch connectingSceneSession.configuration.name {
    case "SecondScene":
      config.delegateClass = SecondSceneDelegate.self
    default:
      config.delegateClass = MainSceneDelegate.self
    }
    return config
  }
}
