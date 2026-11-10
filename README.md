# 数据库系统 · 学习进度仓库

> 学期中零基础起步，用 10 周把《数据库系统概论》（王珊，第 5/6 版）从第 1 章推到第 11 章，
> 每天一次 commit，每周一篇笔记，所有 SQL 都能在本地 MySQL 上跑通。

![status](https://img.shields.io/badge/进度-第1周%20%2F%2010-brightgreen)
![mysql](https://img.shields.io/badge/MySQL-26.10-4479A1?logo=mysql&logoColor=white)
![sqlite](https://img.shields.io/badge/SQLite-3.51-003B57?logo=sqlite&logoColor=white)

---

## 这是什么

这是一个**学习型仓库**：不是教程搬运，而是我自己的学习痕迹。包含

- **可执行的环境**：一套 `setup/` 脚本，在任何机器上重建教材里的「学生-课程-选课」示例库；
- **按章节组织的 SQL 练习**：每章从建表到查询，全部带可验证的答案；
- **每周笔记与打卡**：`notes/` 里是概念梳理（自己的话），`PROGRESS.md` 是进度表；
- **每日日志**：`logs/` 里记录当天学了什么、卡在哪、明天做什么。

## 本机环境（已实测通过）

| 组件 | 版本 / 状态 | 备注 |
|---|---|---|
| macOS | 26.3.1 · arm64 | Apple Silicon |
| MySQL | 26.10.0（Homebrew），已作为服务运行 | `127.0.0.1:3306`，socket `/tmp/mysql.sock` |
| SQLite | 3.51.0（系统自带） | 离线练习 / 便携备份 |
| 学习账号 | `learn@localhost`，密码 `learn1234` | 仅对 `dbs_course`、`scratch` 有权限，不碰 root |
| 课程库 | `dbs_course` | 4 名学生 · 7 门课 · 5 条选课记录 |
| 练习库 | `scratch` | 随便建表、随便删，练手专用 |
| Git / gh | 2.39.5 / 2.98.0 | `gh` 已登录 `CasomTheseus` |

> 环境检查脚本：`bash setup/check_env.sh`，一次打印上面这张表并实测连接。

## 快速开始

```bash
# 1. 连上课程库，进交互式命令行
./scripts/db.sh

# 2. 直接执行一条 SQL
./scripts/db.sh -e "SELECT * FROM Student;"

# 3. 跑某个练习文件
./scripts/db.sh < sql/ch03-关系数据库标准语言SQL/01_单表查询.sql

# 4. 重建整个示例库（会清空 dbs_course，需要 root 密码）
mysql -u root -p < setup/mysql_setup.sql

# 5. 不带 MySQL 时，用 SQLite 离线跑同一套练习
sqlite3 dbs_course.db < setup/sqlite_setup.sql
```

## 学习路线（10 周，学期中冲刺版）

| 周次 | 日期 | 主题 | 教材 | 产出 |
|:--:|---|---|---|---|
| 1 | 11/09–11/15 | 数据库基础 + 关系模型 + 关系代数 | 第 1、2 章 | 笔记 1 + 关系代数 20 题 |
| 2 | 11/16–11/22 | SQL 基础：DDL、单表查询、连接查询 | 第 3 章（上） | SQL 练习集 A |
| 3 | 11/23–11/29 | SQL 进阶：嵌套查询、集合查询、视图、索引 | 第 3 章（下） | SQL 练习集 B |
| 4 | 11/30–12/06 | 数据库安全性 + 完整性 | 第 4、5 章 | 授权/约束实验 |
| 5 | 12/07–12/13 | 关系数据理论：函数依赖与范式 | 第 6 章 | 范式判定 15 题 |
| 6 | 12/14–12/20 | 数据库设计：E-R 模型与逻辑设计 | 第 7 章 | 一个完整设计文档 |
| 7 | 12/21–12/27 | 数据库编程：存储过程、触发器、JDBC | 第 8 章 | 可跑的存储过程 |
| 8 | 12/28–01/03 | 查询处理与查询优化 | 第 9 章 | EXPLAIN 分析报告 |
| 9 | 01/04–01/10 | 事务、恢复技术、并发控制 | 第 10、11 章 | 隔离级别实验 |
| 10 | 01/11–01/17 | 综合项目 + 期末冲刺 | 全书 | 迷你系统 + 模拟卷 |

详细任务拆解见 [ROADMAP.md](ROADMAP.md)，逐周打卡见 [PROGRESS.md](PROGRESS.md)。

## 目录结构

```
database-systems-journey/
├── README.md              # 项目说明（你在这里）
├── ROADMAP.md             # 10 周详细任务拆解
├── PROGRESS.md            # 逐周进度打卡表
├── setup/
│   ├── mysql_setup.sql    # 建学习账号 + 课程库 + 教材样例数据
│   ├── sqlite_setup.sql   # 同一模式的 SQLite 版
│   └── check_env.sh       # 环境自检
├── scripts/
│   └── db.sh              # 一行连库跑 SQL 的包装脚本
├── sql/                   # 按章节的 SQL 练习（可执行、可对照）
├── notes/                 # 每周笔记，weekNN/README.md
├── labs/                  # 上机实验报告
├── exercises/             # 习题与自测答案
└── logs/                  # 每日学习日志 YYYY-MM-DD.md
```

## 学习方法

每章走三步，缺一不可：

1. **读**：教材通读一遍，只求看懂名词，不求记住；
2. **写**：合上书，用自己的话把本章写成 `notes/weekNN/README.md`，写不出来的地方就是没懂的地方；
3. **跑**：在 MySQL 里把本章的 SQL 全部手敲一遍，故意写错几次（拼错表名、漏 GROUP BY），看报错怎么提示。

> 判断标准：能向别人讲清楚「为什么需要这个机制」，而不是「这个语法怎么写」。

## 进度

第 1 周 / 共 10 周 · 详见 [PROGRESS.md](PROGRESS.md)
