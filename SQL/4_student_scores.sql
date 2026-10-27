-- =====================================================================
-- PRACTICE 4: STUDENT SCORES
-- Tables: students (30 rows), scores (30 rows)
-- Written for SQLite (also runs on PostgreSQL/MySQL with small date-function
-- changes, which are noted next to the relevant queries).
-- HOW TO USE: 1) run the SETUP section  2) try the PRACTICE TASKS yourself
--             3) compare with the ANSWER KEY at the bottom
-- =====================================================================
-- PRACTICE TASKS
--   1. Show each student with total and average marks (JOIN students to scores).
--   2. Add Result: 'Pass' if every subject >= 35, otherwise 'Fail'.
--   3. Add Grade: A >= 85, B >= 70, C >= 55, D >= 40, else F (CASE on average).
--   4. Rank students by total marks (RANK).
--   5. Find the class topper, and the highest scorer in Math.
--   6. Average Math score by section.
--   7. How many students scored below 40 in each subject?
--   8. Average marks per subject (one row).
--   9. Top 3 students in each section (ROW_NUMBER).
-- =====================================================================

-- ---------------------------- SETUP ----------------------------------
DROP TABLE IF EXISTS scores;
DROP TABLE IF EXISTS students;
CREATE TABLE students (
  roll_no INTEGER PRIMARY KEY,
  name    TEXT,
  section TEXT
);
CREATE TABLE scores (
  roll_no  INTEGER PRIMARY KEY REFERENCES students(roll_no),
  math     INTEGER,
  science  INTEGER,
  english  INTEGER,
  history  INTEGER,
  computer INTEGER
);
INSERT INTO students (roll_no, name, section) VALUES
  (1, 'Aarav', 'B'),
  (2, 'Vivaan', 'A'),
  (3, 'Aditya', 'B'),
  (4, 'Ishaan', 'B'),
  (5, 'Arjun', 'A'),
  (6, 'Saanvi', 'C'),
  (7, 'Ananya', 'B'),
  (8, 'Diya', 'B'),
  (9, 'Meera', 'A'),
  (10, 'Kavya', 'C'),
  (11, 'Rahul', 'C'),
  (12, 'Pooja', 'A'),
  (13, 'Suresh', 'C'),
  (14, 'Anjali', 'B'),
  (15, 'Manish', 'B'),
  (16, 'Neha', 'B'),
  (17, 'Rohan', 'C'),
  (18, 'Sneha', 'B'),
  (19, 'Karthik', 'B'),
  (20, 'Divya', 'B'),
  (21, 'Vikram', 'A'),
  (22, 'Amit', 'A'),
  (23, 'Priya', 'C'),
  (24, 'Tanvi', 'C'),
  (25, 'Yash', 'C'),
  (26, 'Riya', 'C'),
  (27, 'Kunal', 'B'),
  (28, 'Isha', 'B'),
  (29, 'Dev', 'A'),
  (30, 'Nisha', 'A');
INSERT INTO scores (roll_no, math, science, english, history, computer) VALUES
  (1, 42, 64, 58, 66, 43),
  (2, 58, 81, 86, 36, 42),
  (3, 96, 30, 93, 58, 46),
  (4, 82, 28, 73, 58, 81),
  (5, 38, 95, 74, 36, 95),
  (6, 92, 92, 98, 30, 77),
  (7, 33, 77, 75, 60, 30),
  (8, 36, 72, 58, 41, 70),
  (9, 33, 73, 97, 71, 50),
  (10, 87, 89, 51, 45, 36),
  (11, 86, 32, 65, 53, 33),
  (12, 33, 68, 67, 93, 78),
  (13, 88, 60, 32, 52, 64),
  (14, 34, 70, 62, 43, 75),
  (15, 79, 84, 77, 71, 51),
  (16, 91, 75, 94, 62, 38),
  (17, 82, 38, 83, 51, 97),
  (18, 69, 41, 38, 69, 65),
  (19, 85, 82, 49, 84, 72),
  (20, 33, 73, 83, 63, 35),
  (21, 79, 74, 93, 48, 31),
  (22, 84, 32, 44, 36, 58),
  (23, 74, 74, 77, 32, 47),
  (24, 85, 75, 75, 84, 37),
  (25, 45, 95, 74, 78, 68),
  (26, 63, 59, 42, 31, 51),
  (27, 94, 77, 99, 43, 61),
  (28, 85, 55, 64, 90, 53),
  (29, 45, 37, 85, 50, 84),
  (30, 68, 72, 36, 98, 97);
