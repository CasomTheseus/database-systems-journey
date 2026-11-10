-- =============================================================
--  第 4 章 · 数据库安全性（一）：授权与回收
--
--  ⚠️ 本文件必须用 root 执行（涉及建用户、建角色）：
--     mysql -u root -p < "sql/ch04-数据库安全性/01_授权与回收_root.sql"
-- =============================================================

-- ------------------------------------------------------------
-- 1. 建两个实验账号，只给最小必要权限
-- ------------------------------------------------------------
CREATE USER IF NOT EXISTS 'stu_a'@'localhost' IDENTIFIED BY 'stu_a_pwd';
CREATE USER IF NOT EXISTS 'stu_b'@'localhost' IDENTIFIED BY 'stu_b_pwd';

-- 列级授权：stu_a 只能看学号和姓名，看不到年龄、系别
GRANT SELECT (Sno, Sname) ON dbs_course.Student TO 'stu_a'@'localhost';

-- 表级授权 + 允许转授
GRANT SELECT ON dbs_course.SC TO 'stu_b'@'localhost' WITH GRANT OPTION;

-- ------------------------------------------------------------
-- 2. 查一下授出去了什么（SHOW GRANTS 是最可靠的审计手段）
-- ------------------------------------------------------------
SHOW GRANTS FOR 'stu_a'@'localhost';
SHOW GRANTS FOR 'stu_b'@'localhost';

-- ------------------------------------------------------------
-- 3. 回收权限
-- ------------------------------------------------------------
REVOKE SELECT (Sno, Sname) ON dbs_course.Student FROM 'stu_a'@'localhost';

-- 回收转授权：MySQL 里收回「转授权」要单独用 REVOKE GRANT OPTION，
-- 语法是 ... FROM user（CASCADE 只用于回收角色，用在权限上是语法错误 ERROR 1064）
REVOKE GRANT OPTION ON dbs_course.SC FROM 'stu_b'@'localhost';

-- 再彻底收回查询权限
REVOKE SELECT ON dbs_course.SC FROM 'stu_b'@'localhost';

-- ------------------------------------------------------------
-- 4. 角色：把一组权限打包，按岗位授予（MySQL 8+ 支持）
-- ------------------------------------------------------------
CREATE ROLE IF NOT EXISTS 'reader';
GRANT SELECT ON dbs_course.* TO 'reader';

-- 把角色授予用户，并设为默认激活
GRANT 'reader' TO 'stu_b'@'localhost';
SET DEFAULT ROLE 'reader' TO 'stu_b'@'localhost';

-- 查角色里有什么权限
SHOW GRANTS FOR 'reader';

-- ------------------------------------------------------------
-- 5. 清理（下次重跑不会冲突）
-- ------------------------------------------------------------
-- DROP USER IF EXISTS 'stu_a'@'localhost', 'stu_b'@'localhost';
-- DROP ROLE IF EXISTS 'reader';

-- 结论：
--   权限粒度：全局 (*.*) → 数据库 (db.*) → 表 (db.t) → 列 (db.t(col))；
--   给权限要「最小必要」，WITH GRANT OPTION 会让权限扩散，回收时记得 CASCADE。
