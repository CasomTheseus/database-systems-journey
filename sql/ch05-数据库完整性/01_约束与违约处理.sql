-- =============================================================
--  第 5 章 · 数据库完整性
--  实体完整性 / 参照完整性 / 用户定义完整性 + 违约处理
--  运行：DB=scratch ./scripts/db.sh < "sql/ch05-数据库完整性/01_约束与违约处理.sql"
--  说明：全部在 scratch 库做实验，随便删建，不影响课程库。
-- =============================================================

CREATE DATABASE IF NOT EXISTS scratch;
USE scratch;
SET NAMES utf8mb4;

DROP TABLE IF EXISTS 选课;
DROP TABLE IF EXISTS 课程;
DROP TABLE IF EXISTS 学生;

-- ------------------------------------------------------------
-- 1. 实体完整性：主码（PRIMARY KEY）
--    主码 = 唯一 + 非空，数据库自动建唯一索引
-- ------------------------------------------------------------
CREATE TABLE 学生 (
  Sno   CHAR(9)  PRIMARY KEY,
  Sname VARCHAR(20) NOT NULL,
  Sage  TINYINT  CHECK (Sage BETWEEN 15 AND 45)
);

-- 违反实体完整性：主码重复
-- ERROR 1062 (23000): Duplicate entry '200215121' for key '学生.PRIMARY'

-- 违反实体完整性：主码为空
-- ERROR 1364 (HY000): Field 'Sno' doesn't have a default value
-- （注意：MySQL 对 CHAR 主码插 NULL 时报的是「没有默认值」，
--   严格模式下等价于拒绝，效果一样）

-- ------------------------------------------------------------
-- 2. 参照完整性：外码 + 三种违约处理
--    RESTRICT / NO ACTION：拒绝（默认）
--    CASCADE            ：级联（删父删子、改父改子）
--    SET NULL           ：置空（外码列必须允许 NULL）
-- ------------------------------------------------------------
CREATE TABLE 课程 (
  Cno  CHAR(4) PRIMARY KEY,
  Cname VARCHAR(40) NOT NULL,
  Ccredit TINYINT DEFAULT 2
);

CREATE TABLE 选课 (
  Sno   CHAR(9),
  Cno   CHAR(4),
  Grade TINYINT,
  PRIMARY KEY (Sno, Cno),
  CONSTRAINT fk_sc_sno FOREIGN KEY (Sno) REFERENCES 学生(Sno)
      ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_sc_cno FOREIGN KEY (Cno) REFERENCES 课程(Cno)
      ON DELETE RESTRICT ON UPDATE CASCADE
);

INSERT INTO 学生 VALUES ('200215121','李勇',20), ('200215122','刘晨',19);
INSERT INTO 课程 VALUES ('1','数据库',4), ('2','数学',2);
INSERT INTO 选课 VALUES ('200215121','1',92), ('200215122','1',85), ('200215121','2',90);

SELECT * FROM 选课;

-- 违反参照完整性：插一个不存在的学号
-- ERROR 1452 (23000): Cannot add or update a child row: a foreign key constraint fails
-- INSERT INTO 选课 VALUES ('999999999','1',60);

-- 违反参照完整性：删掉还被引用的课程
-- ERROR 1451 (23000): Cannot delete or update a parent row: a foreign key constraint fails
-- DELETE FROM 课程 WHERE Cno = '1';

-- 级联删除：删学生，他的选课记录跟着没了
DELETE FROM 学生 WHERE Sno = '200215121';
SELECT * FROM 选课;    -- 只剩刘晨那一条

-- ------------------------------------------------------------
-- 3. 用户定义完整性：CHECK / NOT NULL / UNIQUE / DEFAULT
-- ------------------------------------------------------------
DROP TABLE IF EXISTS 员工;
CREATE TABLE 员工 (
  E_id   INT PRIMARY KEY,
  E_name VARCHAR(20) NOT NULL UNIQUE,
  E_age  TINYINT CHECK (E_age >= 18),
  E_sex  CHAR(2) CHECK (E_sex IN ('男','女')),
  E_dept VARCHAR(20) DEFAULT '未分配'
);

INSERT INTO 员工 (E_id, E_name, E_age, E_sex) VALUES (1, '张三', 25, '男');
SELECT * FROM 员工;    -- E_dept 自动填了「未分配」

-- 违反 CHECK：年龄 16
-- ERROR 3819 (HY000): Check constraint '员工_chk_1' is violated.
-- INSERT INTO 员工 (E_id,E_name,E_age,E_sex) VALUES (2,'李四',16,'男');

-- 违反 UNIQUE：重名
-- ERROR 1062 (23000): Duplicate entry '张三' for key '员工.E_name'
-- INSERT INTO 员工 (E_id,E_name,E_age,E_sex) VALUES (2,'张三',30,'女');

-- ------------------------------------------------------------
-- 4. 约束表达不了的规则 → 触发器
--    例：选课成绩只能在「课程存在且学生存在」时录入，
--    这类跨表条件 CHECK 写不了，得用触发器。
-- ------------------------------------------------------------
DROP TRIGGER IF EXISTS trg_sc_grade;
DELIMITER $$
CREATE TRIGGER trg_sc_grade
BEFORE INSERT ON 选课
FOR EACH ROW
BEGIN
  IF NEW.Grade IS NOT NULL AND (NEW.Grade < 0 OR NEW.Grade > 100) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '成绩必须在 0-100 之间';
  END IF;
END$$
DELIMITER ;

-- 触发触发器（会失败）
-- ERROR 1644 (45000): 成绩必须在 0-100 之间
-- INSERT INTO 选课 VALUES ('200215122','2',150);

-- ------------------------------------------------------------
-- 5. 约束存在哪：数据字典里能查到
-- ------------------------------------------------------------
SELECT TABLE_NAME, CONSTRAINT_NAME, CONSTRAINT_TYPE
FROM information_schema.TABLE_CONSTRAINTS
WHERE TABLE_SCHEMA = 'scratch' AND TABLE_NAME IN ('学生','课程','选课','员工');

SELECT CONSTRAINT_NAME, CHECK_CLAUSE
FROM information_schema.CHECK_CONSTRAINTS
WHERE CONSTRAINT_SCHEMA = 'scratch';

-- 清理
DROP TRIGGER IF EXISTS trg_sc_grade;
DROP TABLE IF EXISTS 选课;
DROP TABLE IF EXISTS 课程;
DROP TABLE IF EXISTS 学生;
DROP TABLE IF EXISTS 员工;
