# DevUDisk 5 分钟上手指南

> 适用于 ESP32 教学 / 竞赛 / 现场开发的便携 Arduino 环境

## 1. 插上 U 盘

将 U 盘插入电脑 USB 3.0 接口（蓝色接口）。

## 2. 启动开发环境

打开文件资源管理器，进入 U 盘根目录，**双击 `StartDevEnv.bat`**。

- 首次使用或需要 RAMDisk 加速时，建议**右键 → 以管理员身份运行**。
- 普通用户模式下，构建目录会自动回退到本地临时目录，速度仍明显快于直接在 U 盘构建。

脚本会：
1. 自动识别 U 盘盘符（D:、E:、F: 等均可）。
2. 校验 U 盘内 Arduino 环境完整性。
3. 启动 VS Code: 便携版并打开 **`DevUDisk.code-workspace`** 工作区（包含 Blink、WiFiScan 等示例工程）。

## 3. 打开示例工程

在 VS Code: 左侧资源管理器中点击工作区里的：

```text
Blink → Blink.ino
```

## 4. 编译工程

按 **`Ctrl + Shift + B`** 直接运行默认构建任务：

- **Arduino: Build (RAMDisk)**：编译当前工程。

终端会显示：

```text
[INFO] 开始编译 ...
[INFO] FQBN: esp32:esp32:esp32
[INFO] 工程目录: D:\Projects\Blink
[INFO] 开始时间: 12:34:56.789
[INFO] 编译中 ........................
[INFO] 编译成功。
[INFO] 结束时间: 12:35:45.123
[INFO] 总用时: 00:48.334
```

编译过程中会输出流动的 `.` 进度点，结束后显示总用时。首次编译会花费较长时间（约 1–3 分钟），因为需要编译 ESP32 核心；后续编译会使用缓存，速度显著提升。

> 如果要在工作区里添加自己的工程，右键左侧资源管理器空白处 → **Add Folder to Workspace**。

## 5. 上传固件

1. 使用 USB 线连接 ESP32 开发板。
2. 在设备管理器中确认串口号（如 `COM3`）。
3. 修改 `.vscode/tasks.json` 中 `Arduino: Upload` 任务的 `--port` 参数为实际串口号。
4. 按 **`Ctrl + Shift + P`**，输入 **Tasks: Run Task**，选择 **Arduino: Upload**。

> 如果开发板未被识别，请手动安装 `PortableEnv\Drivers\CH343` 或 `CP210x` 目录下的驱动。

## 6. 查看串口输出

按 **`Ctrl + Shift + P`**，选择 **Terminal: New Terminal**，在终端中执行：

```bat
arduino-cli monitor -p COM3 -b esp32:esp32:esp32
```

（将 `COM3` 替换为实际串口号）

## 7. 使用 Git（可选）

如果 U 盘内置了 `PortableEnv\Git\`，或本机已安装 Git，启动环境后 VS Code: 终端中可直接使用 git：

```bat
git clone git@github.com:DonkeyDrift/MUS4_FW.git
```

如果启动脚本提示未找到 Git，可：

1. 从 [git-scm.com](https://git-scm.com/download/win) 下载 **64-bit Git for Windows Portable**。
2. 解压到 U 盘 `PortableEnv\Git\` 目录，确保存在 `PortableEnv\Git\cmd\git.exe`。
3. 重新运行 `StartDevEnv.bat`。

> 在未内置 Git 且本机也未安装 Git 的电脑上，VS Code: 终端中无法执行 git 命令，但不影响 Arduino 编译与上传。

## 8. 安全退出

完成开发后，双击 U 盘根目录的 **`StopDevEnv.bat`**：

- 关闭 VS Code。
- 卸载 RAMDisk（如以管理员身份运行）。
- 清理本地临时构建目录。
- 弹出 U 盘。

待提示"可以安全拔出 U 盘"后再拔出。

---

## 常见问题

### Q1：双击 `StartDevEnv.bat` 后闪退
右键 → 以管理员身份运行，查看具体错误信息。

### Q2：编译提示找不到 `cmd` 或 `powershell`
请确保 `StartDevEnv.bat` 中 PATH 包含 `C:\Windows\System32` 和 PowerShell 目录（默认已配置）。

### Q3：RAMDisk 没有创建
ImDisk 驱动需要单独安装。当前版本优先使用本地临时目录作为回退方案，仍可正常使用。如需 RAMDisk，请从 ImDisk 官网下载并安装驱动后，以管理员身份运行 `StartDevEnv.bat`。

### Q4：能否同时使用本机已安装的 Arduino IDE？
本 U 盘采用路径隔离设计，`PATH` 仅指向 U 盘内工具，不会与本机 Arduino 环境冲突。

### Q5：VS Code: 终端提示 `'git' is not recognized`
启动脚本会优先使用 U 盘内置 Git；如未内置，则自动回退到本机 Git。若两者都未找到，请在 `PortableEnv\` 下解压 Portable Git for Windows，或在本机安装 Git 后重新启动环境。
