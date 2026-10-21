# 电视设置导航 · TV Settings Navigator

<img src="design/branding/icon.png" alt="电视设置导航应用图标" width="112" height="112">

跟着 [CleanYourTV](https://github.com/Gathin23/cleanyourtv) 等项目尝试通过 ADB 调试或整理电视时，真正的第一步往往不在电脑上，而在电视的设置菜单里：先找到设备信息和开发者选项，再按需要开启调试开关。不同厂商的 Android TV 菜单名称和位置不一样，有些桌面还隐藏了常见的设置入口。我们在调试电视时也遇到了这个问题——知道需要 ADB，却找不到它的入口。

电视设置导航就是为这个起点做的独立小工具。它将“开发者选项”“关于设备 / 本机信息”“系统设置”“无线 / 网络设置”四个入口集中在适合遥控器操作的首页。选中后，应用会尝试打开电视原有的设置页面，帮助你把注意力放回设备排查和调试，而不是反复翻找厂商菜单。

**零权限、无网络、无后台服务。** 它只发送打开页面的标准 Android Intent，不连接电脑、不执行 ADB 命令，也不会自动开启开发者选项、USB 调试或网络调试。具体页面能否打开取决于电视固件；是否开启调试开关，请在系统设置中根据自己的需求决定。

## 功能

| 按钮 | Intent action |
| --- | --- |
| 开发者选项 | `android.settings.APPLICATION_DEVELOPMENT_SETTINGS` |
| 关于设备 / 本机信息 | `android.settings.DEVICE_INFO_SETTINGS` |
| 系统设置 | `android.settings.SETTINGS` |
| 无线 / 网络设置 | `android.settings.WIRELESS_SETTINGS` |

入口均由用户点击触发，支持遥控器焦点导航。页面不存在或被限制时显示提示；请求发出不代表页面一定显示，也不代表已开启 ADB。

v1.1.0 预览版的宽屏界面将四个入口排成 2×2 网格，较窄窗口使用可滚动的单列。启动时焦点落在“开发者选项”入口；使用方向键移动焦点，按确认键打开所选入口。随附 APK 已包含这一界面调整，以及重新设计的“电视＋进入箭头”图标、自适应图标和电视桌面横幅。

不写入系统设置、不执行 Shell、不启停 ADB、不接管 HOME；不含广告、遥测、无障碍服务或第三方运行库。

## 安装与兼容性

初始 1.0 版曾由用户在海信 E8G、Android 9 上通过 U 盘安装，确认开发者选项入口有效。当前 v1.1.0 预览版已完成编译和 APK 静态检查，尚未在电视或模拟器上运行验证；其余入口与其他机型的可用性仍取决于厂商固件。

1. 从 [v1.1.0 下载页](https://github.com/imakeit94-dev/tv-settings-navigator/releases/tag/v1.1.0) 下载 APK，也可获取[仓库中的 APK](dist/tv-settings-navigator.apk)。可用 [SHA256SUMS](dist/SHA256SUMS.txt) 校验。
2. 复制到 U 盘，在电视文件管理器中打开并安装；根据系统提示允许对应安装来源。
3. 在应用列表打开“电视设置导航”，使用方向键和确认键选择入口。

**已安装初始 1.0 版的用户，请先卸载旧版再安装新版。** 这次构建使用了新的本地测试密钥，签名与初始 APK 不同，无法直接覆盖安装。卸载应用不会撤销在系统设置中手动做出的更改。自行构建时也需要使用同一签名密钥，才能直接覆盖安装。

图标和横幅的 [SVG 母版、PNG 预览与资源说明](design/branding) 可在仓库中查看。图标按 Android TV 的方形图标与 16:9 横幅分别提供资源，参见 [Android 官方设计准则](https://developer.android.com/design/ui/tv/guides/system/tv-app-icon-guidelines)。

## 源码构建（Windows）

需要 PowerShell 5.1+、JDK 17、Android SDK Platform 34 和 Build Tools 34.0.0，无需 Gradle。

用 Android SDK 自带的 sdkmanager 安装组件：

```powershell
sdkmanager.bat "platforms;android-34" "build-tools;34.0.0"
```

设置 JAVA_HOME 和 ANDROID_SDK_ROOT（也支持 ANDROID_HOME），在项目目录执行：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\build.ps1
```

或直接传入路径：

```powershell
.\build.ps1 -JavaHome 'C:\Tools\jdk-17' -AndroidSdkRoot 'C:\Tools\android-sdk'
```

构建链：aapt2 → javac → d8 → zipalign → apksigner。输出 `dist/tv-settings-navigator.apk`；可用 `-OutputDirectory` 指定其他目录。未配置依赖时，兼容查找上级目录的 `.toolchains`；独立构建无需此目录。

脚本清理项目内 build 目录，并在当前进程设置 Java 环境，不会连接或安装到电视。

第一次构建在 `keystore/test-debug.keystore` 生成测试密钥，密码为公开开发测试值。**密钥文件不入库。** 长期分发更新需另行配置并安全保管正式签名密钥，不应依赖此测试签名方案。

## 目录

```text
AndroidManifest.xml       无权限的应用声明
src/                      Java 源码
res/                      布局、文字与图标
build.ps1                 Windows 构建脚本
dist/                     当前 APK、校验值和静态验证记录
design/branding/          图标与电视横幅母版、预览和说明
LICENSE                   MIT 许可证
NOTICE.md                 上游来源及修改说明
```

包名 `com.gelab.tvsettingsnavigator`，版本 1.1.0 / versionCode 2；minSdk 21、targetSdk 28、compileSdk 34。同时声明 LAUNCHER 和 LEANBACK_LAUNCHER 入口。

## 验证

当前 v1.1.0 APK 的 SHA-256：

```text
e92513ff282cf207e2c8176ccf457a6d44efd7e8084a3faa2d117af47aad84f4
```

该 APK 的 v1/v2/v3 签名和 ZIP 对齐检查通过，Manifest 无权限，已确认 APK 包含各密度图标、自适应图标及电视横幅。当前版本的检查输出见 [dist/verification/v1.1.0](dist/verification/v1.1.0)；其上级目录中的旧检查记录属于初始 1.0 版。证书和打包时间等会影响重建哈希，上述值仅对应本次随附的 APK。

## 来源与许可

基于 [BuddhaYi/android-tv-developer-enabler](https://github.com/BuddhaYi/android-tv-developer-enabler) 的设置入口思路重写，保留 MIT 许可和上游版权声明。已记录的上游版本和修改范围见 [NOTICE.md](NOTICE.md)。本仓库版本不包含写设置或启停 ADB 的功能。
