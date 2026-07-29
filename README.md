# TencentOpenAPI (iOS) — SPM 二进制分发

腾讯 QQ 互联 OpenAPI iOS SDK 的 Swift Package Manager 二进制分发仓库。

- 当前 SDK 版本：**3.6.21**（修复 modulemap）
- 支持架构：真机 `arm64`、模拟器 `arm64` + `x86_64`
- 最低部署目标：iOS 12.0

## 通过 SPM 集成

1. Xcode → File → Add Packages…
2. 输入仓库地址：
   ```
   https://github.com/ze230123/qq-opensdk-ios-xcframework
   ```
3. Dependency rule 选 **Up to Next Major Version: 3.6.21**，Add Package。
4. 在 target 的 Frameworks, Libraries, and Embedded Content 中确认 `TencentOpenAPI` 已添加。SPM binary target 由 Xcode 自动管理嵌入，无需手动设置 Embed 选项。

## 大小写陷阱（务必注意）

SPM target 名 = xcframework 目录名 = `TencentOpenAPI`（`API` 全大写），但 `module.modulemap` 定义的模块名是 `TencentOpenApi`（`Api` 仅 `A` 大写）。Swift 端必须写：

```swift
import TencentOpenApi   // 不是 TencentOpenAPI
```

ObjC 端 `@import TencentOpenApi;` 或 `#import <TencentOpenAPI/QQApiInterface.h>` 均可。这个大小写不一致是腾讯 SDK 的固有打包方式，不能通过重命名修复（重命名会让 SPM 找不到 binary target）。

> 3.6.21 修复：`module.modulemap` 缺 `framework` 限定符导致 Clang 无法在 framework 的 `Headers/` 下定位 umbrella header，`import TencentOpenApi` 报 `No such module` / `umbrella header not found`。已改为 `framework module TencentOpenApi { ... }`。

## 关于 Embed 与 Xcode 26

本包是静态库（Mach-O `ar archive`），符号在链接期合入宿主 App，**不应被 Embed**。但 Xcode 26 对 SPM binary target 会自动嵌入并在嵌入后校验 `Info.plist`，因此每个 slice 都已注入 `Info.plist` 以通过该校验。集成方按 SPM 默认配置即可，无需手动调整 Embed 选项。

## License

`TencentOpenAPI.xcframework` 本体版权归腾讯所有，使用须遵守 [QQ 互联开放平台服务协议](https://open.tencent.com/)。本仓库仅作 SPM binary target 分发包装。
