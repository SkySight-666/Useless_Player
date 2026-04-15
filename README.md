# Useless-player

musicd 的前端配套播放器（Falcon + Vue + 自定义 C++ JSAPI，使用 `npm`）。

## Backend 默认路径

- `/userdisk/bin/musicd/`
- 实际调用：`/userdisk/bin/musicd/musicctl`

## C++ 层

- 原生模块名：`player_native`
- 构建产物：`libs/libjsapi_bridge.so`
- 依赖库（按机型）：`libs/libcurl.so`、`libs/libsqlite3.so`

前端通过 `src/utils/shell-api.js` 调用 `player_native.Shell.exec()`，不再依赖 `bridge` 模块。

## 外部 App 调用协议

通过 `navTo('index', options)` 调用，支持：

- `action=play` + `url|path|target`
- `action=enqueue` + `url|path|target`
- `action=pause|resume|next|stop|state`
- `action=output` + `output|name`
- `output=speaker|analog|digital|bt|<自定义>`（可与其他 action 同时传）
- `autoclose=1` 执行后自动关闭页面

示例：

- `navTo('index', { action: 'play', path: '/userdisk/Music/demo.mp3', output: 'speaker' })`
- `navTo('index', { action: 'pause', autoclose: '1' })`

## 开发与构建

```bash
cd /home/skysight/Useless-player
CROSS_TOOLCHAIN_PREFIX=/path/to/<triple>- USELESS_PLAYER_DEVICE=s6 ./build.sh
```

说明：

- `USELESS_PLAYER_DEVICE` 支持 `s6` / `a6`
- `build.sh` 会先交叉编译 `jsapi` 产出 `.so`，再构建前端 `.amr`

## GitHub Actions（多架构）

- Workflow: `.github/workflows/build-multi-arch.yml`
- 矩阵：`s6` + `a6`
- 每个架构都会上传：
  - `.amr` 包
  - `libs/*.so`
  - `jsapi/build/<device>` 下的 `.so/.a`

## 屏幕适配

- 在 `src/app.js` 使用 `setViewPort(800)`
- 页面按 `800px` 宽设计，适配词典笔长条小屏
- 右侧日志区域使用 `scroller` 防止小屏裁切
