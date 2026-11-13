## 0.7.0

- Replaced the hand-written `MethodChannel` payload with a typed [Pigeon](https://pub.dev/packages/pigeon) API (`pigeons/menu_api.dart`) shared by Dart and Swift
- **Breaking:** `IPadOSPlatformMenuDelegate.create` now takes `binaryMessenger` instead of `channel`
  - Run `dart fix --apply` to remove the old `channel` argument automatically (added `lib/fix_data.yaml`)
- `IPadOSPlatformMenuDelegate.setMenus` now returns a `Future<void>`
- Fixed `getAvailableDefaultMenus` always returning `null`
- Added unit tests for the menu delegate
- Fixed unresolved dartdoc references
- The package no longer imports `package:flutter/material.dart` or `package:flutter/cupertino.dart` (deprecated in Flutter 3.50 in favor of `material_ui` / `cupertino_ui`); it only depends on `flutter/widgets.dart`, so it stays agnostic of the UI design system
  - Default menu icons now ship as internal glyphs of the `cupertino_icons` font, which is a new dependency of the package (font asset only)
- Updated Pigeon to 30.0.2 and regenerated the Dart and Swift bindings
- Migrated the example apps to `material_ui` and `cupertino_ui`
- Added multi-window focus support: with several `UIScene`s, each running its own `FlutterEngine`, the menu bar now shows the menus of the focused window and menu actions are delivered to that window's engine
  - The iOS plugin keeps one instance and one set of menus per engine instead of a global "last engine wins" singleton; menus of a closed window are dropped with its engine
  - Focus is tracked through the active appearance of each window scene, so it also follows windows that are on screen at the same time (windowed apps, Stage Manager, Split View)
  - `IPadWindowMenu.entrypoint` and `IPadWindowMenu.arguments` are sent to the native side again; read them from your `AppDelegate` with the new `IpadOSMenubarPlugin.focusedWindowEntrypoint` and `IpadOSMenubarPlugin.focusedWindowEntrypointArguments` (a single JSON string) when configuring a new scene
  - **Breaking (Swift):** `IpadOSMenubarPlugin.shared` is deprecated and now returns the instance of the focused window; use `IpadOSMenubarPlugin.focused`
  - Reworked `example/multiple_windows_example` with one scene delegate per kind of window
- Fixed custom menus disappearing from the menu bar when their shortcuts collide with those of a system menu the widget tree does not use (e.g. ⌘T in Format > Font): absent default menus are now removed before the custom menus are inserted
- Fixed the `buildMenu` swizzling being undone when a second engine registered the plugin, and menus being injected into context menus

## 0.6.1

- Expanded dartdoc coverage across the public API (default menus, icon items, stateful items, `MenuItemState`, delegate, and library/helper docs)
- Optimized `preview.gif` to stay under pub.dev's 4 MB screenshot limit
- Removed the API Stability Notice from the README

## 0.6.0

- Added [Swift Package Manager (SPM)](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-plugin-authors) support for the iOS plugin
  - CocoaPods remains fully supported; the Flutter tool picks SPM when enabled and falls back to CocoaPods otherwise, so no action is required for existing users
- Excluded the SPM `.build/` directory from the published package

## 0.5.2

- Quick hotfix adding a "No items" label to an empty `IPadFileMenu` on non-iPadOS platforms instead of an empty string
- Updated documentation for `IconConverter.iconWidgetToBytes`
- [Flutter 3.38's UISceneDelegate migration](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate#migration-guide-for-flutter-apps)

## 0.5.1

* Improved macOS functionality by adding the default native menu actions from `IPadAppMenu` and `IPadWindowMenu` 
using `PlatformProvidedMenuItem`
  * This means that actions such as *About*, *Quit*, *Services* and *Window layout* are accesible just by adding these 
  two widgets to the tree

## 0.5.0

* Added `iconWidget` attribute to `PlatformMenuItemWithIcon`, `PlatformMenuWithIcon` and `StatefulPlatformMenuItemWithIcon`
  * Allows rendering Flutter widgets as an static image in the native iPadOS menu bar
  * Only one of `icon` or `iconWidget` can be set at a time
* Fixed icons not reducing transparency when item is disabled

## 0.4.3

* Added top level example README file

## 0.4.2

* Fixed `IPadMenu` behaviors on macOS (and other non iOS platforms) that either caused crashing or didn't show a menu when additionalItems was null or empty
* Updated `IPadWindowMenu` documentation
* Distributed example folder into different example projects

## 0.4.1

* Added macOS platform to example project
* Fixed bugs found inside macOS/other platforms that aren't iOS/iPadOS

## 0.4.0

* **BREAKING**: Refactored `IPadOSPlatformMenuDelegate` instantiation
  * Constructor is now private (`_internal`)
  * Use static factory method `IPadOSPlatformMenuDelegate.create()` for creating instances
  * This ensures proper platform validation and prevents misuse on non-iOS platforms
* Added `IPadAppMenu`
  * Adds access to the application menu
* Updated `IPadWindowMenu`
  * Added *entrypoint* attribute, in a future will be able to manage multiple windows for your iPad applications
* Removed `IPadFileMenu` window close callbacks, as it makes more sense to use `WidgetsBindingObserver` to manage app 
lifecycle state logic
* Updated README.md to reflect new project feature goals

## 0.3.1

* Fixed custom menus placement behavior
  * Now custom menus follow a *left to right* order correctly following the *top to bottom* widget tree placement

## 0.3.0

* Added menu items state support via `StatefulPlatformMenuItem` and `StatefulPlatformMenuItemWithIcon`
  * `MenuItemState.off` ->
  * `MenuItemState.on` -> ✓
  * `MenuItemState.mixed` -> －
* Updated example to show off new API components

## 0.2.0

* Added keyboard shortcuts support for items
* Added sidebar example with shortcut

## 0.1.1

* Rename `IpadOSPlatformMenuDelegate` into `IPadOSPlatformMenuDelegate`
* Update API documentation

## 0.1.0

* Default menus now work like the classic PlatformMenu widgets and are configured at the widget tree.
  * `IPadFileMenu`
  * `IPadEditMenu`
  * `IPadFormatMenu`
  * `IPadViewMenu`
  * `IPadWindowMenu`
* `PlatformMenuItemWithIcon` and `PlatformMenuWithIcon` to pass `IconData` to menu items

## 0.0.3

* Corrected README.md to correctly show GIF showcase on pub.dev


## 0.0.2

* Correct custom menus placement
* Enable/disable items


## 0.0.1

* Custom PlatformMenuDelegate for iPad
* Custom menu items and submenus (no custom icons on items, as of now)
* Ability to hide select default items (File, Edit, Format, View)
