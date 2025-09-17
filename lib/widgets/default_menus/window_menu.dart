// window_menu.dart
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
class IPadWindowMenu extends IPadMenu {
  @override
  String get menuId => 'window';

  /// Creates a window menu that sets the scene identifier for new windows.
  ///
  /// [entrypoint] specifies the scene ID (e.g., 'SecondScene') for new windows.
  /// If not provided, defaults to 'MainScene'.
  IPadWindowMenu({this.entrypoint})
    : super(
        label: 'Window',
        menus: [
          // Add a dummy invisible item to satisfy Flutter's validation
          PlatformMenuItem(
            label: '', // Empty label - won't be shown in native menu
            onSelected: null, // No action - native items handle this
          ),
        ],
      );

  /// The scene identifier to use when opening new windows.
  /// This value is automatically passed to the Swift side by the delegate.
  final String? entrypoint;
}
