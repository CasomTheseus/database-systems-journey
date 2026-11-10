-- =============================================================
--  第 3 章（补充）· 视图与索引
--  运行：./scripts/db.sh < "sql/ch03-关系数据库标准语言SQL/04_视图与索引.sql"
-- =============================================================

USE dbs_course;
SET NAMES utf8mb4;

-- ------------------------------------------------------------
-- 1. 建视图：把「常用且复杂」的查询起个名字
--    视图是虚表，不存数据，查询时才展开成基表查询
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_cs_student AS
SELECT Sno, Sname, Sage
FROM Student
WHERE Sdept = 'CS';

SELECT * FROM v_cs_student;

-- ------------------------------------------------------------
-- 2. 视图上再做查询、连接、聚集——完全像表一样用
-- ------------------------------------------------------------
SELECT * FROM v_cs_student WHERE Sage > 19;

CREATE OR REPLACE VIEW v_student_score AS
SELECT S.Sno AS 学号, S.Sname AS 姓名, C.Cname AS 课程, SC.Grade AS 成绩
FROM Student S
JOIN SC     ON S.Sno = SC.Sno
JOIN Course C ON SC.Cno = C.Cno;

SELECT * FROM v_student_score ORDER BY 成绩 DESC;

-- ------------------------------------------------------------
-- 3. 视图的两种价值
--    (a) 简化查询：不用每次写三表连接
--    (b) 权限控制：只把视图授权出去，看不到基表的其他列
-- ------------------------------------------------------------
SELECT 姓名, 课程, 成绩 FROM v_student_score WHERE 成绩 >= 88;

-- ------------------------------------------------------------
-- 4. 可更新视图 vs 不可更新视图
--    规则（教材表述）：视图的行与基表的行要能一一对应
--    - 含聚集函数、GROUP BY、DISTINCT、UNION 的视图不可更新
--    - 只做投影/选择的单表视图通常可更新
-- ------------------------------------------------------------
UPDATE v_cs_student SET Sage = 21 WHERE Sno = '200215121';
SELECT * FROM Student WHERE Sno = '200215121';   -- 基表真的变了
UPDATE v_cs_student SET Sage = 20 WHERE Sno = '200215121';  -- 改回去

-- 下面这条会报错（不可更新视图）：
-- ERROR 1288 (HY000): The target table v_student_score of the UPDATE is not updatable
-- UPDATE v_student_score SET Grade = 100 WHERE Sno = '200215121';

-- ------------------------------------------------------------
-- 5. WITH CHECK OPTION：通过视图插入的数据必须满足视图条件
-- ------------------------------------------------------------
CREATE OR REPLACE VIEW v_cs_student_checked AS
SELECT Sno, Sname, Sdept FROM Student
WHERE Sdept = 'CS'
WITH CHECK OPTION;

-- 下面这条会被拒绝（插入 MA 系，不满足 Sdept='CS'）：
-- ERROR 1369 (HY000): CHECK OPTION failed 'dbs_course.v_cs_student_checked'
-- INSERT INTO v_cs_student_checked VALUES ('200215999','测试','MA');

-- ------------------------------------------------------------
-- 6. 索引：给 WHERE / JOIN / ORDER BY 用到的列建索引
--    下面的写法做了「已存在就跳过」的保护，方便反复运行本文件
-- ------------------------------------------------------------
SET @ddl := (SELECT IF(COUNT(*) = 0,
                       'CREATE INDEX idx_student_sdept ON Student(Sdept)',
                       'SELECT ''索引 idx_student_sdept 已存在'' AS msg')
             FROM information_schema.statistics
             WHERE table_schema = 'dbs_course'
               AND table_name = 'Student'
               AND index_name = 'idx_student_sdept');
PREPARE stmt FROM @ddl;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

CREATE INDEX idx_course_cname ON Course(Cname);

SHOW INDEX FROM Student;

-- ------------------------------------------------------------
-- 7. 用 EXPLAIN 看优化器到底走不走索引
--    key 列是实际用到的索引，type=ALL 表示全表扫描
-- ------------------------------------------------------------
EXPLAIN SELECT * FROM Student WHERE Sdept = 'CS';

-- 数据量太小时优化器可能仍选全表扫描——这是正常的，
-- 表只有 4 行，走索引反而更慢。要看到差别需要造大数据（第 8 周做）。

-- ------------------------------------------------------------
-- 8. 删索引、删视图
-- ------------------------------------------------------------
DROP INDEX idx_course_cname ON Course;
DROP VIEW IF EXISTS v_student_score;
DROP VIEW IF EXISTS v_cs_student_checked;

-- 保留 v_cs_student 作为常用视图，不删。
