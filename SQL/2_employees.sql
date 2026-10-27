-- =====================================================================
-- PRACTICE 2: EMPLOYEES & HR
-- Tables: employees (60 rows), departments (6 rows)
-- Written for SQLite (also runs on PostgreSQL/MySQL with small date-function
-- changes, which are noted next to the relevant queries).
-- HOW TO USE: 1) run the SETUP section  2) try the PRACTICE TASKS yourself
--             3) compare with the ANSWER KEY at the bottom
-- =====================================================================
-- PRACTICE TASKS
--   1. List each employee with their manager (JOIN employees to departments).
--   2. Calculate annual bonus = monthly_salary * 12 * bonus_pct for every employee.
--   3. Count employees per department and per city.
--   4. Average salary by department, highest first.
--   5. Tenure in whole years for each employee (from join_date to today).
--   6. Label each employee: 'Top Performer' (rating >= 4), 'Average' (3), else 'Needs Improvement' (CASE).
--   7. Highest and lowest salary in the IT department.
--   8. Headcount and average rating by department.
--   9. Rank employees by salary inside each department; then list those earning above their department average.
-- =====================================================================

-- ---------------------------- SETUP ----------------------------------
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;
CREATE TABLE departments (
  department TEXT PRIMARY KEY,
  manager    TEXT,
  bonus_pct  REAL
);
CREATE TABLE employees (
  emp_id         TEXT PRIMARY KEY,
  name           TEXT,
  department     TEXT,
  job_title      TEXT,
  join_date      TEXT,     -- YYYY-MM-DD
  monthly_salary INTEGER,  -- in rupees
  city           TEXT,
  rating         INTEGER   -- 1 to 5
);
INSERT INTO departments (department, manager, bonus_pct) VALUES
  ('Sales', 'R. Malhotra', 0.12),
  ('IT', 'S. Banerjee', 0.1),
  ('HR', 'A. Fernandes', 0.07),
  ('Finance', 'K. Rao', 0.09),
  ('Operations', 'T. Chawla', 0.08),
  ('Marketing', 'P. Desai', 0.11);
