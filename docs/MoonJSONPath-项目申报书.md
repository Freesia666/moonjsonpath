# MoonJSONPath 项目申报书

**项目名称**：MoonJSONPath：MoonBit 原生 JSON Pointer 与 JSONPath 查询工具

**项目方向**：MoonBit 工程基础设施 / JSON 数据查询与定位基础库

**是否为原创项目**：原创项目。项目参考 JSON Pointer RFC 6901 与 JSONPath RFC 9535 标准，但核心解析器、查询执行器、错误诊断、修改 API 与示例均使用 MoonBit 原生实现。

**项目简介**

MoonJSONPath 面向 MoonBit 工具链、配置处理、API 客户端、测试 fixture、LLM tool-call 数据处理等场景，提供对 JSON 文档的标准化定位、查询和轻量修改能力。开发者可以使用 JSON Pointer 精确访问或更新一个节点，也可以使用 JSONPath 从复杂 JSON 中批量查询匹配值，并获得每个匹配值对应的 JSON Pointer 路径，便于错误诊断、日志输出和后续修改。

**核心功能范围**

- 支持 JSON Pointer 解析、RFC 6901 转义、格式化、`get`、`set`、`remove`。
- 支持 JSON Pointer URI fragment 互转，覆盖 `#`、percent decoding 与常见转义场景。
- 支持 JSONPath 核心子集：根选择 `$`、成员访问、quoted member selector、数组索引、negative index、union selector、通配符、递归成员查询、正反向数组切片和过滤表达式。
- 扩展过滤表达式能力：`&&`、`||`、`!`、括号分组、字符串 `contains` / `starts_with` / `ends_with`、数组或字符串 `.length` 检查。
- 查询结果同时返回匹配 JSON 值和对应 Pointer 路径。
- 提供 `query_json_text`、`query_json_file`、`first`、`exists`、`values`、`pointers`、`explain` 等查询入口，用于解析 JSON 字符串或文件并输出查询结果。
- 提供 Pointer Patch 层，支持 `add`、`replace`、`remove`、`test`、`copy`、`move`，用于轻量 JSON 文档变换。
- 支持 values、pointers、matches 三种输出模式，matches 模式返回 `{ path, value }` 结构，适合诊断和工具链集成。
- 提供 Path canonical formatter、explain API 和错误诊断文本，方便 CLI、测试和文档展示。
- 提供 `query`、`get`、`set`、`remove`、`patch` 文件型 CLI 子命令。
- 提供 cookbook、scenario catalog、operator reference、readiness matrix、submission evidence、longform handbook 等结构化示例与申报材料生成入口。
- 提供 `cmd/main` 可运行示例、README 示例和测试用例。
- 当前 MoonBit 源码规模约 7k 行，包含核心库、CLI、测试、conformance catalog、workflow catalog 与文档生成数据源。
- 使用 `moon check` 与 `moon test` 进行本地验收。

**预期交付**

项目将交付一个可发布到 mooncakes.io 的 MoonBit 库、一个可运行文件输入 CLI、完整 README、Apache-2.0 许可证、核心测试和 GitHub/Gitlink 同步仓库。远期可扩展方向包括更完整 RFC 9535 conformance 导入、正则谓词、stdin 读取适配、JSON Patch 互操作和更多性能/压力测试。
