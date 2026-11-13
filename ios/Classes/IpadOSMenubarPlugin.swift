import Flutter
import UIKit

/// Native side of the `ipados_menu_bar` plugin.
///
/// One instance exists per `FlutterEngine`. Each instance keeps the menus sent
/// by its own engine; the menu bar shows the menus of the instance whose
/// window scene has focus, and menu actions are delivered to that engine.
public class IpadOSMenubarPlugin: NSObject, FlutterPlugin, IpadOSMenuHostApi {
    private weak var registrar: FlutterPluginRegistrar?
    private var flutterApi: IpadOSMenuFlutterApi?
    fileprivate var configuration: NativeMenuConfiguration?

    /// Identifies this instance inside the `propertyList` of key commands.
    fileprivate let token: Int

    private static var nextToken = 0

    /// The plugin instance of the window scene that currently has focus.
    @available(*, deprecated, message: "There is one plugin instance per FlutterEngine. Use `focused` instead.")
    public static var shared: IpadOSMenubarPlugin? { focused }

    /// The plugin instance whose window scene currently has focus, if any.
    public static var focused: IpadOSMenubarPlugin? {
        MenuFocusCoordinator.shared.resolveFocusedOrLast()
    }

    /// Dart entrypoint that the focused window asked to use for new windows
    /// (`IPadWindowMenu.entrypoint`), or `nil` to use the default one.
    @objc public static var focusedWindowEntrypoint: String? {
        MenuFocusCoordinator.shared.resolveFocusedOrLast()?.configuration?.windowEntrypoint
    }

    /// Entrypoint arguments that the focused window asked to hand to new
    /// windows: a single JSON string built from `IPadWindowMenu.arguments`.
    @objc public static var focusedWindowEntrypointArguments: [String]? {
        guard
            let json = MenuFocusCoordinator.shared.resolveFocusedOrLast()?.configuration?
                .windowArguments
        else { return nil }
        return [json]
    }

    /// The window scene displaying the Flutter view of this instance's engine.
    ///
    /// `nil` while the engine has no view controller, or its view is not in a
    /// window yet.
    public var windowScene: UIWindowScene? {
        registrar?.viewController?.viewIfLoaded?.window?.windowScene
    }

    private init(registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        IpadOSMenubarPlugin.nextToken += 1
        token = IpadOSMenubarPlugin.nextToken
        flutterApi = IpadOSMenuFlutterApi(binaryMessenger: registrar.messenger())
        super.init()
    }

    /// Creates the plugin instance of the engine behind `registrar`.
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = IpadOSMenubarPlugin(registrar: registrar)
        IpadOSMenuHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: instance)
        registrar.publish(instance)
        MenuFocusCoordinator.shared.add(instance)
    }

    /// Drops the menus of an engine that is going away, e.g. because its
    /// window was closed.
    public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
        IpadOSMenuHostApiSetup.setUp(binaryMessenger: registrar.messenger(), api: nil)
        flutterApi = nil
        configuration = nil
        MenuFocusCoordinator.shared.remove(self)
    }

    func setMenus(configuration: NativeMenuConfiguration) throws {
        self.configuration = configuration
        MenuFocusCoordinator.shared.menusChanged(for: self)
    }

    func getAvailableDefaultMenus() throws -> [String: String] {
        return [
            "file": "File Menu",
            "edit": "Edit Menu",
            "format": "Format Menu",
            "view": "View Menu",
            "window": "Window Menu",
            "help": "Help Menu",
        ]
    }

    func performAction(id: Int) {
        guard let flutterApi = flutterApi else { return }
        Task { @MainActor in
            do {
                try await flutterApi.menuSelected(id: Int64(id))
            } catch {
                menuLog("Failed to report menu selection \(id): \(error)")
            }
        }
    }
}

