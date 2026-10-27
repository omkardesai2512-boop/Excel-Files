-- =====================================================================
-- PRACTICE 5: MONTHLY BUDGET
-- Tables: monthly_budget (12 rows)
-- Written for SQLite (also runs on PostgreSQL/MySQL with small date-function
-- changes, which are noted next to the relevant queries).
-- HOW TO USE: 1) run the SETUP section  2) try the PRACTICE TASKS yourself
--             3) compare with the ANSWER KEY at the bottom
-- =====================================================================
-- PRACTICE TASKS
--   1. Add total_expenses = rent + food + transport + utilities + entertainment (exclude savings).
--   2. Add balance = income - total_expenses - savings.
--   3. Add savings_rate = savings / income as a percentage.
--   4. Show a TOTAL row and an AVERAGE row beneath the monthly data (UNION ALL).
--   5. Find the highest and lowest spending months.
--   6. Flag months where total expenses exceed 70% of income.
--   7. Each category's share (%) of total spending for the year.
--   8. 3-month moving average of food spending (window frame).
--   9. Running (cumulative) total of savings across the year.
-- =====================================================================

-- ---------------------------- SETUP ----------------------------------
DROP TABLE IF EXISTS monthly_budget;
CREATE TABLE monthly_budget (
  month_no      INTEGER PRIMARY KEY,
  month         TEXT,
  income        INTEGER,   -- all amounts in rupees
  rent          INTEGER,
  food          INTEGER,
  transport     INTEGER,
  utilities     INTEGER,
  entertainment INTEGER,
  savings       INTEGER
);
INSERT INTO monthly_budget (month_no, month, income, rent, food, transport, utilities, entertainment, savings) VALUES
  (1, 'Jan', 65000, 18000, 10650, 4228, 2822, 3426, 11501),
  (2, 'Feb', 65000, 18000, 9083, 3918, 2748, 3646, 11488),
  (3, 'Mar', 65000, 18000, 7969, 5023, 2553, 4956, 9538),
  (4, 'Apr', 70000, 18000, 8511, 4914, 3629, 3063, 10013),
  (5, 'May', 65000, 18000, 7269, 4266, 3315, 5921, 9306),
  (6, 'Jun', 65000, 18000, 10150, 4677, 3677, 2604, 6026),
  (7, 'Jul', 65000, 18000, 9631, 3303, 3421, 5816, 10571),
  (8, 'Aug', 70000, 18000, 8411, 3525, 3629, 6815, 6490),
  (9, 'Sep', 65000, 18000, 8772, 5059, 2613, 3017, 9244),
  (10, 'Oct', 65000, 18000, 8245, 3674, 2831, 4643, 10810),
  (11, 'Nov', 65000, 18000, 8417, 5125, 3081, 2646, 7052),
  (12, 'Dec', 65000, 18000, 9601, 5256, 3062, 3025, 10120);
-- ====================== ANSWER KEY ============================

-- Task 1: Total expenses
SELECT month, income, (rent + food + transport + utilities + entertainment) AS total_expenses
FROM monthly_budget
ORDER BY month_no;


-- Task 2: Balance
SELECT month, income - (rent + food + transport + utilities + entertainment) - savings AS balance
FROM monthly_budget
ORDER BY month_no;


-- Task 3: Savings rate
SELECT month, ROUND(savings * 100.0 / income, 1) AS savings_rate_pct
FROM monthly_budget
ORDER BY month_no;


-- Task 4: Total and average rows
SELECT month, income, (rent + food + transport + utilities + entertainment) AS total_expenses, savings, 1 AS sort_key FROM monthly_budget
UNION ALL
SELECT 'TOTAL', SUM(income), SUM(rent) + SUM(food) + SUM(transport) + SUM(utilities) + SUM(entertainment), SUM(savings), 2 FROM monthly_budget
UNION ALL
SELECT 'AVERAGE', ROUND(AVG(income),0), ROUND(AVG(rent) + AVG(food) + AVG(transport) + AVG(utilities) + AVG(entertainment),0), ROUND(AVG(savings),0), 3 FROM monthly_budget
ORDER BY sort_key;


-- Task 5: Highest and lowest spending
SELECT month, (rent + food + transport + utilities + entertainment) AS total_expenses, 'Highest' AS flag
FROM monthly_budget
WHERE (rent + food + transport + utilities + entertainment) = (SELECT MAX(rent + food + transport + utilities + entertainment) FROM monthly_budget)
UNION ALL
SELECT month, (rent + food + transport + utilities + entertainment), 'Lowest'
FROM monthly_budget
WHERE (rent + food + transport + utilities + entertainment) = (SELECT MIN(rent + food + transport + utilities + entertainment) FROM monthly_budget);


-- Task 6: Months above 70% of income
SELECT month, income, (rent + food + transport + utilities + entertainment) AS total_expenses,
       CASE WHEN (rent + food + transport + utilities + entertainment) > 0.7 * income THEN 'Over budget' ELSE 'OK' END AS status
FROM monthly_budget
ORDER BY month_no;


-- Task 7: Category share
WITH t AS (
  SELECT SUM(rent) AS rent, SUM(food) AS food, SUM(transport) AS transport,
         SUM(utilities) AS utilities, SUM(entertainment) AS entertainment
  FROM monthly_budget
),
tot AS (SELECT rent + food + transport + utilities + entertainment AS grand FROM t)
SELECT 'Rent' AS category, rent AS amount, ROUND(rent*100.0/grand,1) AS pct FROM t, tot
UNION ALL SELECT 'Food', food, ROUND(food*100.0/grand,1) FROM t, tot
UNION ALL SELECT 'Transport', transport, ROUND(transport*100.0/grand,1) FROM t, tot
UNION ALL SELECT 'Utilities', utilities, ROUND(utilities*100.0/grand,1) FROM t, tot
UNION ALL SELECT 'Entertainment', entertainment, ROUND(entertainment*100.0/grand,1) FROM t, tot;


-- Task 8: 3-month moving average (Food)
SELECT month, food,
       ROUND(AVG(food) OVER (ORDER BY month_no ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS food_3m_avg
FROM monthly_budget;


-- Task 9: Running total of savings
SELECT month, savings,
       SUM(savings) OVER (ORDER BY month_no) AS cumulative_savings
FROM monthly_budget;
