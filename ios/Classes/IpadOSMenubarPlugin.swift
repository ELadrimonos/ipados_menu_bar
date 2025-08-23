import Flutter
import UIKit

// TODO Investigar UIMenu image para pasar IconData
public class IpadOSMenubarPlugin: NSObject, FlutterPlugin {
    private var channel: FlutterMethodChannel!
    private var customMenus: [[String: Any]] = []
    private var presentDefaultMenus: [String] = []
    private var defaultMenuItems: [String: [[String: Any]]] = [:]

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

        print("IpadOSMenubarPlugin registered successfully")
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
            if let args = call.arguments as? [String: Any] {
                print("Received menu data: \(args)")

                if let customMenusData = args["customMenus"] as? [[String: Any]] {
                    self.customMenus = customMenusData
                    print("Custom menus: \(customMenusData.count)")
                }

                if let defaultMenusData = args["defaultMenus"] as? [String] {
                    self.presentDefaultMenus = defaultMenusData
                    print("Present default menus: \(defaultMenusData)")
                }

                if let defaultItemsData = args["defaultMenuItems"] as? [String: [[String: Any]]] {
                    self.defaultMenuItems = defaultItemsData
                    print("Default menu items keys: \(defaultItemsData.keys)")
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
        return customMenus
    }

    public func getPresentDefaultMenus() -> [String] {
        return presentDefaultMenus
    }

    public func getDefaultMenuItems() -> [String: [[String: Any]]] {
        return defaultMenuItems
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

        print("Configuring default menus. Present: \(presentMenus)")

        for menuId in presentMenus {
            if let items = menuItems[menuId] {
                configureDefaultMenu(with: builder, menuId: menuId, items: items)
            }
        }
    }

    private func configureDefaultMenu(
        with builder: UIMenuBuilder, menuId: String, items: [[String: Any]]
    ) {
        print("Configuring \(menuId) menu with \(items.count) items")

        let menuElements = buildMenuElements(from: items)

        if !menuElements.isEmpty {
            let customMenu = UIMenu(
                title: "",
                options: [.displayInline],
                children: menuElements
            )

            switch menuId {
            case "file":
                builder.insertChild(customMenu, atStartOfMenu: .file)
            case "edit":
                builder.insertChild(customMenu, atStartOfMenu: .edit)
            case "format":
                builder.insertChild(customMenu, atStartOfMenu: .format)
            case "view":
                builder.insertChild(customMenu, atStartOfMenu: .view)
            case "window":
                builder.insertChild(customMenu, atStartOfMenu: .window)
            case "help":
                builder.insertChild(customMenu, atStartOfMenu: .help)
            default:
                print("Unknown default menu ID: \(menuId)")
            }
        }
    }

    private func hideAbsentDefaultMenus(with builder: UIMenuBuilder) {
        let presentMenus = Set(getPresentDefaultMenus())
        let allDefaultMenus: Set<String> = ["file", "edit", "format", "view", "toolbar"]

        // Hide menus that are not present in the widget tree
        let menusToHide = allDefaultMenus.subtracting(presentMenus)

        print("Hiding absent default menus: \(menusToHide)")

        for menuId in menusToHide {
            hideDefaultMenu(with: builder, menuId: menuId)
        }
    }

    private func buildCustomMenus(with builder: UIMenuBuilder) {
        print("Building custom Flutter menus...")

        let customMenus = getCustomMenus()

        for menuData in customMenus {
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

                // UIImage here for items that open submenus
                if !submenuElements.isEmpty {
                    let submenu = UIMenu(
                        title: title,
                        image: UIImage(systemName: "moon"),

                        options: enabled ? [] : [.displayInline],
                        children: submenuElements
                    )
                    elements.append(submenu)
                }
            } else {
                // UIImage here for items that don't open a submenu
                let action = UIAction(
                    title: title,
                    image: UIImage(systemName: "trash"),
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