// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArrayInfo",
    products: [
        .library(
            name: "ArrayInfo",
            targets: ["ArrayInfo"]),
    ],
    targets: [
        .target(
            name: "ArrayInfo",
            dependencies: []),
        .testTarget(
            name: "ArrayInfoTests",
            dependencies: ["ArrayInfo"]),
    ]
)
