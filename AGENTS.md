# DevUDisk 项目代理指南

> 本文档面向需要在该仓库中工作的 AI 编码代理。阅读前假设你对项目一无所知。

---

## 1. 项目概述

**DevUDisk** 是一个面向 ESP32 教学、竞赛与现场开发的“编程 U 盘”设计与制作方案仓库。

- **仓库地址：** `https://github.com/Haobot/DevUDisk.git`
- **当前分支：** `main`
- **当前状态：** 仓库目前仅包含一份设计规划文档，实际 U 盘制作脚本与工具链尚未加入版本控制。
- **核心目标：** 实现“插上即用、环境隔离、极速编译、AI 辅助、批量交付”的便携式 ESP32 开发环境。

### 1.1 已存在的文件

```text
D:/
├── .git/                         # Git 仓库
├── Doc/
│   └── DevUDisk_Plan_v1.0.md     # 《编程 U 盘设计与制作方案 v1.0》
└── AGENTS.md                     # 本文件
```

> **注意：** 除 `Doc/DevUDisk_Plan_v1.0.md` 外，仓库中没有任何源代码、构建配置文件或测试文件。

---

## 2. 技术栈与运行时架构

根据现有规划文档，项目拟采用以下技术栈：

| 层级 | 技术 / 工具 | 说明 |
| :--- | :--- | :--- |
| 操作系统 | Windows 原生 | 机房兼容性优先，不使用 WSL |
| 文件系统 | NTFS（4K 簇） | 支持权限、符号链接、Git 操作 |
| 启动脚本 | Windows Batch (`.bat`) | `StartDevEnv.bat`、`StopDevEnv.bat`、`_env_init.bat` |
| 编辑器 | VS Code 便携版 | 配置锁定在 `VSCode\data` 目录 |
| 开发框架 | ESP-IDF v5.x LTS | 离线预装，路径 `PortableEnv\esp-idf` |
| 编程语言 | Python（嵌入式） | 用于 ESP-IDF 构建系统 |
| 版本控制 | Portable Git | 仅使用 U 盘内 Git |
| 编译加速 | RAMDisk（ImDisk） | 构建目录映射到 `R:\esp_build\[ProjectName]` |
| 编译工具 | cmake + ninja + ccache | ESP-IDF 标准工具链 |
| AI 辅助 | Continue 插件 | 模型由学生自备 API Key |

### 2.1 规划中的目录结构

```text
ESP32_DEV (U:\)
├── StartDevEnv.bat
├── StopDevEnv.bat
├── PortableEnv\
│   ├── _env_init.bat
│   ├── VSCode\
│   ├── Python\
│   ├── Git\
│   ├── ImDisk\
│   ├── tools-bin\
│   ├── esp-idf\
│   └── Drivers\
├── Projects\
└── Docs\
```

### 2.2 核心运行原则

1. **Zero Installation**：不依赖主机安装任何软件，除 RAMDisk 外无需管理员权限。
2. **Path Isolation**：所有工具路径通过启动脚本注入，禁止依赖系统 `PATH` 搜索。
3. **Performance First**：源码保留在 U 盘，编译发生在 RAMDisk，避免 U 盘 I/O 瓶颈。

---

## 3. 代码组织

当前仓库无代码。规划中的模块划分如下：

- **入口脚本**
  - `StartDevEnv.bat`：请求管理员权限、计算 U 盘盘符、构造隔离 `PATH`、创建 RAMDisk、设置 ESP-IDF 环境变量、启动 VS Code。
  - `StopDevEnv.bat`：结束 VS Code、可选备份 build 缓存、卸载 RAMDisk、弹出 U 盘。
- **环境初始化**
  - `PortableEnv\_env_init.bat`：校验 U 盘剩余空间、Python / Git 可执行性、ESP-IDF 工具链完整性。