INSERT INTO employees (emp_id, name, department, job_title, join_date, monthly_salary, city, rating) VALUES
  ('E101', 'Diya Mehta', 'Sales', 'Sales Manager', '2019-03-19', 107500, 'Hyderabad', 4),
  ('E102', 'Manish Patel', 'Sales', 'Sales Manager', '2024-10-27', 52500, 'Mumbai', 2),
  ('E103', 'Kavya Kulkarni', 'HR', 'HR Manager', '2022-04-10', 125000, 'Chennai', 3),
  ('E104', 'Meera Kulkarni', 'Finance', 'Finance Manager', '2019-02-11', 140000, 'Mumbai', 5),
  ('E105', 'Anjali Reddy', 'Marketing', 'Brand Manager', '2023-01-24', 65000, 'Bengaluru', 3),
  ('E106', 'Ananya Mehta', 'Finance', 'Accountant', '2021-07-04', 97500, 'Delhi', 3),
  ('E107', 'Aditya Singh', 'HR', 'HR Executive', '2019-01-09', 42500, 'Mumbai', 4),
  ('E108', 'Pooja Gupta', 'Sales', 'Sales Executive', '2024-03-28', 37500, 'Chennai', 5),
  ('E109', 'Saanvi Patel', 'Operations', 'Ops Manager', '2021-12-19', 135000, 'Bengaluru', 1),
  ('E110', 'Kavya Nair', 'HR', 'HR Manager', '2019-03-01', 120000, 'Chennai', 2),
  ('E111', 'Rahul Singh', 'IT', 'Developer', '2019-03-20', 85000, 'Chennai', 3),
  ('E112', 'Suresh Nair', 'Sales', 'Sales Executive', '2022-10-24', 117500, 'Chennai', 5),
  ('E113', 'Rahul Joshi', 'Marketing', 'Marketing Executive', '2024-10-30', 135000, 'Hyderabad', 3),
  ('E114', 'Aditya Nair', 'Sales', 'Sales Manager', '2021-10-23', 85000, 'Mumbai', 2),
  ('E115', 'Kavya Mehta', 'IT', 'Developer', '2019-08-05', 147500, 'Hyderabad', 1),
  ('E116', 'Pooja Joshi', 'Sales', 'Sales Executive', '2022-03-21', 95000, 'Bengaluru', 3),
  ('E117', 'Saanvi Nair', 'IT', 'IT Manager', '2021-08-21', 120000, 'Chennai', 1),
  ('E118', 'Aditya Iyer', 'Sales', 'Sales Executive', '2025-07-23', 42500, 'Delhi', 4),
  ('E119', 'Ananya Singh', 'Marketing', 'Brand Manager', '2022-08-24', 72500, 'Pune', 5),
  ('E120', 'Saanvi Mehta', 'Sales', 'Sales Executive', '2021-03-06', 137500, 'Hyderabad', 5),
  ('E121', 'Meera Nair', 'Finance', 'Accountant', '2020-06-22', 92500, 'Chennai', 1),
  ('E122', 'Ishaan Nair', 'Sales', 'Sales Executive', '2019-07-17', 70000, 'Delhi', 3),
  ('E123', 'Aarav Singh', 'Sales', 'Sales Manager', '2019-12-21', 50000, 'Bengaluru', 5),
  ('E124', 'Ishaan Joshi', 'Marketing', 'Brand Manager', '2018-10-23', 92500, 'Hyderabad', 1),
  ('E125', 'Aarav Singh', 'Finance', 'Accountant', '2021-07-06', 120000, 'Bengaluru', 5),
  ('E126', 'Pooja Mehta', 'Finance', 'Finance Manager', '2019-04-17', 92500, 'Mumbai', 3),
  ('E127', 'Suresh Kulkarni', 'IT', 'Data Analyst', '2022-01-22', 42500, 'Bengaluru', 1),
  ('E128', 'Ananya Kulkarni', 'IT', 'Data Analyst', '2023-11-17', 42500, 'Bengaluru', 3),
  ('E129', 'Saanvi Reddy', 'Marketing', 'Brand Manager', '2019-11-20', 40000, 'Chennai', 1),
  ('E130', 'Meera Reddy', 'Operations', 'Ops Manager', '2021-12-09', 145000, 'Hyderabad', 2),
  ('E131', 'Vivaan Iyer', 'IT', 'Data Analyst', '2020-03-19', 57500, 'Chennai', 2),
  ('E132', 'Vivaan Iyer', 'Marketing', 'Brand Manager', '2023-03-16', 120000, 'Chennai', 4),
  ('E133', 'Manish Kulkarni', 'Marketing', 'Brand Manager', '2025-01-13', 80000, 'Pune', 4),
  ('E134', 'Diya Singh', 'Sales', 'Sales Manager', '2021-01-30', 122500, 'Mumbai', 3),
  ('E135', 'Vivaan Nair', 'Operations', 'Ops Manager', '2023-01-26', 35000, 'Mumbai', 3),
  ('E136', 'Vivaan Patel', 'HR', 'HR Manager', '2023-03-11', 122500, 'Chennai', 1),
  ('E137', 'Manish Kulkarni', 'Finance', 'Accountant', '2021-08-09', 125000, 'Bengaluru', 5),
  ('E138', 'Aarav Singh', 'IT', 'Developer', '2021-11-07', 142500, 'Mumbai', 5),
  ('E139', 'Aditya Sharma', 'Marketing', 'Marketing Executive', '2022-11-29', 100000, 'Chennai', 5),
  ('E140', 'Aditya Gupta', 'Operations', 'Ops Manager', '2021-03-04', 90000, 'Bengaluru', 3),
  ('E141', 'Kavya Sharma', 'Marketing', 'Brand Manager', '2018-09-27', 82500, 'Mumbai', 5),
  ('E142', 'Ananya Nair', 'Marketing', 'Brand Manager', '2025-05-13', 125000, 'Pune', 3),
  ('E143', 'Kavya Iyer', 'Sales', 'Sales Manager', '2021-06-24', 132500, 'Hyderabad', 4),
  ('E144', 'Kavya Patel', 'IT', 'Data Analyst', '2024-04-08', 90000, 'Hyderabad', 3),
  ('E145', 'Rahul Joshi', 'IT', 'Developer', '2025-03-31', 135000, 'Bengaluru', 5),
  ('E146', 'Aarav Gupta', 'HR', 'HR Manager', '2020-01-09', 62500, 'Delhi', 4),
  ('E147', 'Ishaan Iyer', 'IT', 'Developer', '2018-11-13', 75000, 'Mumbai', 5),
  ('E148', 'Anjali Joshi', 'Operations', 'Ops Executive', '2025-06-04', 82500, 'Chennai', 2),
  ('E149', 'Ananya Iyer', 'Operations', 'Ops Executive', '2020-01-11', 140000, 'Chennai', 2),
  ('E150', 'Diya Sharma', 'Marketing', 'Brand Manager', '2022-02-01', 137500, 'Hyderabad', 2);
