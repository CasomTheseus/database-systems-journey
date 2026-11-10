#!/usr/bin/env bash
# 数据库学习环境自检：只读，不改任何东西。
#   bash setup/check_env.sh
set -uo pipefail

ok()   { printf '  \033[32m✓\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31m✗\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m!\033[0m %s\n' "$1"; }

echo
echo "== 系统 =="
ok "$(sw_vers -productName) $(sw_vers -productVersion) · $(uname -m)"

echo
echo "== MySQL 服务 =="
if command -v mysql >/dev/null 2>&1; then
  ok "客户端 $(mysql --version | awk "{print \$3}")"
else
  bad "未安装 MySQL 客户端"
fi

if lsof -nP -iTCP:3306 -sTCP:LISTEN >/dev/null 2>&1; then
  ok "3306 端口监听中"
  MYSQL_PWD="${MYSQL_PWD:-learn1234}" \
    mysql -u "${MYSQL_USER:-learn}" -N -e "SELECT 1" >/dev/null 2>&1 \
    && ok "learn 账号连接成功" \
    || warn "learn 账号连不上（先跑 setup/mysql_setup.sql）"
  MYSQL_PWD="${MYSQL_PWD:-learn1234}" \
    mysql -u "${MYSQL_USER:-learn}" -N dbs_course -e "SELECT COUNT(*) FROM SC" 2>/dev/null \
    | grep -q '^[0-9]' && ok "dbs_course 可访问（SC 表有数据）" \
    || warn "dbs_course 不可用，需要初始化"
else
  bad "3306 未监听，执行 brew services start mysql"
fi

echo
echo "== SQLite =="
if command -v sqlite3 >/dev/null 2>&1; then
  ok "$(sqlite3 --version | awk '{print "v" $1}')（离线备用）"
else
  warn "未安装 sqlite3"
fi

echo
echo "== 工具链 =="
git --version >/dev/null 2>&1 && ok "$(git --version)" || bad "缺少 git"
if command -v gh >/dev/null 2>&1; then
  gh auth status >/dev/null 2>&1 && ok "gh 已登录 $(gh api user --jq .login 2>/dev/null)" || warn "gh 未登录"
else
  warn "未安装 gh"
fi

echo
echo "== 课程库内容 =="
MYSQL_PWD="${MYSQL_PWD:-learn1234}" \
  mysql -u "${MYSQL_USER:-learn}" --default-character-set=utf8mb4 dbs_course -e "
    SELECT 'Student' AS 表, COUNT(*) AS 行数 FROM Student
    UNION ALL SELECT 'Course', COUNT(*) FROM Course
    UNION ALL SELECT 'SC', COUNT(*) FROM SC;" 2>/dev/null \
  || warn "查不到课程库，先执行 mysql -u root -p < setup/mysql_setup.sql"
echo
