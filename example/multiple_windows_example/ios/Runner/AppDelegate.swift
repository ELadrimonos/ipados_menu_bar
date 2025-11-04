import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    private let logTag = "[AppDelegate]"
    var engines: FlutterEngineGroup!
    private var pendingSceneIdentifier: String?
    public var currentEntrypointArgs: [String]? = nil
    
    // Store current entrypoint received via notification
    private var currentEntrypoint: String? = nil
    public var currentWindowDataPayload: [String: Any]? = nil
    
    // Tracks which scene/window is currently focused (active)
    public var currentFocusedSceneName: String? = nil {
        didSet {
            let name = currentFocusedSceneName ?? "none"
            print("[AppDelegate] Current focused scene: \(name)")
            NotificationCenter.default.post(
                name: NSNotification.Name("FocusedSceneChanged"),
                object: self,
                userInfo: ["name": name]
            )
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
        
        if let payload = notification.userInfo?["payload"] as? [String: Any] {
            currentWindowDataPayload = payload
            print("\(logTag) received windowDataPayload: \(payload)")
        } else {
            currentWindowDataPayload = nil
            print("\(logTag) cleared windowDataPayload")
        }

        if let payloadArgs = notification.userInfo?["payloadArgs"] as? [String] {
            currentEntrypointArgs = payloadArgs
            print("\(logTag) received payloadArgs: \(payloadArgs)")
        } else {
            currentEntrypointArgs = nil
            print("\(logTag) cleared payloadArgs")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        print("\(logTag) configurationForConnecting: sessionRole=\(connectingSceneSession.role.rawValue)")
        
        var desiredSceneId: String? = nil
        
        // Only use the current entrypoint provided by Dart (via notification)
        if let entrypoint = currentEntrypoint {
            print("\(logTag) using current entrypoint from Dart: \(entrypoint)")
            switch entrypoint {
            case "thirdMain":
                desiredSceneId = "ThirdScene"
            case "secondMain":
                desiredSceneId = "SecondScene"
            default:
                desiredSceneId = nil
            }
        } else {
            print("\(logTag) no current entrypoint from Dart; will fallback to session configuration name")
        }
        
        // Final minimal fallback: ensure first window uses the main scene
        if desiredSceneId == nil {
            // Do NOT use connectingSceneSession.configuration.name here; we always want Main by default.
            print("\(logTag) no current entrypoint; defaulting to MainScene")
            desiredSceneId = "MainScene"
        }
        print("\(logTag) resolved desiredSceneId=\(String(describing: desiredSceneId))")
        
        let config = UISceneConfiguration(name: desiredSceneId, sessionRole: connectingSceneSession.role)
        print("\(logTag) creating UISceneConfiguration with name=\(String(describing: desiredSceneId))")
        
        switch desiredSceneId {
        case "ThirdScene", "thirdMain":
            print("\(logTag) selecting ThirdSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
            config.delegateClass = ThirdSceneDelegate.self
        case "SecondScene", "secondMain":
            print("\(logTag) selecting SecondSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
            config.delegateClass = SecondSceneDelegate.self
        default:
            print("\(logTag) selecting MainSceneDelegate for desiredSceneId=\(String(describing: desiredSceneId))")
            config.delegateClass = MainSceneDelegate.self
        }
        
        // Clear any previously stored pending identifier just in case
        print("\(logTag) clearing pendingSceneIdentifier (was=\(String(describing: pendingSceneIdentifier)))")
        pendingSceneIdentifier = nil
        
        print("\(logTag) returning UISceneConfiguration with delegateClass=\(String(describing: config.delegateClass))")
        return config
    }
}

