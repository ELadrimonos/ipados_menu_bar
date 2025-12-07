part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] that integrates with iPadOS native window management
/// and sets the scene identifier for new windows.
///
/// This menu registers the entrypoint scene identifier with the platform delegate
/// so that when a new window is opened from the native menu, it uses the correct scene.
///
/// ## Usage Example
///
/// ```dart
/// IPadWindowMenu(
///   entrypoint: 'SecondScene', // This will be used for new windows
/// )
/// ```
///
/// The delegate will automatically handle:
/// - Setting the scene ID in Swift when opening new windows
/// - Using the default "MainScene" if no entrypoint is specified
///
/// *Manual management of scenes inside AppDelegate is required*
class IPadWindowMenu extends IPadMenu {
  @override
  String get menuId => 'window';

  /// Creates a window menu that defines the scene identifier used when opening new windows.
  ///
  /// This constructor registers the `entrypoint` (scene identifier) with the platform delegate,
  /// allowing the operating system to correctly assign the new window to the specified scene.
  ///
  /// - [entrypoint]: The name of the scene that will be used when opening new windows (for example, `'SecondScene'`).
  ///   If not specified, `'MainScene'` is used as the default value.
  /// - [arguments]: An optional map containing additional arguments passed when creating the new window.
  /// - [additionalItems]: Extra menu items. These are not displayed on iOS but can be useful on other platforms
  ///   that require custom window management (for example, macOS or Windows).
  IPadWindowMenu({
    this.entrypoint,
    this.arguments,
    List<PlatformMenuItem>? additionalItems,
  }) : super(
         label: 'Window',
         menus: [
           if (additionalItems != null && additionalItems.isNotEmpty)
             PlatformMenuItemGroup(members: additionalItems),
           if (PlatformProvidedMenuItem.hasMenu(
             PlatformProvidedMenuItemType.minimizeWindow,
           ))
             const PlatformMenuItemGroup(
               members: [
                 PlatformProvidedMenuItem(
                   type: PlatformProvidedMenuItemType.minimizeWindow,
                 ),
               ],
             ),
           if (PlatformProvidedMenuItem.hasMenu(
             PlatformProvidedMenuItemType.zoomWindow,
           ))
             const PlatformMenuItemGroup(
               members: [
                 PlatformProvidedMenuItem(
                   type: PlatformProvidedMenuItemType.zoomWindow,
                 ),
               ],
             ),
           if (PlatformProvidedMenuItem.hasMenu(
             PlatformProvidedMenuItemType.toggleFullScreen,
           ))
             const PlatformMenuItemGroup(
               members: [
                 PlatformProvidedMenuItem(
                   type: PlatformProvidedMenuItemType.toggleFullScreen,
                 ),
               ],
             ),
           if (PlatformProvidedMenuItem.hasMenu(
             PlatformProvidedMenuItemType.arrangeWindowsInFront,
           ))
             const PlatformMenuItemGroup(
               members: [
                 PlatformProvidedMenuItem(
                   type: PlatformProvidedMenuItemType.arrangeWindowsInFront,
                 ),
               ],
             ),
           // Fallback: makes sure there's always 1 element so it doesn't crash
           if (![
                 PlatformProvidedMenuItemType.minimizeWindow,
                 PlatformProvidedMenuItemType.zoomWindow,
                 PlatformProvidedMenuItemType.toggleFullScreen,
                 PlatformProvidedMenuItemType.arrangeWindowsInFront,
               ].any(PlatformProvidedMenuItem.hasMenu) &&
               (additionalItems == null || additionalItems.isEmpty) &&
               defaultTargetPlatform != TargetPlatform.iOS)
             const PlatformMenuItem(label: 'No items'),
         ],
       );

  /// The scene identifier to use when opening new windows.
  /// This value is automatically passed to the Swift side by the delegate.
  final String? entrypoint;
  final Map<String, dynamic>? arguments;
}
