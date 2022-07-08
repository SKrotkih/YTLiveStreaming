// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YTLiveStreaming",
    platforms: [.iOS(.v13),
                .macOS(.v10_13)],
    products: [
        .library(
            name: "YTLiveStreaming",
            targets: ["YTLiveStreaming"])
    ],
    dependencies: [.package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", .upToNextMajor(from: "4.0.0")),
                   .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", .upToNextMajor(from: "3.0.0")),
                   .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
                   .package(url: "https://github.com/Moya/Moya.git", .upToNextMajor(from: "15.0.0"))],
    // Dependencies:
    // 1. SwiftyJSON: https://swiftpackageindex.com/SwiftyJSON/SwiftyJSON
    // 2. KeychainAccess: https://swiftpackageindex.com/kishikawakatsumi/KeychainAccess
    // 3. Alamofire: https://swiftpackageindex.com/Alamofire/Alamofire
    // 4. Moya: https://swiftpackageindex.com/Moya/Moya
    targets: [
        .target(
            name: "YTLiveStreaming",
            dependencies: [.product(name: "SwiftyJSON", package: "SwiftyJSON"),
                           .product(name: "KeychainAccess", package: "KeychainAccess"),
                           .product(name: "Alamofire", package: "Alamofire"),
                           .product(name: "Moya", package: "Moya")],
            path: "YTLiveStreaming"),
        .testTarget(
            name: "YTLiveStreamingTests",
            dependencies: ["YTLiveStreaming",
                           .product(name: "SwiftyJSON", package: "SwiftyJSON"),
                           .product(name: "Alamofire", package: "Alamofire")],
            path: "YTLiveStreamingTests")
    ]
)
