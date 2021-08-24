// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftttCamera",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(name: "SwiftttCamera", targets: ["SwiftttCamera"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "SwiftttCamera",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "SwiftttCameraTests",
            dependencies: ["SwiftttCamera"],
            path: "Tests",
            resources: [
                .process("Test Images"),
            ]
        ),
    ]
)
