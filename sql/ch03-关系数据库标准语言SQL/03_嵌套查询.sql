-- =============================================================
--  第 3 章（下）· 嵌套查询
--  IN / 比较 + ANY,ALL / EXISTS / NOT EXISTS 实现「全部」
--  运行：./scripts/db.sh < "sql/ch03-关系数据库标准语言SQL/03_嵌套查询.sql"
-- =============================================================

USE dbs_course;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. IN 子查询（不相关子查询：子查询可以独立执行一次）
--    选了 1 号课的学生
-- ------------------------------------------------------------
SELECT Sno FROM SC WHERE Cno = '1';          -- 先看一眼子查询结果

SELECT Sno, Sname
FROM Student
WHERE Sno IN (SELECT Sno FROM SC WHERE Cno = '1');

-- ------------------------------------------------------------
-- 2. 比较运算符 + 子查询：成绩高于平均分的选择记录
-- ------------------------------------------------------------
SELECT Sno, Cno, Grade
FROM SC
WHERE Grade > (SELECT AVG(Grade) FROM SC)
ORDER BY Grade DESC;

-- ------------------------------------------------------------
-- 3. ANY / ALL：和子查询结果集的「任意一个 / 全部」比较
--    成绩高于 1 号课任一成绩 → > ANY
-- ------------------------------------------------------------
SELECT Sno, Cno, Grade
FROM SC
WHERE Grade > ANY (SELECT Grade FROM SC WHERE Cno = '1');

-- 成绩高于 1 号课所有成绩 → > ALL（等价于 > MAX）
SELECT Sno, Cno, Grade
FROM SC
WHERE Grade > ALL (SELECT Grade FROM SC WHERE Cno = '1');

-- 注意：> ALL 遇到子查询里有 NULL 会返回空集，和 NOT IN 一样的坑

-- ------------------------------------------------------------
-- 4. EXISTS：相关子查询，子查询依赖外层的 S.Sno
--    EXISTS 只关心「有没有行」，所以 SELECT 后面写什么无所谓
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname
FROM Student S
WHERE EXISTS (SELECT 1 FROM SC WHERE SC.Sno = S.Sno AND SC.Cno = '3');

-- ------------------------------------------------------------
-- 5. NOT EXISTS：没选任何课的学生
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname
FROM Student S
WHERE NOT EXISTS (SELECT 1 FROM SC WHERE SC.Sno = S.Sno);

-- ------------------------------------------------------------
-- 6. 关系代数的「除法」：选修了全部课程的学生
--    「不存在一门课，该学生没有选」
--    这是全称量词 ∀ 的标准翻译：¬∃x ¬P(x)
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname
FROM Student S
WHERE NOT EXISTS (
        SELECT 1 FROM Course C
        WHERE NOT EXISTS (
                SELECT 1 FROM SC
                WHERE SC.Sno = S.Sno AND SC.Cno = C.Cno
        )
);

-- ------------------------------------------------------------
-- 7. 除法变体：至少选了「刘晨」所选全部课程的学生
--    刘晨 = 200215122
-- ------------------------------------------------------------
SELECT S.Sno, S.Sname
FROM Student S
WHERE S.Sno <> '200215122'
  AND NOT EXISTS (
        SELECT 1 FROM SC X
        WHERE X.Sno = '200215122'
          AND NOT EXISTS (
                SELECT 1 FROM SC Y
                WHERE Y.Sno = S.Sno AND Y.Cno = X.Cno
          )
);

-- ------------------------------------------------------------
-- 8. 子查询出现在 FROM 里 = 派生表（必须有别名）
--    每门课的平均分，再筛出平均分 > 85 的
-- ------------------------------------------------------------
SELECT 课程号, 平均分
FROM (
    SELECT Cno AS 课程号, AVG(Grade) AS 平均分
    FROM SC
    GROUP BY Cno
) AS t
WHERE 平均分 > 85;

-- ------------------------------------------------------------
-- 9. 子查询出现在 SELECT 里 = 标量子查询（只返回一行一列）
-- ------------------------------------------------------------
SELECT S.Sname,
       (SELECT COUNT(*) FROM SC WHERE SC.Sno = S.Sno) AS 选课门数
FROM Student S
ORDER BY 选课门数 DESC;

-- ------------------------------------------------------------
-- 10. 用子查询做删除：删掉「成绩低于 60」的记录
--     先 SELECT 确认，再 DELETE，务必带 WHERE
-- ------------------------------------------------------------
SELECT * FROM SC WHERE Grade < 60;   -- 目前没有，返回空集

-- DELETE FROM SC WHERE Grade < 60;   -- 确认后再放开

-- ------------------------------------------------------------
-- 11. 三层嵌套：选了「数据库」这门课的学生姓名
--     从课程名反查 → 课程号 → 学号 → 姓名
-- ------------------------------------------------------------
SELECT Sname
FROM Student
WHERE Sno IN (
    SELECT Sno FROM SC WHERE Cno IN (
        SELECT Cno FROM Course WHERE Cname = '数据库'
    )
);

-- 等价的连接写法，可读性更好，优化器通常生成相同计划
SELECT S.Sname
FROM Student S
JOIN SC ON S.Sno = SC.Sno
JOIN Course C ON SC.Cno = C.Cno
WHERE C.Cname = '数据库';
