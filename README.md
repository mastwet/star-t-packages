# STAR-T Packages

STAR-T 服务包的构建模板和目录索引。

本仓库不包含任何服务二进制。CI 流水线根据 `services/` 下的定义，从官方源下载、打包为 `.star` 格式，发布到 GitHub Releases。

## 仓库结构

```
services/
├── jdk/                    # Eclipse Temurin JDK (8 / 17 / 21)
│   ├── jdk-8/
│   ├── jdk-17/
│   └── jdk-21/             ← meta.json + build.ps1
├── tomcat/                 # Apache Tomcat 10.1 (Jakarta EE 10)
├── tomcat9/                # Apache Tomcat 9 (javax.* 兼容)
├── redis/                  # Redis for Windows
├── mysql/                  # MySQL Community Server
└── nginx/                  # Nginx
registry.json               ← 服务目录索引（STAR-T 客户端拉取此文件）
THIRD-PARTY-LICENSES.md     ← 第三方许可证清单
```

## .star 格式

每个 `.star` 文件是一个 ZIP，内部结构：

```
{service}-{version}-win-x64.star
├── bin/                # 可执行文件和运行时
├── conf/               # 配置模板（含占位符）
├── scripts/            # install.cmd / uninstall.cmd
└── meta.json           # 服务元数据
```

## 构建

### 手动构建（本地）

```powershell
# 构建单个服务
cd services/tomcat
.\build.ps1 -Version 10.1.41 -OutputDir ../../dist

# 输出：dist/tomcat-10.1.41-win-x64.star
```

### CI 构建（GitHub Actions）

1. 进入 Actions → "Build Service Package"
2. 选择服务和版本
3. 运行 → 产物出现在 Artifacts 中

## 添加新服务

1. 创建 `services/{name}/` 目录
2. 编写 `meta.json`（参考现有服务）
3. 编写 `build.ps1`（下载 → 解压 → 组装 → 打包）
4. 可选：`conf/` 放配置模板，`scripts/` 放生命周期脚本
5. 更新 `registry.json` 添加对应条目
6. 提 PR，CI 验证后合并

## License

STAR-T Packages 本身采用 [MIT License](LICENSE)。
捆绑的第三方软件许可证见 [THIRD-PARTY-LICENSES.md](THIRD-PARTY-LICENSES.md)。
