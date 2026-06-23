import Flutter
import UIKit

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
        return customMenus.reversed()
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

        guard !menuElements.isEmpty else { return }

        let customMenu = UIMenu(
            title: "",
            options: [.displayInline],
            children: menuElements
        )

        switch menuId {
        case "application":
            builder.insertChild(customMenu, atStartOfMenu: .application)
        // Have items with important native code, just add new items (for now)
        case "file":
            builder.insertChild(customMenu, atStartOfMenu: .file)
        case "window":
            // Do nothing in this case
            break
        case "help":
            builder.insertChild(customMenu, atStartOfMenu: .help)

        // In these cases, as there are no important predefined native functions, we replace all
        // their items to the ones made in dart
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
                let id = childData["id"] as? Int
            else {
                continue
            }

            let enabled = childData["enabled"] as? Bool ?? true
            let iconImage = createImageFromBytes(childData["iconBytes"])
            let displayedImage = applyDisabledAppearance(to: iconImage, enabled: enabled)
            let shortcut = childData["shortcut"] as? [String: Any]
            let menuItemState = parseMenuItemState(childData["state"])

            if let grandchildren = childData["children"] as? [[String: Any]], !grandchildren.isEmpty
            {
                let submenuElements = buildMenuElements(from: grandchildren)

                if !submenuElements.isEmpty {
                    let submenu = UIMenu(
                        title: title,
                        image: displayedImage,
                        options: enabled ? [] : [.displayInline],
                        children: submenuElements
                    )
                    elements.append(submenu)
                }
            } else {
                if let shortcut = shortcut,
                    let input = shortcut["trigger"] as? String,
                    !input.isEmpty
                {
                    let modifiers = parseModifiers(shortcut["modifiers"])
                    let keyCommandIdentifier = "\(input)-\(modifiers.rawValue)"
                    if !usedKeyCommands.contains(keyCommandIdentifier) {
                        usedKeyCommands.insert(keyCommandIdentifier)
                        let keyCommand = UIKeyCommand(
                            title: title,
                            image: displayedImage,
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
                        image: displayedImage,
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

        let targetSize = CGSize(width: 16, height: 16)
        guard let resizedImage = resizeImageWithQuality(image, targetSize: targetSize) else {
            return image.withRenderingMode(.alwaysOriginal)
        }
        return resizedImage.withRenderingMode(.alwaysOriginal)
    }

    private func applyDisabledAppearance(to image: UIImage?, enabled: Bool) -> UIImage? {
        guard let image = image else { return nil }
        if enabled { return image }
        // Draw the original image with reduced alpha to make it appear dimmed when disabled
        let targetSize = image.size
        let format = UIGraphicsImageRendererFormat.default()
        format.scale = image.scale
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
        let dimmed = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize), blendMode: .normal, alpha: 0.4)
        }
        return dimmed.withRenderingMode(.alwaysOriginal)
    }

    private func resizeImageWithQuality(_ image: UIImage?, targetSize: CGSize) -> UIImage? {
        guard let image = image else { return nil }

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = UIScreen.main.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)

        // Preserve aspect ratio and center within target rect
        let aspect = min(targetSize.width / image.size.width, targetSize.height / image.size.height)
        let newSize = CGSize(width: image.size.width * aspect, height: image.size.height * aspect)
        let origin = CGPoint(
            x: (targetSize.width - newSize.width) / 2.0,
            y: (targetSize.height - newSize.height) / 2.0
        )

        return renderer.image { _ in
            image.draw(in: CGRect(origin: origin, size: newSize))
        }
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

