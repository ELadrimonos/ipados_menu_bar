import Flutter
import UIKit

public class IpadOSMenubarPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var menuModel: [[String: Any]] = []
    private var defaultMenusConfig: [String: Any] = [:]
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

        print("IpadOs26MenubarPlugin registered successfully")
    }

    private func setupMenuDelegate() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            menuBuilderDelegate = MenuBuilderDelegate(plugin: self)
        }
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("Method called: \(call.method)")

        switch call.method {
        case "Menu.setMenus":
            if let args = call.arguments as? [String: Any],
                let menus = args["0"] as? [[String: Any]]
            {
                print("Received custom menus: \(menus)")
                self.menuModel = menus

                DispatchQueue.main.async {
                    self.rebuildMenus()
                }
                result(nil)
            } else {
                result(FlutterError(code: "bad_args", message: "Invalid arguments", details: nil))
            }

        case "Menu.configureDefaultMenus":
            if let config = call.arguments as? [String: Any] {
                print("Received default menus config: \(config)")
                self.defaultMenusConfig = config

                DispatchQueue.main.async {
                    self.rebuildMenus()
                }
                result(nil)
            } else {
                result(FlutterError(code: "bad_args", message: "Invalid config", details: nil))
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
            userInfo: ["menus": menuModel, "defaultConfig": defaultMenusConfig]
        )
    }

    public func currentMenus() -> [[String: Any]] {
        return menuModel
    }

    public func getDefaultMenusConfig() -> [String: Any] {
        return defaultMenusConfig
    }

    public func performAction(id: Int) {
        print("Performing action for id: \(id)")
        channel.invokeMethod("Menu.selectedCallback", arguments: id)
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
            let swizzledMethod = class_getInstanceMethod(UIResponder.self, swizzledSelector)
        else {
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
}

extension IpadOSMenubarPlugin {
    func buildAllMenus(with builder: UIMenuBuilder) {
        print("Building all menus...")

        configureDefaultMenus(with: builder)

        buildCustomMenus(with: builder)
    }

    private func configureDefaultMenus(with builder: UIMenuBuilder) {
        let config = getDefaultMenusConfig()
        print("Configuring default menus with config: \(config)")

        if let fileConfig = config["file"] as? [String: Any] {
            configureFileMenu(with: builder, config: fileConfig)
        }

        if let editConfig = config["edit"] as? [String: Any] {
            configureEditMenu(with: builder, config: editConfig)
        }

        if let formatConfig = config["format"] as? [String: Any] {
            configureFormatMenu(with: builder, config: formatConfig)
        }

        if let viewConfig = config["view"] as? [String: Any] {
            configureViewMenu(with: builder, config: viewConfig)
        }

        if let windowConfig = config["window"] as? [String: Any] {
            configureWindowMenu(with: builder, config: windowConfig)
        }

        if let helpConfig = config["help"] as? [String: Any] {
            configureHelpMenu(with: builder, config: helpConfig)
        }

        // Handle menus that want to be hidden
        if let hiddenMenus = config["hidden"] as? [String] {
            for menuId in hiddenMenus {
                hideDefaultMenu(with: builder, menuId: menuId)
            }
        }
    }

    private func configureFileMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let fileMenuElements = buildMenuElements(from: additionalItems)

            if !fileMenuElements.isEmpty {
                let customFileMenu = UIMenu(
                    title: "", options: [.displayInline], children: fileMenuElements)
                builder.insertChild(customFileMenu, atStartOfMenu: .file)
            }
        }
    }

    private func configureEditMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let editMenuElements = buildMenuElements(from: additionalItems)

            if !editMenuElements.isEmpty {
                let customEditMenu = UIMenu(
                    title: "", options: [.displayInline], children: editMenuElements)
                builder.insertChild(customEditMenu, atStartOfMenu: .edit)
            }
        }
    }

    private func configureFormatMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let formatMenuElements = buildMenuElements(from: additionalItems)

            if !formatMenuElements.isEmpty {
                let customFormatMenu = UIMenu(
                    title: "", options: [.displayInline], children: formatMenuElements)
                builder.insertChild(customFormatMenu, atStartOfMenu: .format)
            }
        }
    }

    private func configureViewMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let viewMenuElements = buildMenuElements(from: additionalItems)

            if !viewMenuElements.isEmpty {
                let customViewMenu = UIMenu(
                    title: "", options: [.displayInline], children: viewMenuElements)
                builder.insertChild(customViewMenu, atStartOfMenu: .view)
            }
        }
    }

    private func configureWindowMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let windowMenuElements = buildMenuElements(from: additionalItems)

            if !windowMenuElements.isEmpty {
                let customWindowMenu = UIMenu(
                    title: "", options: [.displayInline], children: windowMenuElements)
                builder.insertChild(customWindowMenu, atStartOfMenu: .window)
            }
        }
    }

    private func configureHelpMenu(with builder: UIMenuBuilder, config: [String: Any]) {
        if let additionalItems = config["additionalItems"] as? [[String: Any]] {
            let helpMenuElements = buildMenuElements(from: additionalItems)

            if !helpMenuElements.isEmpty {
                let customHelpMenu = UIMenu(
                    title: "", options: [.displayInline], children: helpMenuElements)
                builder.insertChild(customHelpMenu, atStartOfMenu: .help)
            }
        }
    }

    private func buildCustomMenus(with builder: UIMenuBuilder) {
        print("Building custom Flutter menus...")

        for menuData in menuModel {
            guard let title = menuData["label"] as? String,
                let children = menuData["children"] as? [[String: Any]]
            else {
                continue
            }

            print("Building custom menu: \(title)")

            let menuElements = buildMenuElements(from: children)
            if !menuElements.isEmpty {
                let customMenu = UIMenu(title: title, children: menuElements)

                if insertCustomMenuInCorrectPosition(builder: builder, menu: customMenu) {
                    print("Added custom menu: \(title)")
                } else {
                    print("Failed to add custom menu: \(title)")
                }
            }
        }
    }

    private func insertCustomMenuInCorrectPosition(builder: UIMenuBuilder, menu: UIMenu) -> Bool {
        // Correct order based on Apple HIG: AppInfo, File, Edit, Format, View, [CUSTOM], Window, Help
        // https://developer.apple.com/videos/play/wwdc2025/208/?time=648

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

    // Never allow to hide important items such as AppInfo, Window and Help
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
                let id = childData["id"] as? Int
            else {
                continue
            }

            let enabled = childData["enabled"] as? Bool ?? true

            if let grandchildren = childData["children"] as? [[String: Any]], !grandchildren.isEmpty
            {
                let submenuElements = buildMenuElements(from: grandchildren)

                if !submenuElements.isEmpty {
                    let submenu = UIMenu(
                        title: title,
                        options: enabled ? [] : [.displayInline],
                        children: submenuElements
                    )
                    elements.append(submenu)
                }
            } else {
                let action = UIAction(
                    title: title,
                    attributes: enabled ? [] : [.disabled]
                ) { [weak self] _ in
                    print("Menu action selected: \(title) (id: \(id))")
                    self?.performAction(id: id)
                }
                elements.append(action)
            }
        }

        return elements
    }
}