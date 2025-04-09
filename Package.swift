// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StackArray",
    products: [
        .library(
            name: "StackArray",
            targets: ["StackArray"]
        ),
    ],
    targets: [
        .target(
            name: "StackArray"
        ),
        .testTarget(
            name: "StackArrayTests",
            dependencies: ["StackArray"]
        ),
    ]
)
