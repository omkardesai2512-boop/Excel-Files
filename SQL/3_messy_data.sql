-- =====================================================================
-- PRACTICE 3: DATA CLEANING
-- Tables: raw_customers (18 intentionally dirty rows)
-- Written for SQLite (also runs on PostgreSQL/MySQL with small date-function
-- changes, which are noted next to the relevant queries).
-- HOW TO USE: 1) run the SETUP section  2) try the PRACTICE TASKS yourself
--             3) compare with the ANSWER KEY at the bottom
-- =====================================================================
-- PRACTICE TASKS
--   1. Find the duplicate rows (GROUP BY all columns + HAVING COUNT(*) > 1).
--   2. Create a de-duplicated view called customers_dedup (use it for the remaining tasks).
--   3. Clean the city column: trim spaces and convert to proper case ('MUMBAI ' -> 'Mumbai').
--   4. Clean the name column: trim, collapse double spaces, turn empty names into NULL.
--   5. Flag invalid emails (blank, or no '.' after the '@').
--   6. Convert order_value_text to a real number (strip the rupee sign and commas; 'N/A' and blanks become NULL).
--   7. Standardise the 4 date formats into one real date (YYYY-MM-DD).
--   8. Count missing values per column (empty strings, NULLs and 'N/A').
--   9. Replace missing order values with the average order value (COALESCE).
-- NOTE: this data is dirty on purpose: spaces, mixed case, duplicates, blanks, 'N/A'.
-- =====================================================================

-- ---------------------------- SETUP ----------------------------------
DROP VIEW IF EXISTS customers_dedup;
DROP TABLE IF EXISTS raw_customers;
CREATE TABLE raw_customers (      -- intentionally NO primary key, so duplicates are allowed
  customer_id      TEXT,
  name             TEXT,
  city             TEXT,
  email            TEXT,
  order_date_text  TEXT,         -- mixed formats on purpose
  order_value_text TEXT          -- text with rupee signs, commas, 'N/A'
);
INSERT INTO raw_customers (customer_id, name, city, email, order_date_text, order_value_text) VALUES
  ('C001', '  rahul sharma ', 'MUMBAI', 'rahul.sharma@mail.com', '15/03/2026', '₹12,500'),
  ('C002', 'PRIYA PATEL', 'pune', 'priya.patel@mail', '2026-03-18', '₹8,200'),
  ('C003', 'Amit Verma ', 'Delhi', 'amit.verma@mail.com', 'March 20, 2026', '15000'),
  ('C004', 'sneha iyer', '  Chennai', 'sneha.iyer@mail.com', '22-03-2026', '₹9,750'),
  ('C002', 'PRIYA PATEL', 'pune', 'priya.patel@mail', '2026-03-18', '₹8,200'),
  ('C005', 'Karthik  Nair', 'bengaluru', '', '25/03/2026', '₹11,000'),
  ('C006', 'DIVYA REDDY', 'Hyderabad', 'divya.reddy@mail.com', '27/03/2026', ''),
  ('C007', 'rohan mehta', 'MUMBAI ', 'rohan.mehta@mail.com', '2026-03-29', '₹7,300'),
  ('C008', '', 'Pune', 'neha.k@mail.com', '30/03/2026', '₹6,400'),
  ('C009', 'Vikram Singh', 'delhi', 'vikram.singh@mail.com', '01/04/2026', 'N/A'),
  ('C010', 'anjali joshi', 'Mumbai', 'anjali.joshi@mail.com', 'April 3, 2026', '₹14,200'),
  ('C003', 'Amit Verma ', 'Delhi', 'amit.verma@mail.com', 'March 20, 2026', '15000'),
  ('C011', 'MANISH GUPTA', 'CHENNAI', 'manish.gupta@mail.com', '05-04-2026', '₹10,500'),
  ('C012', 'pooja kulkarni', 'Pune ', 'pooja.k@mail.com', '06/04/2026', '₹5,900'),
  ('C013', 'Suresh  Rao', 'Hyderabad', 'suresh.rao@mail.com', '2026-04-08', '₹13,300'),
  ('C014', 'kavya menon', 'bengaluru', 'kavya.menon@mail.com', '09/04/2026', '₹8,800'),
  ('C015', 'Arjun Das', 'KOLKATA', 'arjun.das@mail.com', '11/04/2026', ''),
  ('C016', 'meera joshi', 'mumbai', 'meera.joshi@', '12/04/2026', '₹7,700');
