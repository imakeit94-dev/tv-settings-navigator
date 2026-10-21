# 上游与修改说明

本项目基于以下上游项目的思想与 Manifest/Intent 结构重写（未使用其预编译 APK）：

- 上游：https://github.com/BuddhaYi/android-tv-developer-enabler
- 上游分支：main
- 记录的上游 commit：`fd2ca01eb11dbbce84d689fd6603c803bf4842cd`（2026-05-14T01:06:28Z，抓取于 2026-10-20）
- 上游许可证：MIT（见 LICENSE，版权归 Copyright (c) 2026 BuddhaYi）

## 本地修改（developer-navigator）

1. 包名改为 `com.gelab.tvsettingsnavigator`，应用名改为“电视设置导航”，避免冒充/覆盖原版。
2. 仅保留上游按钮 1/5/8/9 对应的四个隐式 Intent：
   - `Settings.ACTION_APPLICATION_DEVELOPMENT_SETTINGS`
   - `Settings.ACTION_DEVICE_INFO_SETTINGS`
   - `Settings.ACTION_SETTINGS`
   - `Settings.ACTION_WIRELESS_SETTINGS`
3. 移除上游按钮 2/3/4 的指定组件与 fragment 跳转（避免无证据的组件猜测）。
4. 彻底移除上游按钮 6/7 相关代码：`Settings.Global.putInt`、`Runtime.exec`、`setprop`、`stop/start adbd`。
5. 移除全部 `uses-permission`（包括 INTERNET / WRITE_SETTINGS / WRITE_SECURE_SETTINGS）。
6. 重写 UI：中文按钮、醒目说明、结果区域、遥控器焦点导航；无 service/receiver/accessibility。
7. 构建方式改为本地 `build.ps1`（aapt2 + javac + d8 + zipalign + apksigner），不执行上游 `build.sh`。
8. 结果文案只说明“已发送打开请求，请以实际页面为准”，不把 `startActivity` 未抛异常等同于开发者/ADB 已开启。
9. v1.1.0 加入遥控器焦点界面调整，并重新绘制启动图标及电视桌面横幅；图形母版保存在 `design/branding/`。
