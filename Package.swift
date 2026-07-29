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
            url: "https://github.com/ze230123/qq-opensdk-ios-xcframework/releases/download/3.6.21/TencentOpenAPI-3.6.21.xcframework.zip",
            checksum: "00d1d2a7633af02d5b6e09f979d9c29ff35e7989b0eadb0ab5a5ffa9424fcd24"
        )
    ]
)
