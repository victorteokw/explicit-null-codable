// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "ExplicitNullCodable",
    platforms: [.macOS(.v26), .iOS(.v26), .tvOS(.v26), .watchOS(.v26), .macCatalyst(.v26)],
    products: [
        .library(
            name: "ExplicitNullCodable",
            targets: ["ExplicitNullCodable"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
    ],
    targets: [
        .macro(
            name: "ExplicitNullCodableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ]
        ),
        .target(name: "ExplicitNullCodable", dependencies: ["ExplicitNullCodableMacros"]),
        .testTarget(
            name: "ExplicitNullCodableTests",
            dependencies: ["ExplicitNullCodable"]
        ),
    ],
)
