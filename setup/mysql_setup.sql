-- =============================================================
--  数据库系统 学习环境初始化脚本（MySQL 8+/9+，本机实测 26.10.0）
--  用法（需要 root 权限，只需执行一次）：
--      mysql -u root -p < setup/mysql_setup.sql
--  说明：
--    1) 创建专用学习账号 learn@localhost，避免日常练习误伤 root
--    2) 创建课程库 dbs_course，内置王珊《数据库系统概论》第 3 章
--       学生-课程-选课 示例模式与教材样例数据
--    3) 创建随手练习库 scratch
--  本脚本可重复执行（内部先 DROP 再建）。
-- =============================================================

-- ---------- 1. 专用学习账号 ----------
-- 打开二进制日志时，非 SUPER 用户建触发器/函数会被拒（ERROR 1419）。
-- 本机是个人学习环境，允许普通账号建触发器，避免第 5、8 章卡住。
SET GLOBAL log_bin_trust_function_creators = 1;

CREATE USER IF NOT EXISTS 'learn'@'localhost' IDENTIFIED BY 'learn1234';
ALTER USER 'learn'@'localhost' IDENTIFIED BY 'learn1234';

CREATE DATABASE IF NOT EXISTS dbs_course
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE DATABASE IF NOT EXISTS scratch
  DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;

GRANT ALL PRIVILEGES ON dbs_course.* TO 'learn'@'localhost';
GRANT ALL PRIVILEGES ON scratch.*    TO 'learn'@'localhost';
FLUSH PRIVILEGES;

-- ---------- 2. 课程库：教材示例模式 ----------
USE dbs_course;

DROP TABLE IF EXISTS SC;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
  Sno    CHAR(9)     PRIMARY KEY,              -- 学号
  Sname  CHAR(20)    NOT NULL,                 -- 姓名
  Ssex   CHAR(2)     CHECK (Ssex IN ('男','女')),  -- 性别
  Sage   SMALLINT    CHECK (Sage BETWEEN 15 AND 45), -- 年龄
  Sdept  CHAR(20)                              -- 所在系
);

CREATE TABLE Course (
  Cno     CHAR(4)    PRIMARY KEY,              -- 课程号
  Cname   CHAR(40)   NOT NULL,                 -- 课程名
  Cpno    CHAR(4),                             -- 先修课号
  Ccredit SMALLINT,                            -- 学分
  FOREIGN KEY (Cpno) REFERENCES Course(Cno)    -- 自参照：先修课
);

CREATE TABLE SC (
  Sno   CHAR(9),
  Cno   CHAR(4),
  Grade SMALLINT CHECK (Grade BETWEEN 0 AND 100),
  PRIMARY KEY (Sno, Cno),
  FOREIGN KEY (Sno) REFERENCES Student(Sno),
  FOREIGN KEY (Cno) REFERENCES Course(Cno)
);

CREATE INDEX idx_sc_cno ON SC(Cno);

-- ---------- 3. 教材样例数据（王珊 第 5 版 表 3.x） ----------
INSERT INTO Student (Sno, Sname, Ssex, Sage, Sdept) VALUES
  ('200215121', '李勇', '男', 20, 'CS'),
  ('200215122', '刘晨', '女', 19, 'CS'),
  ('200215123', '王敏', '女', 18, 'MA'),
  ('200215125', '张立', '男', 19, 'IS');

-- 按先修关系顺序插入，避免自参照外键报错
INSERT INTO Course (Cno, Cname, Cpno, Ccredit) VALUES
  ('2', '数学',         NULL, 2),
  ('6', '数据处理',     NULL, 2),
  ('7', 'PASCAL语言',   '6',  4),
  ('5', '数据结构',     '7',  4),
  ('1', '数据库',       '5',  4),
  ('3', '信息系统',     '1',  4),
  ('4', '操作系统',     '6',  3);

INSERT INTO SC (Sno, Cno, Grade) VALUES
  ('200215121', '1', 92),
  ('200215121', '2', 85),
  ('200215121', '3', 88),
  ('200215122', '2', 90),
  ('200215122', '3', 80);

-- ---------- 4. 自检 ----------
SELECT '账号 learn@localhost 就绪' AS step, COUNT(*) AS ok
  FROM mysql.user WHERE user = 'learn';
SELECT 'dbs_course 数据量' AS step,
       (SELECT COUNT(*) FROM Student) AS students,
       (SELECT COUNT(*) FROM Course)  AS courses,
       (SELECT COUNT(*) FROM SC)      AS sc_rows;
