import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let logTag = "[AppDelegate]"
  var engines: FlutterEngineGroup!
  private var pendingSceneIdentifier: String?
  
  // Store current entrypoint received via notification
  private var currentEntrypoint: String? = nil

  func openNewWindow(withSceneId sceneId: String) {
    print("\(logTag) openNewWindow called with sceneId=\(sceneId)")
    pendingSceneIdentifier = sceneId
    print("\(logTag) pendingSceneIdentifier set to \(String(describing: pendingSceneIdentifier))")

    let activity = NSUserActivity(activityType: "com.example.runner.newWindow")
    activity.title = "New Window"
    activity.userInfo = ["sceneId": sceneId]
    print("\(logTag) requesting SceneSession activation with userActivity.userInfo=\(String(describing: activity.userInfo))")

    UIApplication.shared.requestSceneSessionActivation(nil, userActivity: activity, options: nil) { error in
      print("\(self.logTag) requestSceneSessionActivation failed: \(error.localizedDescription)")
      self.pendingSceneIdentifier = nil
      print("Failed to activate new scene: \(error.localizedDescription)")
    }
  }

  override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    engines = FlutterEngineGroup(name: "myEngineGroup", project: nil)
    
    // Listen for entrypoint updates from plugin
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(entrypointUpdated(_:)),
      name: NSNotification.Name("EntrypointUpdated"),
      object: nil
    )
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  @objc private func entrypointUpdated(_ notification: Notification) {
    if let entrypoint = notification.userInfo?["entrypoint"] as? String {
      currentEntrypoint = entrypoint
      print("\(logTag) received entrypoint update: \(entrypoint)")
    } else {
      currentEntrypoint = nil
      print("\(logTag) cleared entrypoint")
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    print("\(logTag) configurationForConnecting: sessionRole=\(connectingSceneSession.role.rawValue)")
    print("\(logTag) options.userActivities.first?.userInfo=\(String(describing: options.userActivities.first?.userInfo))")

    var desiredSceneId: String? = nil

    // 1) Prefer a sceneId passed via userActivity
    if let activity = options.userActivities.first, let sceneId = activity.userInfo?["sceneId"] as? String {
      desiredSceneId = sceneId
    }
    print("\(logTag) desiredSceneId after userActivity=\(String(describing: desiredSceneId))")

    // 2) Fallback to pending id
    if desiredSceneId == nil {
      desiredSceneId = pendingSceneIdentifier
    }
    print("\(logTag) desiredSceneId after pendingSceneIdentifier=\(String(describing: desiredSceneId))")

    // 3) Check current entrypoint from notification
    if desiredSceneId == nil {
      if let entrypoint = currentEntrypoint {
        print("\(logTag) found current entrypoint: \(entrypoint)")
          desiredSceneId = entrypoint == "thirdMain" ? "thirdScene" : entrypoint == "secondMain" ? "SecondScene" : nil
      }
    }
    print("\(logTag) desiredSceneId after current entrypoint=\(String(describing: desiredSceneId))")

    // 4) Final fallback
    if desiredSceneId == nil {
      desiredSceneId = connectingSceneSession.configuration.name
    }
    print("\(logTag) desiredSceneId after session.configuration.name=\(String(describing: desiredSceneId))")

    let config = UISceneConfiguration(name: desiredSceneId, sessionRole: connectingSceneSession.role)
    print("\(logTag) creating UISceneConfiguration with name=\(String(describing: desiredSceneId))")

    switch desiredSceneId {
    case "ThirdScene", "thirdMain":
        print("\(logTag) selecting SecondSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
        config.delegateClass = ThirdSceneDelegate.self
    case "SecondScene", "secondMain":
      print("\(logTag) selecting SecondSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
      config.delegateClass = SecondSceneDelegate.self
    default:
      print("\(logTag) selecting MainSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
      config.delegateClass = MainSceneDelegate.self
    }

    print("\(logTag) clearing pendingSceneIdentifier (was=\(String(describing: pendingSceneIdentifier)))")
    pendingSceneIdentifier = nil

    print("\(logTag) returning UISceneConfiguration with delegateClass=\(String(describing: config.delegateClass))")
    return config
  }
    /*
  @objc func openNewWindowWithSceneId(_ sceneId: NSString) {
    print("\(logTag) openNewWindowWithSceneId called with sceneId=\(sceneId)")
    openNewWindow(withSceneId: sceneId as String)
  }
     */
}
