// window_menu.dart
part of '../../ipados_menu_bar.dart';

/// Custom [PlatformMenu] that integrates with iPadOS native window management
/// and provides callbacks for app-specific window operations.
/// 
/// This menu registers callbacks directly with the platform delegate for
/// native window actions without creating unnecessary menu items.
/// 
/// ## Usage Example
/// 
/// ```dart
/// IPadWindowMenu(
///   onNewWindow: () {
///     // Initialize new window with specific route or data
///     Navigator.of(context).pushNamed('/new-document');
///   },
///   onShowAllWindows: () {
///     // Optional: Log analytics or refresh content
///     _analyticsService.trackShowAllWindows();
///   },
/// )
/// ```
class IPadWindowMenu extends IPadMenu {
  @override
  String get menuId => 'window';

  /// Creates a window menu that registers callbacks for native window actions.
  /// 
  /// [onNewWindow] is called when the user selects "New Window" from the native menu.
  /// [onShowAllWindows] is called when the user selects "Show All Windows".
  IPadWindowMenu({
    VoidCallback? onNewWindow,
    VoidCallback? onShowAllWindows,
  }) : super(
    label: 'Window',
    menus: [], // Empty - we don't render any items
  ) {
    // Register callbacks directly with the delegate
    _registerWindowCallbacks(onNewWindow, onShowAllWindows);
  }

  void _registerWindowCallbacks(
      VoidCallback? onNewWindow,
      VoidCallback? onShowAllWindows,
      ) {
    // This will be called by the delegate when processing the menu
    final delegate = WidgetsBinding.instance.platformMenuDelegate;
    if (delegate is IPadOSPlatformMenuDelegate) {
      delegate.registerWindowCallbacks(
        onNewWindow: onNewWindow,
        onShowAllWindows: onShowAllWindows,
      );
    }
  }
}