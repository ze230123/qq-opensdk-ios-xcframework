# AGENTS.md

本仓库不是源码项目，而是腾讯 QQ 互联 OpenAPI iOS SDK 的 **SPM 二进制分发仓库**。仓库内不含任何源码、构建脚本、测试、lint 或 typecheck 配置。不要尝试运行 `xcodebuild`、`pod`、`npm` 等命令——此处无对应工程文件。改动只可能发生在二进制替换（新版 SDK 下发）或集成文档微调。

## 仓库结构

- 顶层文件：`Package.swift`（SPM binary target 包装）、`README.md`、`AGENTS.md`、`.gitignore`；xcframework 本体**不进 git**（被 `.gitignore` 排除），仅通过 GitHub Release zip 分发。
- SDK 版本：**3.6.20**（从二进制 `strings` 提取，`_lite` 是内部变体后缀，分发版本号不带后缀）。
- 最低部署目标：iOS 12.0（由 `otool -l` 的 `LC_BUILD_VERSION` `minos 12.0` 核实），`Package.swift` 中 `platforms: .iOS(.v12)` 与之对齐。
- xcframework 两个 slice：
  - `ios-arm64/` — 真机（arm64）
  - `ios-arm64_x86_64-simulator/` — 模拟器（arm64 + x86_64）
- 每个 slice 内的 `TencentOpenAPI.framework/TencentOpenAPI` 是 **静态库（Mach-O `ar archive`）**，不是动态 framework。集成时必须链接而非嵌入（Embed = Do Not Embed）。
- 顶层 `_CodeSignature/` 是 Tencent 分发原始形态，`CodeResources` 哈希清单引用 `TencentOpenAPI.framework/...` 路径——**不要重命名 framework 目录或 xcframework 目录**，否则签名清单失配。
- `PrivacyInfo.xcprivacy` 已声明 `NSPrivacyAccessedAPICategoryUserDefaults`（理由 `CA92.1`），随 xcframework 一起分发，宿主 App 无需再重复声明此项。

## 主要公开头文件

入口在 `TencentOpenApiUmbrellaHeader.h`，导出以下四个公开头：

- `QQApiInterface.h`：分享 / 加群 / 绑群 / 频道 / 表情收藏 / URL 与 Universal Link 回调。
- `QQApiInterfaceObject.h`：上述请求 / 响应对象定义。
- `TencentOAuth.h`：授权登录、token、openId、CGI 调用。
- `SDKDef.h`：`APIResponse`、`OpenSDKError`、权限常量、`TCAPIRequest` 等基础类型。

## 高优先级 / 容易踩坑的事实

- **SPM target 名 ≠ Swift 模块名（大小写陷阱）**：SPM binary target 名必须等于 xcframework 目录名 → `TencentOpenAPI`（`API` 全大写）；但 `module.modulemap` 定义的模块名是 `TencentOpenApi`（`Api` 仅 `A` 大写）。Swift 端必须 `import TencentOpenApi`，写错大小写会直接报模块找不到。ObjC 端 `@import TencentOpenApi;` 或 `#import <TencentOpenAPI/QQApiInterface.h>` 均可。这个不一致**不能通过重命名修复**——重命名会破坏 `_CodeSignature/CodeResources` 的哈希清单。
- **是静态库而非动态框架**：链接时符号会被合入宿主 App，不需要在 `Embed Frameworks` 阶段拷贝，也不要在 `LD_RUNPATH_SEARCH_PATHS` 里找它。
- **不要主动判断 QQ/TIM 是否安装**：`QQApiInterface.h` 注释明确说 SDK 按 `QQ > TIM` 顺序自动回退，已安装任一即可登录/分享；既有 `isQQInstalled` / `isTIMInstalled` 判断逻辑建议移除。
- **`isTIMSupportApi` 已废弃**：头文件用 `__attribute__((deprecated))` 标注，调用处用 `YES` 替代即可。

## 工作约定

- xcframework 本体和 zip 都不进 git（见 `.gitignore`），仅通过 GitHub Release asset 分发。集成方通过 SPM 拉取 `Package.swift`，再按其中 `binaryTarget` 的 url + checksum 下载 zip。
- 仓库内没有任何可验证代码的命令。替换 SDK 前后可通过 `ls -la TencentOpenAPI.xcframework/ios-arm64/TencentOpenAPI.framework/TencentOpenAPI` 与 `file` 命令核对二进制时间戳与架构，不要试图反编译。
- 查 API 时直接读 `Headers/*.h`；二进制内的 `strings` 输出（如 `3.6.20_lite`）只是版本标记，不含完整 API 文档。
- 如需验证集成，应在**宿主 App 工程**里 `import TencentOpenApi` 后构建，而不是在本仓库内。

## 改版流程（升级到 X.Y.Z）

每个版本 = 一个 GitHub Release + 一个 git tag，tag 号 = SDK 版本号 = `Package.swift` 中 url 的版本段。严格按顺序执行：

1. 替换本地 `TencentOpenAPI.xcframework/`（新版 SDK 下发），用 `strings TencentOpenAPI.xcframework/ios-arm64/TencentOpenAPI.framework/TencentOpenAPI | grep -E '^[0-9]+\.[0-9]+\.[0-9]+(_lite)?$'` 确认版本号，`file .../TencentOpenAPI` 确认架构。
2. `find TencentOpenAPI.xcframework -name ".DS_Store" -delete` 清理噪声文件（否则 checksum 不稳定）。
3. `zip -r TencentOpenAPI-X.Y.Z.xcframework.zip TencentOpenAPI.xcframework -x "*.DS_Store" -x "*/.DS_Store"`。
4. `shasum -a 256 TencentOpenAPI-X.Y.Z.xcframework.zip | awk '{print $1}'` 算 checksum。
5. 更新 `Package.swift` 的 `url`（版本段同步）与 `checksum`；如新版有依赖/plist 变化，同步更新本文件"高优先级 / 容易踩坑的事实"段与 `README.md`。
6. `git add` + `git commit -m "Bump TencentOpenAPI to X.Y.Z"` + `git push origin main`。
7. `gh release create X.Y.Z TencentOpenAPI-X.Y.Z.xcframework.zip --title "TencentOpenAPI X.Y.Z" --notes "QQ 互联 OpenAPI iOS SDK X.Y.Z 二进制分发"`。`gh` 会基于当前 HEAD 自动打 tag `X.Y.Z`。
8. `curl -sL <url> | shasum -a 256` 验证远端 checksum 与本地一致；不一致说明上传有损坏，删 Release 重来。

**不可变约定**：

- 不要修改或强推已发布的 tag，发现 bug 就发新版本（如 `3.6.21`），否则集成方 SPM 缓存会错乱。
- zip 文件名必须带版本号 `TencentOpenAPI-X.Y.Z.xcframework.zip`，避免 Release asset 同名混淆。
- 顺序不能反：先打 zip 算 checksum → 改 `Package.swift` → commit → 再 `gh release create`，确保 tag 指向的 commit 已含正确的 `Package.swift`。
