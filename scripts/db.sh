#!/usr/bin/env bash
# 一行连库跑 SQL。
#
#   ./scripts/db.sh                      # 进入交互式命令行
#   ./scripts/db.sh -e "SELECT 1"        # 执行一条语句
#   ./scripts/db.sh < some.sql           # 执行文件
#   DB=scratch ./scripts/db.sh           # 换库
#
# 默认使用 learn@localhost，避免误用 root。
set -euo pipefail

DB="${DB:-dbs_course}"
MYSQL_USER="${MYSQL_USER:-learn}"
MYSQL_PWD="${MYSQL_PWD:-learn1234}"
export MYSQL_PWD

exec mysql -u "$MYSQL_USER" --default-character-set=utf8mb4 "$DB" "$@"
