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
            checksum: "abed1a8e3dfbd4a7ff76e3ea8c1c1b58a2ffa5e6b6904e1037b4f771eeac5a43"
        )
    ]
)
