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
            checksum: "62fa898eeb450e08c21e532b30418815fd4b2cf7e09a19e10ccaa3510088b60c"
        )
    ]
)
