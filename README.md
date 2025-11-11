<div style="text-align: center;">
    <h1 align="center">🍎 iPadOS Menu Bar 📱</h1>
    <a href="https://wakatime.com/badge/github/ELadrimonos/ipados_menu_bar">
        <img src="https://wakatime.com/badge/github/ELadrimonos/ipados_menu_bar.svg" alt="WakaTime">
    </a>
    <br><br>
    <p><strong>A custom PlatformMenuDelegate that adds iPadOS 26+ menu bar functionality to Flutter apps</strong></p>
</div>


<p align="center">
  <img src="https://raw.githubusercontent.com/ELadrimonos/ipados_menu_bar/refs/heads/main/preview.gif" width="80%" alt="iPad menu bar preview"/>
</p>

---

## 📑 Table of Contents

- [🧭 Human Interface Guidelines](#-human-interface-guidelines)
- [🚀 Features](#-features)
- [📦 Installation](#-installation)
- [📚 Examples](#-examples)
- [🏁 Getting Started](#-getting-started)
- [🎛️ Customization Options](#️-customization-options)
- [📱 Platform Support](#-platform-support)
- [🔧 Feature Roadmap](#-feature-roadmap)
- [⚠️ API Stability Notice](#️-api-stability-notice)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)

---

## 🧭 Human Interface Guidelines

This package follows Apple’s official Human Interface Guidelines for the iPadOS menu bar. Before designing your menus, review these resources to ensure consistency with the system experience:

- WWDC session on the iPadOS menu bar: https://developer.apple.com/videos/play/wwdc2025/208/?time=624
- Apple HIG – Menu Bar: https://developer.apple.com/design/human-interface-guidelines/the-menu-bar

## 🚀 Features

Bring the native iPadOS menu bar experience to your Flutter applications with this custom `PlatformMenuDelegate`. This package provides seamless integration with iPadOS 26+ menu bar functionality, allowing users to access app features through the system menu bar.

## 📦 Installation

Add `ipados_menu_bar` to your `pubspec.yaml`:

```yaml
dependencies:
  ipados_menu_bar: ^0.5.0
```

Then run:

```bash
flutter pub get
```

## 📚 Examples

Explore practical use cases demonstrating advanced features and integrations:

- **Menu Provider Example**  
  Demonstrates how to dynamically manage menus using a custom provider.  
  🔗 [View on GitHub](https://github.com/ELadrimonos/ipados_menu_bar/tree/main/example/menu_provider_example)

- **Multiple Windows Example**  
  Shows how to open and manage multiple windows with different Flutter views and arguments.  
  🔗 [View on GitHub](https://github.com/ELadrimonos/ipados_menu_bar/tree/main/example/multiple_windows_example)

## 🏁 Getting Started

### Basic Setup

Initialize the iPadOS menu bar in your app's `main()` method:

```dart
import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate.create();

  runApp(MyApp());
}
```
And everything just works now! Please check out the included examples to learn how `PlatformMenu` works and how to use it on your application.

## 🎛️ Customization Options

### Hidden Default Menus

The package allows you to hide default system menu items that come with iPadOS:

- **File**: Hide file-related actions
- **Edit**: Hide editing actions (cut, copy, paste, etc.)
- **Format**: Hide text formatting options
- **View**: Hide view-related controls

These menus will be automatically hidden when there's a `PlatformMenuBar`on the current context and 
haven't been placed in the widget tree:

```dart

PlatformMenuBar(
    menus: [
        // File and Format will be hidden
        IPadEditMenu(
            onUndo: () => debugPrint('Undo action!'),
            onRedo: () => debugPrint('Redo action!'),
        ),
        IPadViewMenu(),
    ],
)

```

### Disable Menu Items

On custom menu items, you can disable menu items by setting the `onSelected` or `onSelectedIntent` a null value:

```dart
// Controlling when an item should be clickable using a boolean
PlatformMenuItem(
  label: 'Item 0 (Enabled: $enabledBoolean)',
  onSelected: enabledBoolean
      ? () => debugPrint("Item 0 selected")
      : null,
),
```

This is handful when changing contexts, like opening a modal, and don't want the 
user to do unexpected stuff.

### Add Icons to your items

You can use either `IconData` with `icon` attribute or a `Widget` using `iconWidget` attribute on
`PlatformMenuItemWithIcon`, `PlatformMenuWithIcon` and `StatefulPlatformMenuItemWithIcon`.

> [!NOTE]
> Icons will only be rendered on iPadOS, they won't work on macOS or other platforms

```dart
// Disabled items will have their icon's alpha lowered
PlatformMenuItemWithIcon(
  label: 'Disabled item',
  icon: Icons.favorite
),

PlatformMenuItemWithIcon(
  label: 'Icon widget!',
  iconWidget: FlutterLogo(),
  onSelected: () {
    print("Flutter Rocks!!");  
  }
),
```

### Set a state to your item

Menu items can have three different states: *off*, *on* and *mixed*.

> [!NOTE]
> State will only be rendered on iPadOS, they won't work on macOS or other platforms


```dart
StatefulPlatformMenuItem(
  label: 'Unchecked',
  state: MenuItemState.off
),

StatefulPlatformMenuItem(
  label: 'Checked',
  state: MenuItemState.on
),

StatefulPlatformMenuItemWithIcon(
  label: 'Mixed',
  state: MenuItemState.mixed,
  icon: Icons.question_mark
),
```

### Menu Structure

Create organized menu hierarchies with:

- **`PlatformMenu`** – Defines a top-level menu category.
- **`PlatformMenuItemGroup`** – Groups related menu items and automatically separates them from others.
- **`PlatformMenuItem`** – Represents an individual menu action, optionally with a keyboard shortcut.
- **`PlatformMenuWithIcon`** – A top-level menu that includes a leading icon.
- **`PlatformMenuItemWithIcon`** – A single menu action that includes a leading icon.

#### Default Apple-style Menus

These are prebuilt menu categories designed to follow Apple’s native iPadOS behavior, while allowing custom items and callbacks:

- **`IPadAppMenu`** – Allows you to access the Application menu and add your own items.
- **`IPadFileMenu`** – Manages file-related operations such as opening, saving, or creating new documents.
- **`IPadEditMenu`** – Provides standard edit actions (undo, redo, cut, copy, paste) integrated with iPadOS, plus your own callbacks.
- **`IPadFormatMenu`** – Handles formatting-related actions for text or data with system-consistent structure.
- **`IPadViewMenu`** – Allows switching between views, toggling panels, or controlling UI visibility (e.g., showing the sidebar).
- **`IPadWindowMenu`** – Enables window management and lets you define entry points for new windows, each with its own Flutter view and arguments.


## 📱 Platform Support

This package is specifically designed for iPadOS 26+ and provides enhanced functionality when running on compatible devices.  

On other platforms, it executes using the default `DefaultPlatformMenuDelegate`, ensuring full compatibility with macOS and preventing any unexpected behavior on other targets.

While this plugin automatically arranges menu items to follow Apple’s Human Interface Guidelines on iPadOS, macOS retains the menu order exactly as defined in the widget tree.  
For that reason, it’s recommended to keep a consistent and well-structured menu hierarchy when targeting macOS.

## 🔧 Feature Roadmap

| Feature                                                                           | Status |
|-----------------------------------------------------------------------------------|--------|
| Basic Menu Bar Integration                                                        | ✅     |
| Custom Menu Items                                                                 | ✅     |
| Apple Human Interface Guideline menu arrangement                                  | ✅     |
| Hide Default Menus (*File, Edit, Format, View*)                                   | ✅     |
| Submenu Nesting                                                                   | ✅     |
| Dynamic Menu Updates                                                              | ✅     |
| Menu Separators                                                                   | ✅     |
| App Info Custom Children Items                                                    | ✅     |
| Menu Icons Support                                                                | ✅     |
| Widgets as Menu Icons Support                                                     | ✅     |
| Multiple Windows support                                                          | 🚧     |
| Stateful Items (checked, unchecked, mixed)                                        | ✅     |
| Keyboard Shortcuts                                                                | ✅     |
| Native menu items on other platforms (macOS)<br/>using `PlatformProvidedMenuItem` | ✅     |

## ⚠️ API Stability Notice

**Important:** This package is currently in early development (version 0.x.x). The API is subject to breaking changes until it reaches a stable 1.0.0 release. Please be aware that:

- Method signatures may change
- Configuration options may be modified or removed
- New features may introduce breaking changes

We recommend pinning to a specific version in your `pubspec.yaml` and reviewing the changelog before updating. Once the package reaches version 1.0.0, we will follow semantic versioning for all future releases.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This package is licensed under [MIT License](LICENSE).