/// Logs `message` in debug builds only.
func menuLog(_ message: @autoclosure () -> String) {
    #if DEBUG
        NSLog("[ipados_menu_bar] %@", message())
    #endif
}

/// Tracks every live plugin instance and which of them owns the menu bar.
final class MenuFocusCoordinator {
    static let shared = MenuFocusCoordinator()

    private let instances = NSHashTable<IpadOSMenubarPlugin>.weakObjects()
    private weak var current: IpadOSMenubarPlugin?
    private weak var lastFocused: IpadOSMenubarPlugin?
    private weak var lastFocusedScene: UIWindowScene?
    private let observedScenes = NSHashTable<UIWindowScene>.weakObjects()
    private var installed = false

    func add(_ instance: IpadOSMenubarPlugin) {
        instances.add(instance)
        installIfNeeded()
    }

    func remove(_ instance: IpadOSMenubarPlugin) {
        instances.remove(instance)
        refresh(reason: "detach")
    }

    func instance(withToken token: Int) -> IpadOSMenubarPlugin? {
        instances.allObjects.first { $0.token == token }
    }

    func menusChanged(for instance: IpadOSMenubarPlugin) {
        DispatchQueue.main.async {
            self.observeTraits()
            if self.resolveFocusedOrLast() === instance {
                self.current = instance
                UIMenuSystem.main.setNeedsRebuild()
            }
        }
    }

    private func installIfNeeded() {
        guard !installed else { return }
        installed = true

        let original = #selector(UIResponder.buildMenu(with:))
        let swizzled = #selector(UIResponder.ipadosMenuBar_buildMenu(with:))
        if let originalMethod = class_getInstanceMethod(UIResponder.self, original),
            let swizzledMethod = class_getInstanceMethod(UIResponder.self, swizzled)
        {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }

        let center = NotificationCenter.default
        let names: [Notification.Name] = [
            UIScene.didActivateNotification,
            UIScene.willDeactivateNotification,
            UIScene.didDisconnectNotification,
            UIScene.didEnterBackgroundNotification,
            UIScene.willEnterForegroundNotification,
        ]
        for name in names {
            center.addObserver(
                self, selector: #selector(focusMayHaveChanged(_:)), name: name, object: nil)
        }
    }

    @objc private func focusMayHaveChanged(_ notification: Notification) {
        observeTraits()
        // Scene state and traits settle after the notification is delivered.
        DispatchQueue.main.async {
            self.refresh(reason: notification.name.rawValue)
        }
    }

    /// Watches the active appearance of every connected window scene: it is
    /// the only signal UIKit gives when focus moves between two scenes that
    /// are both in the foreground.
    private func observeTraits() {
        guard #available(iOS 17.0, *) else { return }
        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene,
                !observedScenes.contains(windowScene)
            else { continue }
            observedScenes.add(windowScene)
            // Always called on the main thread, by UIKit or from the main queue.
            MainActor.assumeIsolated {
                _ = windowScene.registerForTraitChanges([UITraitActiveAppearance.self]) {
                    [weak self] (_: UIWindowScene, _: UITraitCollection) in
                    self?.refresh(reason: "activeAppearance")
                }
            }
        }
    }