-- ====================== ANSWER KEY ============================

-- Task 1: Find duplicates
SELECT customer_id, name, city, email, order_date_text, order_value_text, COUNT(*) AS times
FROM raw_customers
GROUP BY customer_id, name, city, email, order_date_text, order_value_text
HAVING COUNT(*) > 1;


-- Task 2: De-duplicated view
DROP VIEW IF EXISTS customers_dedup;
CREATE VIEW customers_dedup AS
SELECT DISTINCT * FROM raw_customers;

SELECT COUNT(*) AS rows_after_dedup FROM customers_dedup;


-- Task 3: Clean city (proper case)
SELECT city AS original,
       UPPER(SUBSTR(TRIM(city), 1, 1)) || LOWER(SUBSTR(TRIM(city), 2)) AS city_clean
       -- PostgreSQL has INITCAP(TRIM(city)) built in
FROM customers_dedup;


-- Task 4: Clean name
SELECT name AS original,
       NULLIF(TRIM(REPLACE(name, '  ', ' ')), '') AS name_clean
FROM customers_dedup;


-- Task 5: Invalid emails
SELECT customer_id, email,
       CASE WHEN email = '' OR email IS NULL THEN 'Missing'
            WHEN email NOT LIKE '%@%.%'      THEN 'Invalid'
            ELSE 'OK' END AS email_status
FROM customers_dedup;


-- Task 6: Order value to number
SELECT customer_id, order_value_text,
       CAST(NULLIF(NULLIF(REPLACE(REPLACE(order_value_text, '₹', ''), ',', ''), 'N/A'), '') AS REAL) AS order_value
FROM customers_dedup;


-- Task 7: Standardise dates
SELECT customer_id, order_date_text,
       CASE
         WHEN order_date_text LIKE '__/__/____'   -- dd/mm/yyyy
           THEN SUBSTR(order_date_text,7,4)||'-'||SUBSTR(order_date_text,4,2)||'-'||SUBSTR(order_date_text,1,2)
         WHEN order_date_text LIKE '__-__-____'   -- dd-mm-yyyy
           THEN SUBSTR(order_date_text,7,4)||'-'||SUBSTR(order_date_text,4,2)||'-'||SUBSTR(order_date_text,1,2)
         WHEN order_date_text LIKE '____-__-__'   -- already ISO
           THEN order_date_text
         ELSE                                      -- 'March 20, 2026'
           SUBSTR(order_date_text, -4) || '-' ||
           PRINTF('%02d', (INSTR('JanFebMarAprMayJunJulAugSepOctNovDec', SUBSTR(order_date_text,1,3)) + 2) / 3) || '-' ||
           PRINTF('%02d', CAST(SUBSTR(order_date_text, INSTR(order_date_text,' ')+1,
                                      INSTR(order_date_text,',') - INSTR(order_date_text,' ') - 1) AS INTEGER))
       END AS order_date
FROM customers_dedup;


-- Task 8: Missing values per column
SELECT
  SUM(CASE WHEN name = '' OR name IS NULL THEN 1 ELSE 0 END)   AS missing_name,
  SUM(CASE WHEN email = '' OR email IS NULL THEN 1 ELSE 0 END) AS missing_email,
  SUM(CASE WHEN order_value_text IN ('', 'N/A') OR order_value_text IS NULL THEN 1 ELSE 0 END) AS missing_value
FROM customers_dedup;


-- Task 9: Fill missing with average
WITH v AS (
  SELECT customer_id, CAST(NULLIF(NULLIF(REPLACE(REPLACE(order_value_text, '₹', ''), ',', ''), 'N/A'), '') AS REAL) AS order_value
  FROM customers_dedup
)
SELECT customer_id,
       COALESCE(order_value, (SELECT AVG(order_value) FROM v)) AS order_value_filled
FROM v;
