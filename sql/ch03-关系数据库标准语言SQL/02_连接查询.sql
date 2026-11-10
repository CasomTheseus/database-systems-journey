-- =============================================================
--  第 3 章（中）· 连接查询
--  等值连接 / 自然连接 / 自身连接 / 外连接 / 多表连接
--  运行：./scripts/db.sh < "sql/ch03-关系数据库标准语言SQL/02_连接查询.sql"
-- =============================================================

USE dbs_course;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. 等值连接（最常用写法，JOIN ... ON）
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname, SC.Cno, SC.Grade
FROM Student S
JOIN SC ON S.Sno = SC.Sno
ORDER BY S.Sno, SC.Cno;

-- 等价的隐式写法：FROM A, B WHERE A.x = B.y（教材里的老写法，能看懂即可）
SELECT S.Sno, S.Sname, SC.Cno
FROM Student S, SC
WHERE S.Sno = SC.Sno
ORDER BY S.Sno, SC.Cno;

-- ------------------------------------------------------------
-- 2. 自然连接：自动按同名同类型列连接，并去掉重复列
-- ------------------------------------------------------------
SELECT * FROM Student NATURAL JOIN SC;

-- ------------------------------------------------------------
-- 3. 三表连接：学生 + 选课 + 课程
-- ------------------------------------------------------------
SELECT S.Sname AS 姓名, C.Cname AS 课程, SC.Grade AS 成绩
FROM Student S
JOIN SC    ON S.Sno = SC.Sno
JOIN Course C ON SC.Cno = C.Cno
ORDER BY SC.Grade DESC;

-- ------------------------------------------------------------
-- 4. 自身连接：Course 表的先修关系（Cpno 指向本表 Cno）
--    必须给同一张表起两个别名，否则数据库分不清是哪一行
-- ------------------------------------------------------------
SELECT C1.Cname AS 课程, C1.Ccredit AS 学分,
       IFNULL(C2.Cname, '无') AS 先修课
FROM Course C1
LEFT JOIN Course C2 ON C1.Cpno = C2.Cno
ORDER BY C1.Cno;

-- ------------------------------------------------------------
-- 5. 外连接：左外 / 右外 / 全外
--    内连接会丢掉「没有匹配」的行，外连接保留它们并用 NULL 填充
-- ------------------------------------------------------------
-- 左外：所有学生都在，没选课的显示 NULL
SELECT S.Sno, S.Sname, SC.Cno, SC.Grade
FROM Student S
LEFT JOIN SC ON S.Sno = SC.Sno
ORDER BY S.Sno;

-- 右外：所有课程都在，没人选的课显示 NULL
SELECT C.Cno, C.Cname, SC.Sno
FROM SC
RIGHT JOIN Course C ON SC.Cno = C.Cno
ORDER BY C.Cno;

-- 全外：MySQL 不支持 FULL OUTER JOIN，用 UNION 模拟
SELECT S.Sno, S.Sname, SC.Cno
FROM Student S LEFT JOIN SC ON S.Sno = SC.Sno
UNION
SELECT S.Sno, S.Sname, SC.Cno
FROM Student S RIGHT JOIN SC ON S.Sno = SC.Sno;

-- ------------------------------------------------------------
-- 6. 用外连接找「没选课的学生」——比 NOT IN 更安全
--    NOT IN 遇到 NULL 会整体返回空集，这是经典坑
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname
FROM Student S
LEFT JOIN SC ON S.Sno = SC.Sno
WHERE SC.Sno IS NULL;

-- 对照：NOT EXISTS 也能做，且不受 NULL 影响
SELECT S.Sno, S.Sname
FROM Student S
WHERE NOT EXISTS (SELECT 1 FROM SC WHERE SC.Sno = S.Sno);

-- ------------------------------------------------------------
-- 7. 交叉连接：笛卡尔积，4 学生 × 7 课程 = 28 行
-- ------------------------------------------------------------
SELECT COUNT(*) AS 笛卡尔积行数 FROM Student CROSS JOIN Course;

-- ------------------------------------------------------------
-- 8. 连接 + 分组：每门课的选课人数和平均分
-- ------------------------------------------------------------
SELECT C.Cname AS 课程, COUNT(SC.Sno) AS 选课人数, ROUND(AVG(SC.Grade), 1) AS 平均分
FROM Course C
LEFT JOIN SC ON C.Cno = SC.Cno        -- 用 LEFT 才能让没人选的课也出现（人数 0）
GROUP BY C.Cno, C.Cname
ORDER BY 平均分 DESC;
