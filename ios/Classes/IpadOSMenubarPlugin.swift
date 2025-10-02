import Flutter
import UIKit

public class IpadOSMenubarPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    
    // Estado por escena: cada identificador de escena tiene su propio estado de menú
    private var sceneMenuStates: [String: MenuState] = [:]
    
    // Estructura para almacenar el estado de menú de una escena
    struct MenuState {
        var customMenus: [[String: Any]] = []
        var presentDefaultMenus: [String] = []
        var defaultMenuItems: [String: [[String: Any]]] = [:]
        var windowEntrypoint: String? = nil
        var windowDataPayload: [String: Any]? = nil
        var windowEntrypointArgs: [String]? = nil
    }
    
    @objc public var windowEntrypoint: String? = nil
    @objc public var windowDataPayload: [String: Any]? = nil
    @objc public var windowEntrypointArgs: [String]? = nil
    
    @objc public func getCurrentEntrypoint() -> String? {
        print("[IpadOSMenubarPlugin] getCurrentEntrypoint called, returning: \(String(describing: windowEntrypoint))")
        return windowEntrypoint
    }
    
    private let logTag = "[IpadOSMenubarPlugin]"
    
    public static var shared: IpadOSMenubarPlugin?
    private var menuBuilderDelegate: MenuBuilderDelegate?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = IpadOSMenubarPlugin()
        instance.channel = FlutterMethodChannel(
            name: "flutter/ipados_menu",
            binaryMessenger: registrar.messenger()
        )
        registrar.addMethodCallDelegate(instance, channel: instance.channel)
        
        IpadOSMenubarPlugin.shared = instance
        instance.setupMenuDelegate()
        instance.observeFocusChanges()
        
        print("[IpadOSMenubarPlugin] registered successfully")
    }
    
    private func setupMenuDelegate() {
        if UIApplication.shared.connectedScenes.first is UIWindowScene {
            menuBuilderDelegate = MenuBuilderDelegate(plugin: self)
        }
    }
    
    // Observar cambios de foco entre escenas
    private func observeFocusChanges() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(focusedSceneChanged(_:)),
            name: NSNotification.Name("FocusedSceneChanged"),
            object: nil
        )
    }
    
    @objc private func focusedSceneChanged(_ notification: Notification) {
        guard let sceneName = notification.userInfo?["name"] as? String else { return }
        print("\(logTag) Scene focus changed to: \(sceneName)")
        
        // Restaurar el estado de menú de la escena enfocada
        if let state = sceneMenuStates[sceneName] {
            print("\(logTag) Restoring menu state for scene: \(sceneName)")
            self.windowEntrypoint = state.windowEntrypoint
            self.windowDataPayload = state.windowDataPayload
            self.windowEntrypointArgs = state.windowEntrypointArgs
            
            DispatchQueue.main.async {
                self.rebuildMenus()
            }
        }
    }
    
    // Obtener el identificador de la escena actual
    private func getCurrentSceneIdentifier() -> String? {
        // Intenta obtener la escena activa
        if let activeScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            return activeScene.session.configuration.name
        }
        
        return nil
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("\(logTag) handle: method=\(call.method)")
        
        switch call.method {
        case "Menu.setMenus":
            if let args = call.arguments as? [String: Any] {
                // Determinar qué escena está haciendo la llamada
                let sceneId = (args["sceneIdentifier"] as? String) ?? getCurrentSceneIdentifier() ?? "MainScene"
                print("\(logTag) Menu.setMenus for scene: \(sceneId)")
                
                var state = sceneMenuStates[sceneId] ?? MenuState()
                
                if let customMenusData = args["customMenus"] as? [[String: Any]] {
                    state.customMenus = customMenusData
                    print("\(logTag) customMenus count=\(customMenusData.count)")
                }
                
                if let defaultMenusData = args["defaultMenus"] as? [String] {
                    state.presentDefaultMenus = defaultMenusData
                    print("\(logTag) presentDefaultMenus ids=\(defaultMenusData)")
                }
                
                if let defaultItemsData = args["defaultMenuItems"] as? [String: [[String: Any]]] {
                    state.defaultMenuItems = defaultItemsData
                    print("\(logTag) defaultMenuItems keys=\(Array(defaultItemsData.keys))")
                }
                
                if let entrypoint = args["windowEntrypoint"] as? String {
                    state.windowEntrypoint = entrypoint
                    print("\(logTag) windowEntrypoint set to: \(entrypoint)")
                } else {
                    state.windowEntrypoint = nil
                }
                
                if let payload = args["windowDataPayload"] as? [String: Any] {
                    state.windowDataPayload = payload
                    state.windowEntrypointArgs = makeEntrypointArgs(from: payload)
                } else {
                    state.windowDataPayload = nil
                    state.windowEntrypointArgs = nil
                }
                
                // Guardar el estado actualizado
                sceneMenuStates[sceneId] = state
                
                // Si esta es la escena activa, actualizar las variables globales y reconstruir
                if sceneId == getCurrentSceneIdentifier() {
                    self.windowEntrypoint = state.windowEntrypoint
                    self.windowDataPayload = state.windowDataPayload
                    self.windowEntrypointArgs = state.windowEntrypointArgs
                    
                    self.setGlobalEntrypointAndPayload()
                    
                    DispatchQueue.main.async {
                        self.rebuildMenus()
                    }
                }
                
                result(nil)
            } else {
                result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
            }
            
        case "Menu.getAvailableDefaultMenus":
            let availableMenus = [
                "file": "File Menu",
                "edit": "Edit Menu",
                "format": "Format Menu",
                "view": "View Menu",
                "window": "Window Menu",
                "help": "Help Menu",
            ]
            result(availableMenus)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func rebuildMenus() {
        UIMenuSystem.main.setNeedsRebuild()
        
        // Obtener el estado de la escena actual
        guard let sceneId = getCurrentSceneIdentifier(),
              let state = sceneMenuStates[sceneId] else {
            return
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("FlutterMenusChanged"),
            object: self,
            userInfo: [
                "customMenus": state.customMenus,
                "presentDefaultMenus": state.presentDefaultMenus,
                "defaultMenuItems": state.defaultMenuItems,
            ]
        )
    }
    
    public func getCustomMenus() -> [[String: Any]] {
        guard let sceneId = getCurrentSceneIdentifier(),
              let state = sceneMenuStates[sceneId] else {
            return []
        }
        return state.customMenus.reversed()
    }
    
    public func getPresentDefaultMenus() -> [String] {
        guard let sceneId = getCurrentSceneIdentifier(),
              let state = sceneMenuStates[sceneId] else {
            return []
        }
        return state.presentDefaultMenus
    }
    
    public func getDefaultMenuItems() -> [String: [[String: Any]]] {
        guard let sceneId = getCurrentSceneIdentifier(),
              let state = sceneMenuStates[sceneId] else {
            return [:]
        }
        return state.defaultMenuItems
    }
    
    public func performAction(id: Int) {
        print("\(logTag) performAction id=\(id)")
        channel.invokeMethod("Menu.selectedCallback", arguments: id)
    }
    
    private func setGlobalEntrypointAndPayload() {
        print("\(logTag) sending entrypoint and payload notification: entrypoint=\(String(describing: windowEntrypoint)), payload=\(String(describing: windowDataPayload))")
        
        // Verificar si estamos en un entorno multi-escena antes de enviar la notificación
        let isMultiScene = UIApplication.shared.connectedScenes.count > 1 ||
                          UIApplication.shared.supportsMultipleScenes
        
        if !isMultiScene {
            print("\(logTag) Single-scene app detected, skipping AppDelegate notification")
            return
        }
        
        var userInfo: [String: Any] = [:]
        if let entrypoint = windowEntrypoint {
            userInfo["entrypoint"] = entrypoint
        }
        if let payload = windowDataPayload {
            userInfo["payload"] = payload
        }
        if let args = windowEntrypointArgs {
            userInfo["payloadArgs"] = args
        }
        
        NotificationCenter.default.post(
            name: NSNotification.Name("EntrypointUpdated"),
            object: self,
            userInfo: userInfo
        )
        
        print("\(logTag) notification sent successfully")
    }
    
    private func makeEntrypointArgs(from payload: [String: Any]) -> [String]? {
        guard JSONSerialization.isValidJSONObject(payload) else {
            print("\(logTag) payload is not valid JSON")
            return nil
        }
        do {
            let data = try JSONSerialization.data(withJSONObject: payload, options: [])
            guard let json = String(data: data, encoding: .utf8) else {
                print("\(logTag) failed to create UTF-8 JSON string")
                return nil
            }
            return [json]
        } catch {
            print("\(logTag) JSON serialization error: \(error)")
            return nil
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

private class MenuBuilderDelegate {
    weak var plugin: IpadOSMenubarPlugin?
    
    init(plugin: IpadOSMenubarPlugin) {
        self.plugin = plugin
        setupMenuInterception()
    }
    
    private func setupMenuInterception() {
        let originalSelector = #selector(UIResponder.buildMenu(with:))
        let swizzledSelector = #selector(UIResponder.swizzled_buildMenu(with:))
        
        guard let originalMethod = class_getInstanceMethod(UIResponder.self, originalSelector),
              let swizzledMethod = class_getInstanceMethod(UIResponder.self, swizzledSelector) else {
            return
        }
        
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension UIResponder {
    @objc func swizzled_buildMenu(with builder: UIMenuBuilder) {
        swizzled_buildMenu(with: builder)
        
        if let plugin = IpadOSMenubarPlugin.shared {
            plugin.buildAllMenus(with: builder)
        }
    }
    
    @objc func handleKeyCommand(_ sender: UIKeyCommand) {
        if let id = sender.propertyList as? Int {
            IpadOSMenubarPlugin.shared?.performAction(id: id)
        }
    }
}

extension IpadOSMenubarPlugin {
    func buildAllMenus(with builder: UIMenuBuilder) {
        print("\(logTag) rebuild: building all menus")
        
        configureDefaultMenus(with: builder)
        buildCustomMenus(with: builder)
        hideAbsentDefaultMenus(with: builder)
    }
    
    private func configureDefaultMenus(with builder: UIMenuBuilder) {
        let presentMenus = getPresentDefaultMenus()
        let menuItems = getDefaultMenuItems()
        
        print("\(logTag) menus: configure defaults for ids=\(presentMenus)")
        
        for menuId in presentMenus {
            if let items = menuItems[menuId] {
                configureDefaultMenu(with: builder, menuId: menuId, items: items)
            }
        }
    }
    
    private func configureDefaultMenu(with builder: UIMenuBuilder, menuId: String, items: [[String: Any]]) {
        print("\(logTag) menus: configure \(menuId) count=\(items.count)")
        
        let menuElements = buildMenuElements(from: items)
        
        guard !menuElements.isEmpty else {
            return
        }
        
        let customMenu = UIMenu(
            title: "",
            options: [.displayInline],
            children: menuElements
        )
        
        switch menuId {
        case "application":
            builder.insertChild(customMenu, atStartOfMenu: .application)
        case "file":
            builder.insertChild(customMenu, atStartOfMenu: .file)
        case "window":
            break
        case "help":
            builder.insertChild(customMenu, atStartOfMenu: .help)
        case "edit":
            builder.replaceChildren(ofMenu: .edit) { _ in customMenu.children }
        case "format":
            builder.replaceChildren(ofMenu: .format) { _ in customMenu.children }
        case "view":
            builder.replaceChildren(ofMenu: .view) { _ in customMenu.children }
        default:
            print("Unknown default menu ID: \(menuId)")
        }
    }
    
    private func hideAbsentDefaultMenus(with builder: UIMenuBuilder) {
        let presentMenus = Set(getPresentDefaultMenus())
        let allDefaultMenus: Set<String> = ["file", "edit", "format", "view", "toolbar"]
        let menusToHide = allDefaultMenus.subtracting(presentMenus)
        
        print("\(logTag) menus: hiding absent=\(menusToHide)")
        
        for menuId in menusToHide {
            hideDefaultMenu(with: builder, menuId: menuId)
        }
    }
    
    private func buildCustomMenus(with builder: UIMenuBuilder) {
        let customMenus = getCustomMenus()
        print("\(logTag) menus: building custom menus (count=\(customMenus.count))")
        
        for menuData in customMenus {
            guard let title = menuData["label"] as? String,
                  let children = menuData["children"] as? [[String: Any]] else {
                continue
            }
            
            print("\(logTag) menus: custom '\(title)'")
            
            let menuElements = buildMenuElements(from: children)
            if !menuElements.isEmpty {
                let customMenu = UIMenu(title: title, children: menuElements)
                
                if insertCustomMenuInCorrectPosition(builder: builder, menu: customMenu) {
                    print("\(logTag) menus: added custom '\(title)'")
                } else {
                    print("\(logTag) menus: failed to add '\(title)'")
                }
            }
        }
    }
    
    private func insertCustomMenuInCorrectPosition(builder: UIMenuBuilder, menu: UIMenu) -> Bool {
        if builder.menu(for: .view) != nil {
            builder.insertSibling(menu, afterMenu: .view)
            return true
        }
        
        if builder.menu(for: .format) != nil {
            builder.insertSibling(menu, afterMenu: .format)
            return true
        }
        
        if builder.menu(for: .edit) != nil {
            builder.insertSibling(menu, afterMenu: .edit)
            return true
        }
        
        if builder.menu(for: .file) != nil {
            builder.insertSibling(menu, afterMenu: .file)
            return true
        }
        
        if builder.menu(for: .window) != nil {
            builder.insertSibling(menu, beforeMenu: .window)
            return true
        }
        
        if builder.menu(for: .help) != nil {
            builder.insertSibling(menu, beforeMenu: .help)
            return true
        }
        
        print("Warning: Could not find suitable position for custom menu")
        return false
    }
    
    private func hideDefaultMenu(with builder: UIMenuBuilder, menuId: String) {
        switch menuId {
        case "file":
            builder.remove(menu: .file)
        case "edit":
            builder.remove(menu: .edit)
        case "format":
            builder.remove(menu: .format)
        case "view":
            builder.remove(menu: .view)
        case "toolbar":
            builder.remove(menu: .toolbar)
        default:
            print("Cannot hide menu: \(menuId) (AppInfo, Window and Help are protected)")
        }
    }
    
    private func buildMenuElements(from children: [[String: Any]]) -> [UIMenuElement] {
        var elements: [UIMenuElement] = []
        var usedKeyCommands: Set<String> = Set()
        
        for childData in children {
            if let type = childData["type"] as? String, type == "group" {
                if let groupChildren = childData["children"] as? [[String: Any]] {
                    let groupElements = buildMenuElements(from: groupChildren)
                    let dividerGroup = UIMenu(
                        title: "", options: [.displayInline], children: groupElements)
                    elements.append(dividerGroup)
                }
                continue
            }
            
            guard let title = childData["label"] as? String,
                  let id = childData["id"] as? Int else {
                continue
            }
            
            let enabled = childData["enabled"] as? Bool ?? true
            let iconImage = createImageFromBytes(childData["iconBytes"])
            let shortcut = childData["shortcut"] as? [String: Any]
            let menuItemState = parseMenuItemState(childData["state"])
            
            if let grandchildren = childData["children"] as? [[String: Any]], !grandchildren.isEmpty {
                let submenuElements = buildMenuElements(from: grandchildren)
                
                if !submenuElements.isEmpty {
                    let submenu = UIMenu(
                        title: title,
                        image: iconImage,
                        options: enabled ? [] : [.displayInline],
                        children: submenuElements
                    )
                    elements.append(submenu)
                }
            } else {
                if let shortcut = shortcut,
                   let input = shortcut["trigger"] as? String,
                   !input.isEmpty {
                    let modifiers = parseModifiers(shortcut["modifiers"])
                    let keyCommandIdentifier = "\(input)-\(modifiers.rawValue)"
                    if !usedKeyCommands.contains(keyCommandIdentifier) {
                        usedKeyCommands.insert(keyCommandIdentifier)
                        let keyCommand = UIKeyCommand(
                            title: title,
                            image: iconImage,
                            action: #selector(UIResponder.handleKeyCommand(_:)),
                            input: input, modifierFlags: modifiers,
                            propertyList: id,
                            attributes: enabled ? [] : [.disabled],
                            state: menuItemState
                        )
                        elements.append(keyCommand)
                    }
                } else {
                    let action = UIAction(
                        title: title,
                        image: iconImage,
                        attributes: enabled ? [] : [.disabled],
                        state: menuItemState
                    ) { [weak self] _ in
                        print("Menu action selected: \(title) (id: \(id))")
                        self?.performAction(id: id)
                    }
                    elements.append(action)
                }
            }
        }
        
        return elements
    }
    
    private func createImageFromBytes(_ iconBytesData: Any?) -> UIImage? {
        guard let iconBytes = iconBytesData as? FlutterStandardTypedData else {
            return nil
        }
        
        let data = Data(iconBytes.data)
        guard let image = UIImage(data: data) else {
            return nil
        }
        
        let templateImage = image.withRenderingMode(.alwaysTemplate)
        let targetSize = CGSize(width: 18, height: 18)
        
        UIGraphicsBeginImageContextWithOptions(targetSize, false, 0.0)
        UIColor.label.setFill()
        templateImage.draw(in: CGRect(origin: .zero, size: targetSize))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage?.withRenderingMode(.alwaysTemplate)
    }
    
    private func parseModifiers(_ modifiersData: Any?) -> UIKeyModifierFlags {
        guard let modifiersList = modifiersData as? [String] else {
            return []
        }
        
        var flags: UIKeyModifierFlags = []
        
        for modifier in modifiersList {
            switch modifier.lowercased() {
            case "shift":
                flags.insert(.shift)
            case "control":
                flags.insert(.control)
            case "alt", "option":
                flags.insert(.alternate)
            case "command", "meta":
                flags.insert(.command)
            default:
                break
            }
        }
        
        return flags
    }
    
    private func parseMenuItemState(_ stateData: Any?) -> UIMenuElement.State {
        guard let stateString = stateData as? String else {
            return .off
        }
        
        switch stateString.lowercased() {
        case "on":
            return .on
        case "off":
            return .off
        case "mixed":
            return .mixed
        default:
            return .off
        }
    }
}
