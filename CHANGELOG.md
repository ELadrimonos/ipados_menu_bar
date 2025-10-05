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
