# 启动图标与电视横幅

使用电视轮廓和向右进入的箭头，表达“打开电视的设置入口”。延续应用的深色和蓝色视觉，不使用播放按钮、清理扫帚或无线信号，避免误认成播放器、清理工具或 ADB 连接器。

- 背景：`#0B1830`。
- 电视轮廓：`#F0F7FF`。
- 入口箭头：`#57DBFF`。
- 无文字的方形图标在小尺寸保持识别；电视横幅包含应用名称。

## 源文件与 Android 资源

- `icon.svg`：512×512 可缩放图标母版，带透明边距。
- `tv-banner.svg`：640×360 横幅母版，文字使用 Microsoft YaHei 和 Segoe UI。
- `res/mipmap-*/ic_launcher.png`：旧版系统使用的 48 / 72 / 96 / 144 / 192 像素图标。
- `res/mipmap-anydpi-v26/ic_launcher.xml`：Android 8.0 及以上使用的自适应图标。
- `res/drawable/ic_launcher_foreground.xml`：自适应图标的原生矢量前景，图形位于安全区域内。
- `res/drawable-xhdpi/tv_banner.png`：320×180 电视桌面横幅。
- `res/drawable-xxhdpi/tv_banner.png`：480×270 电视桌面横幅。
- `res/drawable-xxxhdpi/tv_banner.png`：640×360 电视桌面横幅。

PNG 由 SVG 母版使用 resvg 2.6.2 导出。导出图标时按各密度目标宽度等比缩放；导出横幅时加载上述字体，保留 16:9 比例。母版及 Android 矢量前景中的电视和箭头几何保持一致，仅按各自图标安全区域等比缩放。

原有应用页面的颜色和布局不因本次图标设计而改变。