    private func describeState() -> String {
        UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.map { scene in
            var appearance = -1
            if #available(iOS 14.0, *) {
                appearance = scene.traitCollection.activeAppearance.rawValue
            }
            let engine = instances.allObjects.first { $0.windowScene === scene }
            return
                "\(scene.session.persistentIdentifier.prefix(6)):state=\(scene.activationState.rawValue),active=\(appearance),engine=#\(engine?.token ?? -1)"
        }.joined(separator: " ")
    }

    /// The window scene that currently has focus.
    ///
    /// Several scenes can be `foregroundActive` at once (Stage Manager,
    /// windowed apps, Split View), each with its own key window, so neither
    /// tells them apart. Only the focused one has an active appearance.
    func focusedScene() -> UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        let active = scenes.filter { $0.activationState == .foregroundActive }

        var focused = active
        if #available(iOS 14.0, *) {
            focused = active.filter { $0.traitCollection.activeAppearance == .active }
        }
        if focused.count == 1 { return focused[0] }

        // None or several candidates: traits are briefly stale while focus
        // moves, and nothing took focus yet. The scene that had it keeps it
        // while it stays on screen, e.g. while it is briefly inactive because
        // the system is opening a new window from it. The trait observer
        // runs again as soon as the traits settle.
        let last = lastFocusedScene
        if let last = last,
            last.activationState == .foregroundActive
                || last.activationState == .foregroundInactive,
            scenes.contains(where: { $0 === last })
        {
            return last
        }
        return active.count == 1 ? active[0] : nil
    }

    func resolveFocused() -> IpadOSMenubarPlugin? {
        let all = instances.allObjects
        if let scene = focusedScene() {
            lastFocusedScene = scene
            // A focused scene without Flutter content shows no Flutter menus.
            return all.first { $0.windowScene === scene }
        }
        // An app with a single engine keeps working even when the engine is
        // not attached to a window scene yet.
        if all.count == 1, all[0].windowScene == nil { return all[0] }
        return nil
    }

    /// The focused instance or, while no scene has focus (a scene is being
    /// opened, closed or switched), the one that had it last.
    func resolveFocusedOrLast() -> IpadOSMenubarPlugin? {
        if let focused = resolveFocused() {
            lastFocused = focused
            return focused
        }
        if focusedScene() != nil { return nil }
        return lastFocused
    }

    func refresh(reason: String) {
        let focused = resolveFocusedOrLast()
        guard focused !== current else { return }
        menuLog(
            "focus #\(current?.token ?? -1) -> #\(focused?.token ?? -1) (\(reason)) \(describeState())")
        current = focused
        UIMenuSystem.main.setNeedsRebuild()
    }

    func buildMenus(with builder: UIMenuBuilder) {
        let focused = resolveFocusedOrLast()
        current = focused
        focused?.buildAllMenus(with: builder)
    }
}

extension UIResponder {
    @objc func ipadosMenuBar_buildMenu(with builder: UIMenuBuilder) {
        // Calls the original implementation: the methods are exchanged.
        ipadosMenuBar_buildMenu(with: builder)

        guard builder.system == .main else { return }
        MenuFocusCoordinator.shared.buildMenus(with: builder)
    }

    // Has to be inside UIResponder or else no UIKeyCommand will ever work
    @objc func handleKeyCommand(_ sender: UIKeyCommand) {
        guard let info = sender.propertyList as? [String: Int],
            let token = info["engine"], let id = info["id"]
        else { return }
        MenuFocusCoordinator.shared.instance(withToken: token)?.performAction(id: id)
    }
}

extension IpadOSMenubarPlugin {
    func buildAllMenus(with builder: UIMenuBuilder) {
        guard let configuration = configuration else { return }

        // Configure default menus based on what's present in the widget tree
        configureDefaultMenus(with: builder, configuration: configuration)

        // Build custom menus
        buildCustomMenus(with: builder, configuration: configuration)

        // Hide menus that are not present in the widget tree
        hideAbsentDefaultMenus(with: builder, configuration: configuration)
    }

    private func configureDefaultMenus(
        with builder: UIMenuBuilder, configuration: NativeMenuConfiguration
    ) {
        let presentMenus = configuration.defaultMenus
        let menuItems = configuration.defaultMenuItems

        for menuId in presentMenus {
            if let items = menuItems[menuId] {
                configureDefaultMenu(with: builder, menuId: menuId, items: items)
            }
        }
    }

