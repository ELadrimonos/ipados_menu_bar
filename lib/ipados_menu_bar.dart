/// A highly customizable, native-like iPadOS 26+ menu bar for Flutter.
///
/// Provides a custom [PlatformMenuDelegate] plus a set of Apple-style menu
/// widgets ([IPadAppMenu], [IPadFileMenu], [IPadEditMenu], [IPadFormatMenu],
/// [IPadViewMenu], [IPadWindowMenu]), menu items with icons, and stateful
/// items. On non-iPadOS targets it falls back to the default delegates so apps
/// keep working safely.
library;

export 'ipados_platform_menu_delegate.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

part 'widgets/default_menus/abstract_menu.dart';
part 'widgets/default_menus/file_menu.dart';
part 'widgets/default_menus/edit_menu.dart';
part 'widgets/default_menus/format_menu.dart';
part 'widgets/default_menus/view_menu.dart';
part 'widgets/default_menus/window_menu.dart';
part 'widgets/default_menus/app_menu.dart';

part 'widgets/icon/item_with_icon.dart';
part 'widgets/icon/submenu_with_icon.dart';

part 'widgets/stateful_menu_item.dart';
part 'helpers/menu_item_state.dart';
