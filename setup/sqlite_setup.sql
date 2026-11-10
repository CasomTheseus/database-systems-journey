-- =============================================================
--  同一个教材示例模式的 SQLite 版本（离线/便携用）
--  用法：
--      sqlite3 dbs_course.db < setup/sqlite_setup.sql
-- =============================================================

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS SC;
DROP TABLE IF EXISTS Course;
DROP TABLE IF EXISTS Student;

CREATE TABLE Student (
  Sno    CHAR(9)  PRIMARY KEY,
  Sname  CHAR(20) NOT NULL,
  Ssex   CHAR(2)  CHECK (Ssex IN ('男','女')),
  Sage   SMALLINT CHECK (Sage BETWEEN 15 AND 45),
  Sdept  CHAR(20)
);

CREATE TABLE Course (
  Cno     CHAR(4)  PRIMARY KEY,
  Cname   CHAR(40) NOT NULL,
  Cpno    CHAR(4)  REFERENCES Course(Cno),
  Ccredit SMALLINT
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

INSERT INTO Student (Sno, Sname, Ssex, Sage, Sdept) VALUES
  ('200215121', '李勇', '男', 20, 'CS'),
  ('200215122', '刘晨', '女', 19, 'CS'),
  ('200215123', '王敏', '女', 18, 'MA'),
  ('200215125', '张立', '男', 19, 'IS');

INSERT INTO Course (Cno, Cname, Cpno, Ccredit) VALUES
  ('2', '数学',       NULL, 2),
  ('6', '数据处理',   NULL, 2),
  ('7', 'PASCAL语言', '6',  4),
  ('5', '数据结构',   '7',  4),
  ('1', '数据库',     '5',  4),
  ('3', '信息系统',   '1',  4),
  ('4', '操作系统',   '6',  3);

INSERT INTO SC (Sno, Cno, Grade) VALUES
  ('200215121', '1', 92),
  ('200215121', '2', 85),
  ('200215121', '3', 88),
  ('200215122', '2', 90),
  ('200215122', '3', 80);

SELECT 'SQLite 初始化完成' AS step,
       (SELECT COUNT(*) FROM Student) AS students,
       (SELECT COUNT(*) FROM Course)  AS courses,
       (SELECT COUNT(*) FROM SC)      AS sc_rows;
