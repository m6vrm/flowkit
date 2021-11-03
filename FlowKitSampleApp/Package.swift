// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "FlowKitSampleApp",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "NavigationKit", targets: ["NavigationKit"]),
        .library(name: "PromiseKit", targets: ["PromiseKit"]),
        .library(name: "FlowKit", targets: ["FlowKit"]),
        .library(name: "AppFeature", targets: ["AppFeature"]),
    ],
    targets: [
        .target(name: "NavigationKit"),
        .target(name: "PromiseKit"),
        .target(name: "FlowKit"),
        .target(
            name: "TransferFlowFeature",
            dependencies: ["NavigationKit", "FlowKit", "PromiseKit"]),
        .testTarget(
            name: "TransferFlowFeatureTests",
            dependencies: ["TransferFlowFeature"]),
        .target(
            name: "AppFeature",
            dependencies: ["NavigationKit", "FlowKit", "TransferFlowFeature"]),
    ]
)