    private func configureDefaultMenu(
        with builder: UIMenuBuilder, menuId: String, items: [NativeMenuItem]
    ) {
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
            menuLog("Unknown default menu ID: \(menuId)")
        }
    }

    private func hideAbsentDefaultMenus(
        with builder: UIMenuBuilder, configuration: NativeMenuConfiguration
    ) {
        let presentMenus = Set(configuration.defaultMenus)
        let allDefaultMenus: Set<String> = ["file", "edit", "format", "view", "toolbar"]

        // Hide menus that are not present in the widget tree
        let menusToHide = allDefaultMenus.subtracting(presentMenus)

        for menuId in menusToHide {
            hideDefaultMenu(with: builder, menuId: menuId)
        }
    }

    private func buildCustomMenus(
        with builder: UIMenuBuilder, configuration: NativeMenuConfiguration
    ) {
        // Reversed to keep the Dart order: each menu is inserted at the same anchor
        let customMenus = configuration.customMenus.reversed()

        for menuData in customMenus {
            guard let title = menuData.label else {
                continue
            }

            let menuElements = buildMenuElements(from: menuData.children)
            if !menuElements.isEmpty {
                let customMenu = UIMenu(title: title, children: menuElements)

                insertCustomMenuInCorrectPosition(builder: builder, menu: customMenu)
            }
        }
    }

    @discardableResult
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

        menuLog("Warning: Could not find suitable position for custom menu")
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
            menuLog("Cannot hide menu: \(menuId) (AppInfo, Window and Help are protected)")
        }
    }

    private func buildMenuElements(from children: [NativeMenuItem]) -> [UIMenuElement] {
        var elements: [UIMenuElement] = []
        var usedKeyCommands: Set<String> = Set()

        for childData in children {
            if childData.isGroup {
                let groupElements = buildMenuElements(from: childData.children)
                let dividerGroup = UIMenu(
                    title: "", options: [.displayInline], children: groupElements)
                elements.append(dividerGroup)
                continue
            }

            guard let title = childData.label,
                let nativeId = childData.id
            else {
                continue
            }
            let id = Int(nativeId)

            let enabled = childData.enabled
            let iconImage = createImageFromBytes(childData.iconBytes)
            let displayedImage = applyDisabledAppearance(to: iconImage, enabled: enabled)
            let shortcut = childData.shortcut
            let menuItemState = parseMenuItemState(childData.state)

            if !childData.children.isEmpty {
                let submenuElements = buildMenuElements(from: childData.children)

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
                if let shortcut = shortcut, !shortcut.trigger.isEmpty {
                    let input = shortcut.trigger
                    let modifiers = parseModifiers(shortcut.modifiers)
                    let keyCommandIdentifier = "\(input)-\(modifiers.rawValue)"
                    if !usedKeyCommands.contains(keyCommandIdentifier) {
                        usedKeyCommands.insert(keyCommandIdentifier)
                        let keyCommand = UIKeyCommand(
                            title: title,
                            image: displayedImage,
                            action: #selector(UIResponder.handleKeyCommand(_:)),
                            input: input, modifierFlags: modifiers,
                            propertyList: ["engine": token, "id": id],
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
                        self?.performAction(id: id)
                    }
                    elements.append(action)
                }
            }
        }

        return elements
    }

    private func createImageFromBytes(_ iconBytes: FlutterStandardTypedData?) -> UIImage? {
        guard let iconBytes = iconBytes else {
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

    private func parseModifiers(_ modifiersList: [NativeMenuModifier]) -> UIKeyModifierFlags {
        var flags: UIKeyModifierFlags = []

        for modifier in modifiersList {
            switch modifier {
            case .shift:
                flags.insert(.shift)
            case .control:
                flags.insert(.control)
            case .alt:
                flags.insert(.alternate)
            case .meta:
                flags.insert(.command)
            }
        }

        return flags
    }

    private func parseMenuItemState(_ state: NativeMenuState?) -> UIMenuElement.State {
        switch state {
        case .on:
            return .on
        case .mixed:
            return .mixed
        case .off, .none:
            return .off
        }
    }
}
