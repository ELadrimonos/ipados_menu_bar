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
  ipados_menu_bar: ^0.3.1
```

Then run:

```bash
flutter pub get
```

## 🏁 Getting Started

### Basic Setup

Initialize the iPadOS menu bar in your app's `main()` method:

```dart
import 'package:flutter/material.dart';
import 'package:ipados_menu_bar/ipados_menu_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.platformMenuDelegate = IPadOSPlatformMenuDelegate();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iPadOS Menu Bar Demo',
      home: PlatformMenuBar(
        menus: [
          // Your custom menus here
          IPadEditMenu(
              onUndo: () => debugPrint('Undo action!'),
              onRedo: () => debugPrint('Redo action!'),
          ),
          PlatformMenu(
            label: 'Normal Actions',
            menus: [
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuItemWithIcon(
                    icon: CupertinoIcons.plus_app,
                    label: 'New Document',
                    onSelected: () {
                      // Handle action
                    },
                  ),
                  PlatformMenuItem(
                    label: 'Open Document',
                    onSelected: () {
                      // Handle action
                    },
                  ),
                ],
              ),
              PlatformMenuItemGroup(
                members: [
                  PlatformMenuWithIcon(
                    icon: CupertinoIcons.folder,
                    label: "Recent Documents",
                    menus: [
                      PlatformMenuItem(
                        label: 'Shopping list',
                        onSelected: () => debugPrint("Carrots, popcorn, water..."),
                      ),
                      // Disabled (onSelected is null)
                      PlatformMenuItem(
                        label: 'Family secrets',
                      ),
                    ],
                  ),
                ]
              ),
            ],
          ),
        ],
        child: Scaffold(
          appBar: AppBar(
            title: Text('My App'),
          ),
          body: Center(
            child: Text('Hello iPadOS Menu Bar!'),
          ),
        ),
      ),
    );
  }
}
```

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

### Menu Structure

Create organized menu hierarchies with:
- `PlatformMenu`: Top-level menu categories
- `PlatformMenuItemGroup`: Grouped menu items with separators
- `PlatformMenuItem`: Individual menu actions with optional keyboard shortcuts
- `PlatformMenuWithIcon`: Menu categories with a leading icon
- `PlatformMenuItemWithIcon`: Individual menu actions with a leading action
- *Default menu items*: Apple's top-level menu categories with their corresponding items and listeners
  - `IPadFileMenu`: Items file-related using Apple's incorporated item with callbacks for your app functionality
  and additional custom items
  - `IPadEditMenu`: Items for actions on your app using Apple's incorporated item with callbacks for your app f
  functionality and additional custom items
  - `IPadFormatMenu`: Items for formatting text or other data on your app using Apple's incorporated item with 
  callbacks for your app functionality and additional custom items
  - `IPadViewMenu`: Items to switch between screens or other UI-related actions like showing the sidebar
  - `IPadWindowMenu`: Listeners for reacting when the window layout changes, a new window is opened, switched screen,
  etc...
  - `IPadAppMenu`: Application-level related custom items

## 📱 Platform Support

This package is specifically designed for iPadOS 26+ and provides enhanced functionality when running on compatible devices. On older iOS versions, it gracefully falls back to standard Flutter menu behavior.

## 🔧 Feature Roadmap

| Feature                                       | Status |
|-----------------------------------------------|--------|
| Basic Menu Bar Integration                    | ✅      |
| Custom Menu Items                             | ✅      |
| Custom Menu Items HIG Placement               | ✅      |
| Hide Default Menus (File, Edit, Format, View) | ✅      |
| Submenu Nesting                               | ✅      |
| Dynamic Menu Updates                          | ✅      |
| Menu Separators                               | ✅      |
| App Info Custom Children Items                | ✅      |
| Menu Icons Support                            | ✅      |
| Window Change listeners in dart               | 🚧     |
| Stateful Items (checked, unchecked, mixed)    | ✅     |
| Keyboard Shortcuts                            | ✅     |

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