-- ====================== ANSWER KEY ============================

-- Task 1: Total and average
SELECT st.roll_no, st.name, st.section,
       (sc.math + sc.science + sc.english + sc.history + sc.computer) AS total,
       ROUND((sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0, 2) AS average
FROM students st
JOIN scores sc ON sc.roll_no = st.roll_no;


-- Task 2: Pass / Fail
SELECT st.name,
       CASE WHEN MIN(sc.math, sc.science, sc.english, sc.history, sc.computer) >= 35
            THEN 'Pass' ELSE 'Fail' END AS result
       -- MySQL/PostgreSQL: use LEAST(...) instead of MIN(a, b, c)
FROM students st
JOIN scores sc ON sc.roll_no = st.roll_no;


-- Task 3: Grade
SELECT st.name, ROUND((sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0, 1) AS average,
       CASE WHEN (sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0 >= 85 THEN 'A'
            WHEN (sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0 >= 70 THEN 'B'
            WHEN (sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0 >= 55 THEN 'C'
            WHEN (sc.math + sc.science + sc.english + sc.history + sc.computer) / 5.0 >= 40 THEN 'D'
            ELSE 'F' END AS grade
FROM students st
JOIN scores sc ON sc.roll_no = st.roll_no;


-- Task 4: Rank by total
SELECT st.name, (sc.math + sc.science + sc.english + sc.history + sc.computer) AS total,
       RANK() OVER (ORDER BY (sc.math + sc.science + sc.english + sc.history + sc.computer) DESC) AS class_rank
FROM students st
JOIN scores sc ON sc.roll_no = st.roll_no
ORDER BY class_rank;


-- Task 5: Topper and Math highest
-- Class topper
SELECT st.name, (sc.math + sc.science + sc.english + sc.history + sc.computer) AS total
FROM students st JOIN scores sc ON sc.roll_no = st.roll_no
ORDER BY total DESC
LIMIT 1;

-- Highest scorer in Math (handles ties)
SELECT st.name, sc.math
FROM students st JOIN scores sc ON sc.roll_no = st.roll_no
WHERE sc.math = (SELECT MAX(math) FROM scores);


-- Task 6: Average Math by section
SELECT st.section, ROUND(AVG(sc.math), 2) AS avg_math
FROM students st
JOIN scores sc ON sc.roll_no = st.roll_no
GROUP BY st.section;


-- Task 7: Failing counts by subject
SELECT
  SUM(CASE WHEN math     < 40 THEN 1 ELSE 0 END) AS math_below_40,
  SUM(CASE WHEN science  < 40 THEN 1 ELSE 0 END) AS science_below_40,
  SUM(CASE WHEN english  < 40 THEN 1 ELSE 0 END) AS english_below_40,
  SUM(CASE WHEN history  < 40 THEN 1 ELSE 0 END) AS history_below_40,
  SUM(CASE WHEN computer < 40 THEN 1 ELSE 0 END) AS computer_below_40
FROM scores;


-- Task 8: Subject averages
SELECT ROUND(AVG(math),1) AS math, ROUND(AVG(science),1) AS science,
       ROUND(AVG(english),1) AS english, ROUND(AVG(history),1) AS history,
       ROUND(AVG(computer),1) AS computer
FROM scores;


-- Task 9: Top 3 per section
WITH t AS (
  SELECT st.name, st.section, (sc.math + sc.science + sc.english + sc.history + sc.computer) AS total,
         ROW_NUMBER() OVER (PARTITION BY st.section ORDER BY (sc.math + sc.science + sc.english + sc.history + sc.computer) DESC) AS rn
  FROM students st JOIN scores sc ON sc.roll_no = st.roll_no
)
SELECT section, name, total, rn AS position
FROM t
WHERE rn <= 3
ORDER BY section, rn;
