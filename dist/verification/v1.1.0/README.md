# v1.1.0 预览版构建检查

- 构建环境：Windows PowerShell、Temurin JDK 17.0.20.1+1、Android SDK Platform 34、Build Tools 34.0.0。
- 通过 `build.ps1` 完整编译并打包当前源码，包含已提交的遥控器界面调整与本次图标资源。
- 包名 `com.gelab.tvsettingsnavigator`，versionName `1.1.0`，versionCode `2`。
- APK 的 v1/v2/v3 签名验证、4 字节 ZIP 对齐检查通过。
- Manifest 未声明权限；保留普通桌面和电视桌面启动入口。
- 确认 APK 内存在五种密度的旧版 PNG 图标、API 26+ 自适应图标及三种密度的 16:9 横幅资源。
- 已检查 SVG 导出的图标在 24/32/48 像素和圆形、圆角方形裁切下的效果；这是资源预览，并非电视或模拟器截图。
- 已将 APK 内的 48 像素图标和 320×180 横幅提取出来检查。
- 未连接电视或模拟器；未验证桌面实际显示、安装运行或不同厂商的设置入口。

当前测试证书与初始 1.0 版不同。旧版用户需要先卸载再安装；签名密钥仅保存在本地忽略目录，不随源码或 APK 上传。

APK SHA-256：`e92513ff282cf207e2c8176ccf457a6d44efd7e8084a3faa2d117af47aad84f4`。