INSERT INTO employees (emp_id, name, department, job_title, join_date, monthly_salary, city, rating) VALUES
  ('E151', 'Kavya Nair', 'Finance', 'Finance Manager', '2020-08-16', 115000, 'Pune', 3),
  ('E152', 'Manish Reddy', 'Finance', 'Finance Manager', '2025-08-10', 120000, 'Bengaluru', 4),
  ('E153', 'Suresh Mehta', 'HR', 'HR Manager', '2019-10-26', 60000, 'Chennai', 2),
  ('E154', 'Aarav Singh', 'HR', 'HR Manager', '2024-03-21', 45000, 'Hyderabad', 5),
  ('E155', 'Arjun Patel', 'Sales', 'Sales Executive', '2021-01-22', 100000, 'Chennai', 2),
  ('E156', 'Vivaan Reddy', 'Finance', 'Finance Manager', '2021-12-02', 32500, 'Bengaluru', 1),
  ('E157', 'Meera Gupta', 'Finance', 'Accountant', '2022-05-01', 42500, 'Delhi', 2),
  ('E158', 'Saanvi Patel', 'Sales', 'Sales Manager', '2019-08-22', 50000, 'Mumbai', 3),
  ('E159', 'Pooja Iyer', 'Finance', 'Finance Manager', '2023-01-12', 127500, 'Mumbai', 1),
  ('E160', 'Arjun Reddy', 'Sales', 'Sales Executive', '2024-02-26', 145000, 'Chennai', 5);
-- ====================== ANSWER KEY ============================

-- Task 1: Employee with manager
SELECT e.emp_id, e.name, e.department, d.manager
FROM employees e
JOIN departments d ON d.department = e.department;


-- Task 2: Annual bonus
SELECT e.name, e.department,
       e.monthly_salary * 12 * d.bonus_pct AS annual_bonus
FROM employees e
JOIN departments d ON d.department = e.department
ORDER BY annual_bonus DESC;


-- Task 3: Counts by department and city
SELECT department, COUNT(*) AS headcount FROM employees GROUP BY department;

SELECT city, COUNT(*) AS headcount FROM employees GROUP BY city;


-- Task 4: Average salary by department
SELECT department, ROUND(AVG(monthly_salary), 0) AS avg_salary
FROM employees
GROUP BY department
ORDER BY avg_salary DESC;


-- Task 5: Tenure in years
SELECT name, join_date,
       CAST((julianday('now') - julianday(join_date)) / 365.25 AS INTEGER) AS tenure_years
       -- MySQL: TIMESTAMPDIFF(YEAR, join_date, CURDATE())
       -- PostgreSQL: DATE_PART('year', AGE(CURRENT_DATE, join_date))
FROM employees
ORDER BY tenure_years DESC;


-- Task 6: Performance label
SELECT name, rating,
       CASE WHEN rating >= 4 THEN 'Top Performer'
            WHEN rating = 3  THEN 'Average'
            ELSE 'Needs Improvement' END AS performance
FROM employees;


-- Task 7: Max / min salary in IT
SELECT MAX(monthly_salary) AS highest, MIN(monthly_salary) AS lowest
FROM employees
WHERE department = 'IT';


-- Task 8: Headcount and avg rating
SELECT department, COUNT(*) AS headcount, ROUND(AVG(rating), 2) AS avg_rating
FROM employees
GROUP BY department;


-- Task 9: Salary rank and above-average
SELECT name, department, monthly_salary,
       DENSE_RANK() OVER (PARTITION BY department ORDER BY monthly_salary DESC) AS salary_rank
FROM employees;

-- Earning above their department average (correlated subquery)
SELECT name, department, monthly_salary
FROM employees e
WHERE monthly_salary > (SELECT AVG(monthly_salary) FROM employees WHERE department = e.department);
