import Flutter
import UIKit

import Flutter
import UIKit

public class IpadOSMenubarPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var customMenus: [[String: Any]] = []
    private var presentDefaultMenus: [String] = []
    private var defaultMenuItems: [String: [[String: Any]]] = [:]

    // MAKE THIS @objc AND PUBLIC for AppDelegate access
    @objc public var windowEntrypoint: String? = nil

    // Public method to get current entrypoint - easier for AppDelegate to call

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

        print("[IpadOSMenubarPlugin] registered successfully")
    }

    private func setupMenuDelegate() {
        if UIApplication.shared.connectedScenes.first is UIWindowScene {
            menuBuilderDelegate = MenuBuilderDelegate(plugin: self)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("\(logTag) handle: method=\(call.method)")

        switch call.method {
        case "Menu.setMenus":
            if let args = call.arguments as?  [String: Any] {
                print("\(logTag) Menu.setMenus received (customMenus=\((args["customMenus"] as?  [[String: Any]])?.count ?? 0), defaultMenus=\((args["defaultMenus"] as?  [String])?.count ?? 0), defaultMenuItemsKeys=\((args["defaultMenuItems"] as?  [String: [[String: Any]]])?.keys.count ?? 0))")

                if let customMenusData = args["customMenus"] as?  [[String: Any]] {
                    self.customMenus = customMenusData
                    print("\(logTag) customMenus count=\(customMenusData.count)")
                }

                if let defaultMenusData = args["defaultMenus"] as?  [String] {
                    self.presentDefaultMenus = defaultMenusData
                    print("\(logTag) presentDefaultMenus ids=\(defaultMenusData)")
                }

                if let defaultItemsData = args["defaultMenuItems"] as?  [String: [[String: Any]]] {
                    self.defaultMenuItems = defaultItemsData
                    print("\(logTag) defaultMenuItems keys=\(Array(defaultItemsData.keys))")
                }

                // Store the window entrypoint from Dart
                if let entrypoint = args["windowEntrypoint"] as? String {
                    self.windowEntrypoint = entrypoint
                    print("\(logTag) windowEntrypoint set to: \(entrypoint)")

                    // NEW: Try multiple ways to set it in AppDelegate
                    self.setGlobalEntrypoint(entrypoint)
                } else {
                    self.windowEntrypoint = nil
                    print("\(logTag) no windowEntrypoint provided; using defaults")

                    // NEW: Clear global entrypoint too
                    self.setGlobalEntrypoint(nil)
                }

                DispatchQueue.main.async {
                    self.rebuildMenus()
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

        NotificationCenter.default.post(
            name: NSNotification.Name("FlutterMenusChanged"),
            object: self,
            userInfo: [
                "customMenus": customMenus,
                "presentDefaultMenus": presentDefaultMenus,
                "defaultMenuItems": defaultMenuItems,
            ]
        )
    }

    public func getCustomMenus() -> [[String: Any]] {
        return customMenus.reversed()
    }

    public func getPresentDefaultMenus() -> [String] {
        return presentDefaultMenus
    }

    public func getDefaultMenuItems() -> [String: [[String: Any]]] {
        return defaultMenuItems
    }

    public func performAction(id: Int) {
        print("\(logTag) performAction id=\(id)")
        channel.invokeMethod("Menu.selectedCallback", arguments: id)
    }

    private func setGlobalEntrypoint(_ entrypoint: String?) {
        print("\(logTag) sending entrypoint notification: \(String(describing: entrypoint))")

        // Send notification to AppDelegate
        let userInfo: [String: Any] = entrypoint != nil ? ["entrypoint": entrypoint!]: [:]
        NotificationCenter.default.post(
            name: NSNotification.Name("EntrypointUpdated"),
            object: self,
            userInfo: userInfo
        )

        print("\(logTag) notification sent successfully")
    }
}


private class MenuBuilderDelegate {
    weak var plugin: IpadOSMenubarPlugin?

    init(plugin: IpadOSMenubarPlugin) {
        self.plugin = plugin
        setupMenuInterception()
    }

    private func setupMenuInterception() {
        let originalSelector = #selector (UIResponder.buildMenu (with:))
        let swizzledSelector = #selector (UIResponder.swizzled_buildMenu (with:))

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

    // Has to be inside UIResponder or else no UIKeyCommand will ever work

    @objc func handleKeyCommand(_ sender: UIKeyCommand) {
        if let id = sender.propertyList as? Int {
            // Call using plugin's singleton
            IpadOSMenubarPlugin.shared?.performAction(id: id)
        }
    }
}

extension IpadOSMenubarPlugin {
    func buildAllMenus(with builder: UIMenuBuilder) {
        print("\(logTag) rebuild: building all menus")

        // Configure default menus based on what's present in the widget tree
        configureDefaultMenus(with: builder)

        // Build custom menus
        buildCustomMenus(with: builder)

        // Hide menus that are not present in the widget tree
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

        // Have items with important native code, just add new items (for now)
        case "file":
            builder.insertChild(customMenu, atStartOfMenu: .file)
        case "window":
            // Don't add custom items here
            //builder.insertChild(customMenu, atStartOfMenu: .window)
            break
        case "help":
            builder.insertChild(customMenu, atStartOfMenu: .help)

        // In these cases, as there are no important predefined native functions, we replace all
        // their items to the ones made in dart
        case "edit":
            builder.replaceChildren(ofMenu: .edit) {
                _ in customMenu.children
            }
        case "format":
            builder.replaceChildren(ofMenu: .format) {
                _ in customMenu.children
            }
        case "view":
            builder.replaceChildren(ofMenu: .view) {
                _ in customMenu.children
            }
        default:
            print("Unknown default menu ID: \(menuId)")
        }
    }

    private func hideAbsentDefaultMenus(with builder: UIMenuBuilder) {
        let presentMenus = Set(getPresentDefaultMenus())
        let allDefaultMenus: Set<String> = ["file", "edit", "format", "view", "toolbar"]

        // Hide menus that are not present in the widget tree
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
            let children = menuData["children"] as?  [[String: Any]] else {
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
        // Correct order based on Apple HIG: AppInfo, File, Edit, Format, View, [CUSTOM], Window, Help

        // First try after the View menu
        if builder.menu(for: .view) != nil {
            builder.insertSibling(menu, afterMenu: .view)
            return true
        }

        // If View doesn't exist, add after Format menu
        if builder.menu(for: .format) != nil {
            builder.insertSibling(menu, afterMenu: .format)
            return true
        }

        // And so on...
        if builder.menu(for: .edit) != nil {
            builder.insertSibling(menu, afterMenu: .edit)
            return true
        }

        if builder.menu(for: .file) != nil {
            builder.insertSibling(menu, afterMenu: .file)
            return true
        }

        // As last resort, add it before the Window menu
        if builder.menu(for: .window) != nil {
            builder.insertSibling(menu, beforeMenu: .window)
            return true
        }

        // Shouldn't even get here, but just in case
        if builder.menu(for: .help) != nil {
            builder.insertSibling(menu, beforeMenu: .help)
            return true
        }

        print("Warning: Could not find suitable position for custom menu")
        return false
    }

    // Only allow hiding certain menus. AppInfo, Window and Help are protected

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
                if let groupChildren = childData["children"] as?  [[String: Any]] {
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
            let shortcut = childData["shortcut"] as?  [String: Any]
            let menuItemState = parseMenuItemState(childData["state"])

            if let grandchildren = childData["children"] as?  [[String: Any]], !grandchildren.isEmpty {
                let submenuElements = buildMenuElements(from: grandchildren)

                if !submenuElements.isEmpty {
                    let submenu = UIMenu(
                        title: title,
                        image: iconImage,
                        options: enabled ? []: [.displayInline],
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
                            action: #selector (UIResponder.handleKeyCommand (_:)),
                            input: input, modifierFlags: modifiers,
                            propertyList: id,
                            attributes: enabled ? []: [.disabled],
                            state: menuItemState

                        )
                        elements.append(keyCommand)
                    }
                } else {
                    let action = UIAction(
                        title: title,
                        image: iconImage,
                        attributes: enabled ? []: [.disabled],
                        state: menuItemState

                    ) {
                        [weak self] _ in
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

    private func createSystemColoredImage(from originalImage: UIImage?) -> UIImage? {
        guard let image = originalImage else {
            return nil
        }

        return image.withTintColor(.label, renderingMode: .alwaysTemplate)
    }

    private func resizeImageWithQuality(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else {
            return nil
        }

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image {
            _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }

    private func parseModifiers(_ modifiersData: Any?) -> UIKeyModifierFlags {
        guard let modifiersList = modifiersData as?  [String] else {
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

