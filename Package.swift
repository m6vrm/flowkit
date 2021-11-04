// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FlowKit",
    platforms: [.iOS(.v11)],
    products: [
        .library(name: "FlowKit", targets: ["FlowKit"]),
        .library(name: "FlowKitExampleAppFeature", targets: ["FlowKitExampleAppFeature"]),
    ],
    targets: [
        .target(name: "FlowKit"),
        .target(name: "FlowKitExampleNavigation"),
        .target(name: "FlowKitExamplePromises"),
        .target(
            name: "FlowKitExampleTransferFlowFeature",
            dependencies: ["FlowKit", "FlowKitExampleNavigation", "FlowKitExamplePromises"]),
        .target(
            name: "FlowKitExampleAppFeature",
            dependencies: ["FlowKit", "FlowKitExampleNavigation", "FlowKitExampleTransferFlowFeature"]),
    ]
)
