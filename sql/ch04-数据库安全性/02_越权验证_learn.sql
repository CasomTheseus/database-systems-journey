-- =============================================================
--  第 4 章 · 数据库安全性（二）：越权验证
--
--  用 learn 账号跑，故意做没权限的事，观察报错：
--     ./scripts/db.sh < "sql/ch04-数据库安全性/02_越权验证_learn.sql"
--
--  每条「应该失败」的语句都包在 mysql --force 下才不会中断脚本，
--  这里用 SELECT 先确认自己有哪些权限，再逐条手工试。
-- =============================================================

USE dbs_course;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. 我现在是谁、有什么权限？
--    CURRENT_USER() 返回实际生效的账号
-- ------------------------------------------------------------
SELECT CURRENT_USER() AS 当前账号, USER() AS 连接账号;

SHOW GRANTS;

-- ------------------------------------------------------------
-- 2. learn 能干什么：对 dbs_course 有 ALL，所以建表可以
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS t_security_demo (id INT PRIMARY KEY);
DROP TABLE IF EXISTS t_security_demo;

-- ------------------------------------------------------------
-- 3. learn 不能干什么（把下面注释去掉，逐条手工验证报错文案）
--
--    (a) 读系统库 mysql.user
--        ERROR 1142 (42000): SELECT command denied to user 'learn'@'localhost' for table 'user'
--    SELECT user, host FROM mysql.user;
--
--    (b) 建新库
--        ERROR 1044 (42000): Access denied for user 'learn'@'localhost' to database 'secret_db'
--    CREATE DATABASE secret_db;
--
--    (c) 给别的库建表（BANK285 是别的项目，learn 没有权限）
--        ERROR 1044 (42000): Access denied for user 'learn'@'localhost' to database 'BANK285'
--    CREATE TABLE BANK285.hack (id INT);
--
--    (d) 建用户
--        ERROR 1227 (42000): Access denied; you need (at least one of) the CREATE USER privilege(s)
--    CREATE USER 'hacker'@'localhost' IDENTIFIED BY 'x';
-- ------------------------------------------------------------

-- ------------------------------------------------------------
-- 4. 一个真实的教训：权限不足时，报错信息会泄露「库/表是否存在」
--    攻击者能据此探测结构，所以生产环境连报错文案都要控制。
-- ------------------------------------------------------------
SELECT '越权测试完成：把上面注释掉的语句逐条跑一遍，抄下报错原文' AS 提示;