- **工具目录**
  - `PortableEnv\VSCode\`、`Python\`、`Git\`、`ImDisk\`、`tools-bin\`、`esp-idf\`、`Drivers\`。
- **用户空间**
  - `Projects\`：学生工程目录（Git 仓库）。
  - `Docs\`：离线文档。

---

## 4. 构建与测试命令

### 4.1 当前仓库

由于仓库仅包含 Markdown 文档，**没有可执行代码、构建脚本或测试套件**。无需运行构建命令。

### 4.2 规划中 ESP32 工程的构建流程

按规划，学生工程构建将在 VS Code 内通过 ESP-IDF 插件完成，等价于：

```bat
set IDF_PATH=U:\PortableEnv\esp-idf
set IDF_CCACHE_ENABLE=1
set ESP_IDF_BUILD_DIR=R:\esp_build\%workspace%
idf.py build
```

> 注意：以上命令仅为规划文档中的描述，当前仓库未提供这些脚本或工具链。

---

## 5. 代码风格与开发规范

根据规划文档，未来添加脚本时应遵守以下约定：

### 5.1 Batch 脚本

- **路径解析**：使用 `%~dp0` 动态计算脚本所在目录，禁止硬编码盘符。
- **PATH 构造**：采用“收缩式注入”，仅包含 U 盘内工具路径，例如：

  ```bat
  set PATH=U:\PortableEnv\Git\cmd;U:\PortableEnv\Python;U:\PortableEnv\tools-bin
  ```

- **禁止行为**：不要使用 `where python`、`where git`、`dir /s` 等依赖系统搜索的命令。
- **管理员权限**：仅在创建/卸载 RAMDisk 时请求管理员权限。

### 5.2 文档

- 项目主要使用**中文**编写方案与说明。
- 新文档应放置在 `Doc/` 目录下，并采用 Markdown 格式。
- 版本号、生效日期、状态字段需与 `DevUDisk_Plan_v1.0.md` 保持一致的风格。

---

## 6. 测试策略

当前仓库无自动化测试。规划文档中列出的验证清单如下：

| 测试项 | 预期结果 |
| :--- | :--- |
| 插拔 U 盘 | 盘符变化不影响启动 |
| 脏机器测试 | 已安装 Python/Git 的主机仍能正常运行 |
| 编译速度 | 比无 RAMDisk 快 ≥ 30% |
| AI 辅助 | Continue 插件可正常补全代码 |
| 安全退出 | 无文件残留，可正常弹出 U 盘 |

如需补充测试，建议优先添加：

1. Batch 脚本的语法检查（`batfile` 或手动执行）。
2. 路径注入是否泄露到系统 `PATH` 的断言。
3. RAMDisk 创建/卸载的幂等性测试。

---

## 7. 部署与交付

### 7.1 母盘制作流程（规划中）

1. 格式化 U 盘：NTFS / 4K 簇 / 卷标 `ESP32_DEV`。
2. 部署 VS Code 便携版、嵌入式 Python、Portable Git。
3. 集成 ESP-IDF（递归克隆并运行 `install.bat`）。
4. 部署 ImDisk 与驱动包。
5. 预装 VS Code 插件（ESP-IDF Extension、Continue）。
6. 编写并放置 `StartDevEnv.bat` 与 `StopDevEnv.bat`。

### 7.2 量产方案

- 使用 Win32 Disk Imager 制作镜像 `ESP32_Dev_v1.0.img`。
- 使用 Rufus / BalenaEtcher 批量烧录到同型号 U 盘。

---

## 8. 安全与风险控制

| 风险 | 应对措施 |
| :--- | :--- |
| 串口驱动缺失 | U 盘内置 CH341/CP210x 驱动包，首次手动安装 |
| 机房禁用管理员权限 | 提前协调管理员，或提供无 RAMDisk 降级模式 |
| U 盘异常拔出 | 依赖 NTFS 日志恢复；学生源码保存在 U 盘，损失风险低 |
| 杀毒软件误报 | 提前将 U 盘路径加入机房白名单 |
| 路径泄露 | 脚本中严格使用 `%~dp0` 与隔离 `PATH`，避免调用系统工具 |

---

## 9. 给代理的实用提示

- 修改前请先检查 `Doc/DevUDisk_Plan_v1.0.md`，所有实现都应与方案一致。
- 当前仓库没有 `pyproject.toml`、`package.json`、`Cargo.toml` 或任何 CI/CD 配置文件；若添加实际代码，请根据语言补充相应配置。
- 由于项目面向教学场景，脚本与文档应优先保证**可读性**和**可维护性**，避免过度工程化。
- 若需引入新依赖，必须确保其能运行在便携/离线环境中。
