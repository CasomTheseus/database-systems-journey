-- =============================================================
--  第 3 章（上）· 单表查询
--  WHERE / ORDER BY / LIKE / BETWEEN / 聚集函数 / GROUP BY / HAVING
--  运行：./scripts/db.sh < "sql/ch03-关系数据库标准语言SQL/01_单表查询.sql"
-- =============================================================

USE dbs_course;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 0. 先把三张表看清楚：有几个列、什么类型、有没有约束
-- ------------------------------------------------------------
SHOW COLUMNS FROM Student;

-- ------------------------------------------------------------
-- 1. 最简单的查询：SELECT 子句里可以写表达式和别名
-- ------------------------------------------------------------
SELECT Sname AS 姓名, Sdept AS 系, 2026 - Sage AS 出生年
FROM Student;

-- ------------------------------------------------------------
-- 2. WHERE 的六种常用条件
-- ------------------------------------------------------------
SELECT * FROM Student WHERE Sage BETWEEN 18 AND 19;   -- 区间
SELECT * FROM Student WHERE Sdept IN ('CS', 'MA');    -- 枚举
SELECT * FROM Student WHERE Sname LIKE '张%';          -- 前缀匹配
SELECT * FROM Student WHERE Sname LIKE '_晨';          -- 单字符通配
SELECT * FROM Student WHERE Sage IS NOT NULL;          -- 空值判断
SELECT * FROM Student WHERE Sdept = 'CS' AND Sage > 19; -- 逻辑组合

-- 注意：LIKE 里 % 匹配任意个字符，_ 匹配恰好一个字符；
-- 要匹配真正的 % 或 _ 本身，得用 ESCAPE：
SELECT '100%' LIKE '100\%' ESCAPE '\\' AS 含百分号的字面匹配;

-- ------------------------------------------------------------
-- 3. ORDER BY：默认 ASC，NULL 在 MySQL 里排最前
-- ------------------------------------------------------------
SELECT Sno, Sname, Sage FROM Student ORDER BY Sage DESC, Sno ASC;

-- ------------------------------------------------------------
-- 4. LIMIT：分页取数（第 2 页，每页 2 条）
-- ------------------------------------------------------------
SELECT Sno, Sname FROM Student ORDER BY Sno LIMIT 2 OFFSET 2;

-- ------------------------------------------------------------
-- 5. 聚集函数：COUNT / SUM / AVG / MAX / MIN
--    COUNT(*) 数行，COUNT(列) 跳过 NULL
-- ------------------------------------------------------------
SELECT COUNT(*) AS 学生总数,
       ROUND(AVG(Sage), 2) AS 平均年龄,
       MAX(Sage) AS 最大年龄,
       MIN(Sage) AS 最小年龄
FROM Student;

-- ------------------------------------------------------------
-- 6. GROUP BY：每个系多少人、平均年龄
--    规则：SELECT 里只能出现「分组列」和「聚集函数」
-- ------------------------------------------------------------
SELECT Sdept AS 系, COUNT(*) AS 人数, ROUND(AVG(Sage), 1) AS 平均年龄
FROM Student
GROUP BY Sdept;

-- ------------------------------------------------------------
-- 7. HAVING：分组之后过滤「组」
--    执行顺序 FROM → WHERE → GROUP BY → HAVING → SELECT → ORDER BY
-- ------------------------------------------------------------
SELECT Sdept AS 系, COUNT(*) AS 人数
FROM Student
WHERE Sage >= 18          -- 先过滤「行」
GROUP BY Sdept
HAVING COUNT(*) >= 2      -- 再过滤「组」
ORDER BY 人数 DESC;

-- ------------------------------------------------------------
-- 8. WHERE 里不能写聚集函数，这是初学者最常见的报错
--    ERROR 1111 (HY000): Invalid use of group function
-- ------------------------------------------------------------
-- SELECT Sdept, COUNT(*) FROM Student WHERE COUNT(*) > 1 GROUP BY Sdept;

-- ------------------------------------------------------------
-- 9. 查询结果本身可以再当一张表用（派生表 / 子查询再 FROM 一次）
-- ------------------------------------------------------------
SELECT 系, 人数
FROM (SELECT Sdept AS 系, COUNT(*) AS 人数 FROM Student GROUP BY Sdept) AS t
WHERE 人数 > 1;

-- ------------------------------------------------------------
-- 10. 算选课成绩：空值参与运算的结果仍是 NULL
-- ------------------------------------------------------------
SELECT Sno, Cno, Grade, Grade + 5 AS 加分后
FROM SC
ORDER BY Grade DESC;

-- ------------------------------------------------------------
-- 11. 去重查询：CS 系都有哪些年龄
-- ------------------------------------------------------------
SELECT DISTINCT Sage FROM Student WHERE Sdept = 'CS' ORDER BY Sage;
