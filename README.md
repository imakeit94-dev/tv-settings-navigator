# 电视设置导航 · TV Settings Navigator

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

不写入系统设置、不执行 Shell、不启停 ADB、不接管 HOME；不含广告、遥测、无障碍服务或第三方运行库。

## 安装与兼容性

已由用户在海信 E8G、Android 9 上通过 U 盘安装，确认开发者选项入口有效。其余三个入口与其他机型尚未逐一验证，可用性取决于厂商固件。

1. 获取 [APK](dist/tv-settings-navigator.apk)，可用 [SHA256SUMS](dist/SHA256SUMS.txt) 校验。
2. 复制到 U 盘，在电视文件管理器中打开并安装；根据系统提示允许对应安装来源。
3. 在应用列表打开“电视设置导航”，使用方向键和确认键选择入口。

卸载应用不会撤销在系统设置中手动做出的更改。随附 APK 使用测试签名；自行构建的签名不同时，无法直接覆盖已有版本。

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
dist/                    初始 APK、校验值和静态验证记录
LICENSE                   MIT 许可证
NOTICE.md                 上游来源及修改说明
```

包名 `com.gelab.tvsettingsnavigator`，版本 1.0 / versionCode 1；minSdk 21、targetSdk 28、compileSdk 34。同时声明 LAUNCHER 和 LEANBACK_LAUNCHER 入口。

## 验证

初始 APK 的 SHA-256：

```text
99bcbdd959f05c8fb9140f4736ffc01f38acaf5c3abb6f1297133f00eb69f367
```

该 APK 的 v1/v2/v3 签名验证通过，Manifest 无权限，DEX 设置 action 仅上述四项。原始输出见 [dist/verification](dist/verification)。证书和打包时间等会影响重建哈希，上述值仅对应仓库保留的初始 APK。

## 来源与许可

基于 [BuddhaYi/android-tv-developer-enabler](https://github.com/BuddhaYi/android-tv-developer-enabler) 的设置入口思路重写，保留 MIT 许可和上游版权声明。已记录的上游版本和修改范围见 [NOTICE.md](NOTICE.md)。本仓库版本不包含写设置或启停 ADB 的功能。