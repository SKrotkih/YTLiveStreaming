// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "YTLiveStreaming",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "YTLiveStreaming", targets: ["YTLiveStreaming"])
    ],
    targets: [
        .target(
            name: "YTLiveStreaming",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "YTLiveStreamingTests",
            dependencies: ["YTLiveStreaming"],
            resources: [.copy("Fixtures")]
        )
    ]
)
