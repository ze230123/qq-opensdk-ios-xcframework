// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "TencentOpenAPI",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(name: "TencentOpenAPI", targets: ["TencentOpenAPI"])
    ],
    targets: [
        .binaryTarget(
            name: "TencentOpenAPI",
            url: "https://github.com/ze230123/qq-opensdk-ios-xcframework/releases/download/3.6.20/TencentOpenAPI-3.6.20.xcframework.zip",
            checksum: "e831ac859a09fac0a00f29043a99189f69c46d1ceaed4c2a4c9f06e2e628600f"
        )
    ]
)
