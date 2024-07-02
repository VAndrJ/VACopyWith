// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "VACopyWith",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(
            name: "VACopyWith",
            targets: ["VACopyWith"]
        ),
        .executable(
            name: "VACopyWithClient",
            targets: ["VACopyWithClient"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "VACopyWithMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "VACopyWith", dependencies: ["VACopyWithMacros"]),
        .executableTarget(name: "VACopyWithClient", dependencies: ["VACopyWith"]),
        .testTarget(
            name: "VACopyWithTests",
            dependencies: [
                "VACopyWithMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
