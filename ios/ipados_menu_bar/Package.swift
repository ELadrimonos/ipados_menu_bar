// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ipados_menu_bar",
    platforms: [
        .iOS("13.0"),
    ],
    products: [
        // Library product name is hyphen-separated to match the dependency
        // name injected by Flutter's `FlutterGeneratedPluginSwiftPackage`.
        .library(name: "ipados-menu-bar", targets: ["ipados_menu_bar"])
    ],
    dependencies: [
        // `FlutterFramework` is a synthetic package that Flutter generates
        // next to this plugin in the build directory; it vends the Flutter
        // framework so this target can `import Flutter`.
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            // Target name becomes the Swift module name (`@import ipados_menu_bar`
            // in the generated registrant).
            //
            // The Swift source under `Sources/ipados_menu_bar/` is a copy of
            // `ios/Classes/IpadOSMenubarPlugin.swift`, which the CocoaPods
            // flow compiles via `ipados_menu_bar.podspec`. Keep the two in
            // sync. (This duplication is required because SPM requires target
            // sources to live under `Sources/<Target>/` while CocoaPods reads
            // `Classes/**/*` from the podspec.)
            name: "ipados_menu_bar",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            path: "Sources/ipados_menu_bar",
            resources: [
                .process("PrivacyInfo.xcprivacy"),
            ]
        )
    ]
)
