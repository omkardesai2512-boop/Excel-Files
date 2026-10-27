-- =====================================================================
-- PRACTICE 1: SALES ANALYSIS
-- Tables: sales (200 orders)
-- Written for SQLite (also runs on PostgreSQL/MySQL with small date-function
-- changes, which are noted next to the relevant queries).
-- HOW TO USE: 1) run the SETUP section  2) try the PRACTICE TASKS yourself
--             3) compare with the ANSWER KEY at the bottom
-- =====================================================================
-- PRACTICE TASKS
--   1. Show every order with a calculated revenue column = quantity * unit_price * (1 - discount_pct).
--   2. Total revenue per region (GROUP BY), highest first.
--   3. Number of orders per category.
--   4. Average revenue per order for the 'Electronics' category.
--   5. Top 5 orders by revenue.
--   6. Monthly revenue trend (group by year-month).
--   7. Pivot-style table: salesperson as rows, one column per category with revenue (CASE WHEN).
--   8. Regions that have more than 50 orders (HAVING).
--   9. Rank salespeople by revenue within each region (window function).
-- =====================================================================

-- ---------------------------- SETUP ----------------------------------
DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
  order_id     TEXT PRIMARY KEY,
  order_date   TEXT,      -- stored as YYYY-MM-DD
  region       TEXT,
  salesperson  TEXT,
  product      TEXT,
  category     TEXT,
  quantity     INTEGER,
  unit_price   INTEGER,   -- in rupees
  discount_pct REAL       -- 0.10 = 10%
);
INSERT INTO sales (order_id, order_date, region, salesperson, product, category, quantity, unit_price, discount_pct) VALUES
  ('ORD1132', '2026-01-02', 'North', 'Priya', 'Headphones', 'Electronics', 8, 3500, 0.15),
  ('ORD1169', '2026-01-05', 'West', 'Vikram', 'Desk', 'Furniture', 15, 12000, 0.05),
  ('ORD1107', '2026-01-07', 'North', 'Priya', 'Notebook Pack', 'Stationery', 14, 450, 0.1),
  ('ORD1123', '2026-01-08', 'South', 'Karthik', 'Desk', 'Furniture', 5, 12000, 0),
  ('ORD1197', '2026-01-09', 'South', 'Karthik', 'Notebook Pack', 'Stationery', 5, 450, 0),
  ('ORD1173', '2026-01-12', 'East', 'Sneha', 'Desk', 'Furniture', 5, 12000, 0),
  ('ORD1065', '2026-01-13', 'South', 'Karthik', 'Office Chair', 'Furniture', 7, 8500, 0.05),
  ('ORD1095', '2026-01-14', 'North', 'Amit', 'Pen Box', 'Stationery', 11, 220, 0.1),
  ('ORD1196', '2026-01-14', 'South', 'Karthik', 'Smartphone', 'Electronics', 1, 22000, 0.05),
  ('ORD1067', '2026-01-15', 'West', 'Neha', 'Notebook Pack', 'Stationery', 15, 450, 0.05),
  ('ORD1112', '2026-01-15', 'West', 'Vikram', 'Notebook Pack', 'Stationery', 14, 450, 0.05),
  ('ORD1133', '2026-01-17', 'West', 'Neha', 'Desk', 'Furniture', 5, 12000, 0.05),
  ('ORD1189', '2026-01-17', 'West', 'Vikram', 'Desk', 'Furniture', 4, 12000, 0.1),
  ('ORD1144', '2026-01-19', 'East', 'Sneha', 'Pen Box', 'Stationery', 2, 220, 0.05),
  ('ORD1068', '2026-01-20', 'South', 'Karthik', 'Desk', 'Furniture', 10, 12000, 0.1),
  ('ORD1007', '2026-01-23', 'East', 'Sneha', 'Desk', 'Furniture', 9, 12000, 0),
  ('ORD1070', '2026-01-23', 'South', 'Divya', 'Desk', 'Furniture', 1, 12000, 0.15),
  ('ORD1079', '2026-01-24', 'South', 'Karthik', 'Laptop', 'Electronics', 8, 55000, 0.15),
  ('ORD1018', '2026-01-25', 'West', 'Neha', 'Smartphone', 'Electronics', 3, 22000, 0),
  ('ORD1035', '2026-01-28', 'West', 'Neha', 'Printer', 'Electronics', 1, 9500, 0.1),
  ('ORD1165', '2026-01-29', 'North', 'Priya', 'Notebook Pack', 'Stationery', 6, 450, 0.05),
  ('ORD1025', '2026-01-30', 'East', 'Rohan', 'Office Chair', 'Furniture', 15, 8500, 0.15),
  ('ORD1043', '2026-01-30', 'North', 'Amit', 'Notebook Pack', 'Stationery', 10, 450, 0.1),
  ('ORD1130', '2026-01-31', 'West', 'Neha', 'Desk', 'Furniture', 13, 12000, 0),
  ('ORD1090', '2026-02-01', 'West', 'Neha', 'Pen Box', 'Stationery', 14, 220, 0.1),
  ('ORD1184', '2026-02-02', 'East', 'Sneha', 'Office Chair', 'Furniture', 15, 8500, 0.05),
  ('ORD1031', '2026-02-04', 'North', 'Amit', 'Office Chair', 'Furniture', 14, 8500, 0.05),
  ('ORD1136', '2026-02-06', 'East', 'Rohan', 'Headphones', 'Electronics', 3, 3500, 0.05),
  ('ORD1127', '2026-02-07', 'West', 'Neha', 'Printer', 'Electronics', 3, 9500, 0),
  ('ORD1167', '2026-02-10', 'South', 'Divya', 'Headphones', 'Electronics', 10, 3500, 0),
  ('ORD1046', '2026-02-11', 'South', 'Divya', 'Laptop', 'Electronics', 11, 55000, 0.15),
  ('ORD1131', '2026-02-11', 'South', 'Karthik', 'Desk', 'Furniture', 4, 12000, 0),
  ('ORD1077', '2026-02-13', 'West', 'Vikram', 'Headphones', 'Electronics', 9, 3500, 0.15),
  ('ORD1181', '2026-02-16', 'West', 'Vikram', 'Notebook Pack', 'Stationery', 1, 450, 0.05),
  ('ORD1006', '2026-02-17', 'East', 'Sneha', 'Smartphone', 'Electronics', 2, 22000, 0.05),
  ('ORD1055', '2026-02-17', 'East', 'Sneha', 'Laptop', 'Electronics', 14, 55000, 0.05),
  ('ORD1034', '2026-02-19', 'South', 'Divya', 'Smartphone', 'Electronics', 6, 22000, 0.1),
  ('ORD1186', '2026-02-19', 'West', 'Neha', 'Smartphone', 'Electronics', 15, 22000, 0.15),
  ('ORD1049', '2026-02-21', 'North', 'Amit', 'Printer', 'Electronics', 9, 9500, 0),
  ('ORD1060', '2026-02-22', 'South', 'Divya', 'Office Chair', 'Furniture', 13, 8500, 0.15),
  ('ORD1053', '2026-02-24', 'East', 'Rohan', 'Smartphone', 'Electronics', 5, 22000, 0.05),
  ('ORD1020', '2026-02-28', 'East', 'Sneha', 'Laptop', 'Electronics', 13, 55000, 0.05),
  ('ORD1135', '2026-02-28', 'South', 'Karthik', 'Pen Box', 'Stationery', 11, 220, 0),
  ('ORD1150', '2026-02-28', 'North', 'Priya', 'Office Chair', 'Furniture', 2, 8500, 0),
  ('ORD1145', '2026-03-01', 'East', 'Sneha', 'Notebook Pack', 'Stationery', 14, 450, 0.15),
  ('ORD1029', '2026-03-03', 'West', 'Neha', 'Printer', 'Electronics', 4, 9500, 0),
  ('ORD1137', '2026-03-05', 'East', 'Sneha', 'Printer', 'Electronics', 12, 9500, 0.05),
  ('ORD1124', '2026-03-06', 'North', 'Priya', 'Desk', 'Furniture', 2, 12000, 0),
  ('ORD1178', '2026-03-09', 'South', 'Divya', 'Office Chair', 'Furniture', 9, 8500, 0.15),
  ('ORD1016', '2026-03-13', 'South', 'Karthik', 'Desk', 'Furniture', 12, 12000, 0.15);
INSERT INTO sales (order_id, order_date, region, salesperson, product, category, quantity, unit_price, discount_pct) VALUES
  ('ORD1185', '2026-03-13', 'West', 'Neha', 'Smartphone', 'Electronics', 1, 22000, 0.05),
  ('ORD1195', '2026-03-16', 'North', 'Amit', 'Desk', 'Furniture', 9, 12000, 0.05),
  ('ORD1088', '2026-03-19', 'North', 'Amit', 'Headphones', 'Electronics', 7, 3500, 0),
  ('ORD1158', '2026-03-19', 'West', 'Vikram', 'Pen Box', 'Stationery', 1, 220, 0),
  ('ORD1051', '2026-03-22', 'East', 'Sneha', 'Desk', 'Furniture', 14, 12000, 0.15),
  ('ORD1063', '2026-03-23', 'South', 'Karthik', 'Desk', 'Furniture', 7, 12000, 0),
  ('ORD1143', '2026-03-24', 'East', 'Sneha', 'Smartphone', 'Electronics', 7, 22000, 0.1),
  ('ORD1164', '2026-03-27', 'North', 'Priya', 'Printer', 'Electronics', 15, 9500, 0),
  ('ORD1062', '2026-04-02', 'West', 'Vikram', 'Laptop', 'Electronics', 13, 55000, 0.1),
  ('ORD1096', '2026-04-04', 'South', 'Karthik', 'Printer', 'Electronics', 5, 9500, 0.1),
  ('ORD1042', '2026-04-08', 'West', 'Vikram', 'Headphones', 'Electronics', 4, 3500, 0),
  ('ORD1120', '2026-04-09', 'South', 'Divya', 'Smartphone', 'Electronics', 2, 22000, 0.15),
  ('ORD1122', '2026-04-10', 'East', 'Sneha', 'Smartphone', 'Electronics', 4, 22000, 0.05),
  ('ORD1028', '2026-04-13', 'West', 'Vikram', 'Office Chair', 'Furniture', 7, 8500, 0.05),
  ('ORD1064', '2026-04-13', 'West', 'Vikram', 'Office Chair', 'Furniture', 6, 8500, 0.05),
  ('ORD1100', '2026-04-13', 'North', 'Amit', 'Office Chair', 'Furniture', 10, 8500, 0),
  ('ORD1047', '2026-04-15', 'East', 'Sneha', 'Desk', 'Furniture', 4, 12000, 0.05),
  ('ORD1054', '2026-04-15', 'South', 'Divya', 'Notebook Pack', 'Stationery', 9, 450, 0.1),
  ('ORD1193', '2026-04-16', 'South', 'Karthik', 'Headphones', 'Electronics', 14, 3500, 0.15),
  ('ORD1075', '2026-04-18', 'East', 'Sneha', 'Desk', 'Furniture', 13, 12000, 0.15),
  ('ORD1113', '2026-04-19', 'South', 'Divya', 'Printer', 'Electronics', 13, 9500, 0.05),
  ('ORD1192', '2026-04-19', 'West', 'Neha', 'Smartphone', 'Electronics', 1, 22000, 0.05),
  ('ORD1121', '2026-04-21', 'South', 'Divya', 'Office Chair', 'Furniture', 5, 8500, 0.15),
  ('ORD1082', '2026-04-23', 'North', 'Amit', 'Pen Box', 'Stationery', 13, 220, 0.15),
  ('ORD1099', '2026-04-25', 'North', 'Amit', 'Notebook Pack', 'Stationery', 13, 450, 0),
  ('ORD1009', '2026-04-27', 'North', 'Priya', 'Laptop', 'Electronics', 2, 55000, 0),
  ('ORD1163', '2026-04-27', 'South', 'Karthik', 'Desk', 'Furniture', 7, 12000, 0),
  ('ORD1030', '2026-04-28', 'East', 'Rohan', 'Laptop', 'Electronics', 1, 55000, 0),
  ('ORD1168', '2026-04-29', 'West', 'Vikram', 'Headphones', 'Electronics', 11, 3500, 0.05),
  ('ORD1134', '2026-04-30', 'West', 'Vikram', 'Smartphone', 'Electronics', 13, 22000, 0.15),
  ('ORD1183', '2026-04-30', 'East', 'Sneha', 'Smartphone', 'Electronics', 1, 22000, 0.15),
  ('ORD1194', '2026-04-30', 'South', 'Divya', 'Office Chair', 'Furniture', 13, 8500, 0),
  ('ORD1045', '2026-05-01', 'North', 'Priya', 'Smartphone', 'Electronics', 2, 22000, 0.15),
  ('ORD1078', '2026-05-01', 'East', 'Sneha', 'Smartphone', 'Electronics', 4, 22000, 0),
  ('ORD1039', '2026-05-02', 'North', 'Amit', 'Smartphone', 'Electronics', 7, 22000, 0.1),
  ('ORD1061', '2026-05-02', 'West', 'Neha', 'Headphones', 'Electronics', 13, 3500, 0),
  ('ORD1172', '2026-05-02', 'West', 'Vikram', 'Smartphone', 'Electronics', 10, 22000, 0.05),
  ('ORD1086', '2026-05-03', 'East', 'Sneha', 'Printer', 'Electronics', 8, 9500, 0),
  ('ORD1033', '2026-05-05', 'South', 'Divya', 'Printer', 'Electronics', 13, 9500, 0.1),
  ('ORD1081', '2026-05-05', 'West', 'Neha', 'Pen Box', 'Stationery', 11, 220, 0),
  ('ORD1117', '2026-05-05', 'South', 'Divya', 'Pen Box', 'Stationery', 11, 220, 0.15),
  ('ORD1012', '2026-05-06', 'North', 'Amit', 'Headphones', 'Electronics', 8, 3500, 0.1),
  ('ORD1166', '2026-05-06', 'West', 'Vikram', 'Headphones', 'Electronics', 10, 3500, 0),
  ('ORD1036', '2026-05-08', 'East', 'Rohan', 'Smartphone', 'Electronics', 4, 22000, 0.15),
  ('ORD1083', '2026-05-08', 'West', 'Neha', 'Laptop', 'Electronics', 8, 55000, 0),
  ('ORD1128', '2026-05-08', 'East', 'Rohan', 'Smartphone', 'Electronics', 9, 22000, 0.1),
  ('ORD1175', '2026-05-09', 'South', 'Karthik', 'Office Chair', 'Furniture', 11, 8500, 0),
  ('ORD1098', '2026-05-10', 'East', 'Rohan', 'Pen Box', 'Stationery', 8, 220, 0),
  ('ORD1179', '2026-05-12', 'East', 'Sneha', 'Headphones', 'Electronics', 13, 3500, 0.05),
  ('ORD1041', '2026-05-16', 'North', 'Priya', 'Pen Box', 'Stationery', 5, 220, 0.1);
INSERT INTO sales (order_id, order_date, region, salesperson, product, category, quantity, unit_price, discount_pct) VALUES
  ('ORD1014', '2026-05-18', 'East', 'Rohan', 'Pen Box', 'Stationery', 4, 220, 0.15),
  ('ORD1140', '2026-05-18', 'South', 'Karthik', 'Laptop', 'Electronics', 13, 55000, 0),
  ('ORD1087', '2026-05-20', 'East', 'Sneha', 'Office Chair', 'Furniture', 6, 8500, 0.15),
  ('ORD1001', '2026-05-21', 'North', 'Amit', 'Laptop', 'Electronics', 4, 55000, 0),
  ('ORD1114', '2026-05-22', 'East', 'Rohan', 'Desk', 'Furniture', 9, 12000, 0),
  ('ORD1153', '2026-05-22', 'South', 'Divya', 'Smartphone', 'Electronics', 6, 22000, 0.15),
  ('ORD1010', '2026-05-23', 'North', 'Priya', 'Pen Box', 'Stationery', 11, 220, 0.05),
  ('ORD1032', '2026-05-23', 'North', 'Priya', 'Office Chair', 'Furniture', 4, 8500, 0.15),
  ('ORD1066', '2026-05-23', 'East', 'Sneha', 'Smartphone', 'Electronics', 11, 22000, 0.15),
  ('ORD1141', '2026-05-23', 'West', 'Neha', 'Printer', 'Electronics', 10, 9500, 0.1),
  ('ORD1154', '2026-05-25', 'East', 'Sneha', 'Laptop', 'Electronics', 14, 55000, 0.15),
  ('ORD1174', '2026-05-27', 'North', 'Amit', 'Printer', 'Electronics', 10, 9500, 0.05),
  ('ORD1008', '2026-05-31', 'West', 'Vikram', 'Smartphone', 'Electronics', 10, 22000, 0),
  ('ORD1073', '2026-06-01', 'East', 'Rohan', 'Pen Box', 'Stationery', 4, 220, 0.1),
  ('ORD1177', '2026-06-01', 'South', 'Divya', 'Smartphone', 'Electronics', 12, 22000, 0.1),
  ('ORD1048', '2026-06-03', 'West', 'Vikram', 'Headphones', 'Electronics', 6, 3500, 0),
  ('ORD1052', '2026-06-03', 'East', 'Rohan', 'Laptop', 'Electronics', 15, 55000, 0),
  ('ORD1072', '2026-06-03', 'East', 'Sneha', 'Smartphone', 'Electronics', 11, 22000, 0.1),
  ('ORD1074', '2026-06-04', 'West', 'Vikram', 'Headphones', 'Electronics', 9, 3500, 0),
  ('ORD1105', '2026-06-04', 'South', 'Karthik', 'Smartphone', 'Electronics', 13, 22000, 0.15),
  ('ORD1103', '2026-06-09', 'North', 'Amit', 'Headphones', 'Electronics', 10, 3500, 0),
  ('ORD1149', '2026-06-09', 'South', 'Karthik', 'Headphones', 'Electronics', 9, 3500, 0.1),
  ('ORD1156', '2026-06-14', 'West', 'Neha', 'Printer', 'Electronics', 12, 9500, 0),
  ('ORD1139', '2026-06-15', 'North', 'Priya', 'Pen Box', 'Stationery', 1, 220, 0),
  ('ORD1013', '2026-06-16', 'East', 'Rohan', 'Office Chair', 'Furniture', 4, 8500, 0),
  ('ORD1056', '2026-06-20', 'North', 'Amit', 'Laptop', 'Electronics', 11, 55000, 0.05),
  ('ORD1005', '2026-06-24', 'South', 'Divya', 'Pen Box', 'Stationery', 3, 220, 0),
  ('ORD1050', '2026-06-28', 'East', 'Rohan', 'Headphones', 'Electronics', 15, 3500, 0),
  ('ORD1011', '2026-07-01', 'South', 'Karthik', 'Notebook Pack', 'Stationery', 11, 450, 0.05),
  ('ORD1108', '2026-07-05', 'North', 'Priya', 'Pen Box', 'Stationery', 12, 220, 0),
  ('ORD1190', '2026-07-05', 'West', 'Neha', 'Office Chair', 'Furniture', 11, 8500, 0.05),
  ('ORD1199', '2026-07-05', 'West', 'Neha', 'Printer', 'Electronics', 8, 9500, 0.15),
  ('ORD1059', '2026-07-06', 'North', 'Amit', 'Desk', 'Furniture', 15, 12000, 0.05),
  ('ORD1102', '2026-07-08', 'West', 'Neha', 'Desk', 'Furniture', 10, 12000, 0.15),
  ('ORD1182', '2026-07-08', 'North', 'Priya', 'Printer', 'Electronics', 10, 9500, 0.1),
  ('ORD1058', '2026-07-09', 'South', 'Karthik', 'Laptop', 'Electronics', 7, 55000, 0),
  ('ORD1023', '2026-07-11', 'South', 'Karthik', 'Headphones', 'Electronics', 9, 3500, 0.15),
  ('ORD1091', '2026-07-14', 'West', 'Vikram', 'Laptop', 'Electronics', 1, 55000, 0.05),
  ('ORD1019', '2026-07-17', 'West', 'Vikram', 'Smartphone', 'Electronics', 10, 22000, 0.1),
  ('ORD1104', '2026-07-23', 'East', 'Rohan', 'Pen Box', 'Stationery', 2, 220, 0.15),
  ('ORD1161', '2026-07-23', 'East', 'Rohan', 'Notebook Pack', 'Stationery', 14, 450, 0.05),
  ('ORD1191', '2026-07-23', 'East', 'Sneha', 'Laptop', 'Electronics', 4, 55000, 0),
  ('ORD1017', '2026-07-24', 'East', 'Sneha', 'Pen Box', 'Stationery', 4, 220, 0),
  ('ORD1040', '2026-07-25', 'West', 'Neha', 'Office Chair', 'Furniture', 3, 8500, 0.1),
  ('ORD1115', '2026-07-28', 'North', 'Priya', 'Office Chair', 'Furniture', 9, 8500, 0),
  ('ORD1160', '2026-07-29', 'North', 'Amit', 'Headphones', 'Electronics', 2, 3500, 0.1),
  ('ORD1157', '2026-07-30', 'West', 'Neha', 'Office Chair', 'Furniture', 6, 8500, 0.1),
  ('ORD1146', '2026-07-31', 'North', 'Amit', 'Printer', 'Electronics', 4, 9500, 0.15),
  ('ORD1080', '2026-08-01', 'North', 'Amit', 'Printer', 'Electronics', 12, 9500, 0.1),
  ('ORD1089', '2026-08-01', 'South', 'Divya', 'Smartphone', 'Electronics', 6, 22000, 0.15);
INSERT INTO sales (order_id, order_date, region, salesperson, product, category, quantity, unit_price, discount_pct) VALUES
  ('ORD1188', '2026-08-01', 'West', 'Neha', 'Headphones', 'Electronics', 14, 3500, 0.1),
  ('ORD1092', '2026-08-03', 'East', 'Rohan', 'Pen Box', 'Stationery', 8, 220, 0),
  ('ORD1002', '2026-08-05', 'North', 'Amit', 'Smartphone', 'Electronics', 1, 22000, 0),
  ('ORD1037', '2026-08-05', 'West', 'Neha', 'Headphones', 'Electronics', 5, 3500, 0.1),
  ('ORD1057', '2026-08-07', 'South', 'Karthik', 'Printer', 'Electronics', 2, 9500, 0),
  ('ORD1071', '2026-08-09', 'South', 'Karthik', 'Notebook Pack', 'Stationery', 11, 450, 0.05),
  ('ORD1021', '2026-08-11', 'North', 'Amit', 'Desk', 'Furniture', 8, 12000, 0),
  ('ORD1069', '2026-08-12', 'East', 'Rohan', 'Notebook Pack', 'Stationery', 7, 450, 0.15),
  ('ORD1110', '2026-08-12', 'West', 'Vikram', 'Printer', 'Electronics', 6, 9500, 0),
  ('ORD1148', '2026-08-13', 'South', 'Divya', 'Desk', 'Furniture', 2, 12000, 0),
  ('ORD1159', '2026-08-14', 'East', 'Rohan', 'Smartphone', 'Electronics', 9, 22000, 0.1),
  ('ORD1176', '2026-08-14', 'North', 'Amit', 'Desk', 'Furniture', 10, 12000, 0.05),
  ('ORD1038', '2026-08-15', 'South', 'Karthik', 'Smartphone', 'Electronics', 1, 22000, 0.15),
  ('ORD1076', '2026-08-15', 'East', 'Sneha', 'Printer', 'Electronics', 11, 9500, 0),
  ('ORD1084', '2026-08-15', 'West', 'Vikram', 'Notebook Pack', 'Stationery', 14, 450, 0.15),
  ('ORD1147', '2026-08-15', 'East', 'Rohan', 'Printer', 'Electronics', 4, 9500, 0.05),
  ('ORD1170', '2026-08-15', 'South', 'Divya', 'Smartphone', 'Electronics', 10, 22000, 0.05),
  ('ORD1155', '2026-08-17', 'West', 'Vikram', 'Headphones', 'Electronics', 6, 3500, 0.05),
  ('ORD1004', '2026-08-18', 'West', 'Vikram', 'Office Chair', 'Furniture', 13, 8500, 0),
  ('ORD1116', '2026-08-18', 'West', 'Neha', 'Printer', 'Electronics', 2, 9500, 0.05),
  ('ORD1111', '2026-08-19', 'North', 'Amit', 'Desk', 'Furniture', 13, 12000, 0.1),
  ('ORD1129', '2026-08-19', 'South', 'Divya', 'Pen Box', 'Stationery', 5, 220, 0.15),
  ('ORD1097', '2026-08-21', 'East', 'Sneha', 'Office Chair', 'Furniture', 6, 8500, 0.1),
  ('ORD1119', '2026-08-21', 'East', 'Sneha', 'Notebook Pack', 'Stationery', 5, 450, 0.05),
  ('ORD1187', '2026-08-21', 'South', 'Divya', 'Pen Box', 'Stationery', 11, 220, 0.15),
  ('ORD1152', '2026-08-22', 'West', 'Neha', 'Office Chair', 'Furniture', 7, 8500, 0),
  ('ORD1171', '2026-08-22', 'West', 'Vikram', 'Desk', 'Furniture', 4, 12000, 0.1),
  ('ORD1094', '2026-08-28', 'West', 'Neha', 'Headphones', 'Electronics', 10, 3500, 0.15),
  ('ORD1180', '2026-08-28', 'East', 'Rohan', 'Smartphone', 'Electronics', 3, 22000, 0),
  ('ORD1142', '2026-08-29', 'West', 'Vikram', 'Smartphone', 'Electronics', 7, 22000, 0.05),
  ('ORD1101', '2026-08-31', 'South', 'Karthik', 'Headphones', 'Electronics', 10, 3500, 0),
  ('ORD1027', '2026-09-01', 'South', 'Karthik', 'Headphones', 'Electronics', 5, 3500, 0.15),
  ('ORD1085', '2026-09-01', 'West', 'Vikram', 'Headphones', 'Electronics', 5, 3500, 0),
  ('ORD1126', '2026-09-02', 'North', 'Amit', 'Desk', 'Furniture', 14, 12000, 0),
  ('ORD1125', '2026-09-03', 'East', 'Sneha', 'Printer', 'Electronics', 6, 9500, 0),
  ('ORD1026', '2026-09-06', 'North', 'Amit', 'Smartphone', 'Electronics', 13, 22000, 0.15),
  ('ORD1093', '2026-09-06', 'East', 'Rohan', 'Pen Box', 'Stationery', 7, 220, 0.05),
  ('ORD1162', '2026-09-07', 'West', 'Neha', 'Notebook Pack', 'Stationery', 10, 450, 0),
  ('ORD1024', '2026-09-08', 'North', 'Amit', 'Notebook Pack', 'Stationery', 2, 450, 0.05),
  ('ORD1015', '2026-09-13', 'East', 'Sneha', 'Office Chair', 'Furniture', 15, 8500, 0.1),
  ('ORD1138', '2026-09-14', 'West', 'Vikram', 'Desk', 'Furniture', 8, 12000, 0),
  ('ORD1003', '2026-09-16', 'South', 'Karthik', 'Office Chair', 'Furniture', 9, 8500, 0),
  ('ORD1022', '2026-09-17', 'East', 'Rohan', 'Headphones', 'Electronics', 14, 3500, 0.05),
  ('ORD1044', '2026-09-18', 'South', 'Karthik', 'Laptop', 'Electronics', 14, 55000, 0),
  ('ORD1151', '2026-09-18', 'West', 'Vikram', 'Desk', 'Furniture', 7, 12000, 0.1),
  ('ORD1200', '2026-09-24', 'South', 'Divya', 'Laptop', 'Electronics', 8, 55000, 0),
  ('ORD1109', '2026-09-25', 'West', 'Vikram', 'Headphones', 'Electronics', 10, 3500, 0.15),
  ('ORD1198', '2026-09-27', 'South', 'Karthik', 'Pen Box', 'Stationery', 12, 220, 0),
  ('ORD1118', '2026-09-29', 'East', 'Sneha', 'Printer', 'Electronics', 7, 9500, 0.15),
  ('ORD1106', '2026-09-30', 'North', 'Priya', 'Notebook Pack', 'Stationery', 11, 450, 0.05);
-- ====================== ANSWER KEY ============================

-- Task 1: Revenue per order
SELECT order_id, order_date, region, product, quantity * unit_price * (1 - discount_pct) AS revenue
FROM sales
ORDER BY order_date;


-- Task 2: Revenue per region
SELECT region, ROUND(SUM(quantity * unit_price * (1 - discount_pct)), 2) AS total_revenue
FROM sales
GROUP BY region
ORDER BY total_revenue DESC;


-- Task 3: Orders per category
SELECT category, COUNT(*) AS order_count
FROM sales
GROUP BY category;


-- Task 4: Average Electronics revenue
SELECT ROUND(AVG(quantity * unit_price * (1 - discount_pct)), 2) AS avg_revenue
FROM sales
WHERE category = 'Electronics';


-- Task 5: Top 5 orders
SELECT order_id, product, quantity * unit_price * (1 - discount_pct) AS revenue
FROM sales
ORDER BY revenue DESC
LIMIT 5;   -- SQL Server: SELECT TOP 5 ...


-- Task 6: Monthly revenue
SELECT strftime('%Y-%m', order_date) AS month,   -- MySQL: DATE_FORMAT(order_date,'%Y-%m')
       ROUND(SUM(quantity * unit_price * (1 - discount_pct)), 2) AS revenue
FROM sales
GROUP BY month
ORDER BY month;


-- Task 7: Pivot by category
SELECT salesperson,
       ROUND(SUM(CASE WHEN category='Electronics' THEN quantity * unit_price * (1 - discount_pct) END), 2) AS electronics,
       ROUND(SUM(CASE WHEN category='Furniture'   THEN quantity * unit_price * (1 - discount_pct) END), 2) AS furniture,
       ROUND(SUM(CASE WHEN category='Stationery'  THEN quantity * unit_price * (1 - discount_pct) END), 2) AS stationery
FROM sales
GROUP BY salesperson;


-- Task 8: Regions with > 50 orders
SELECT region, COUNT(*) AS orders
FROM sales
GROUP BY region
HAVING COUNT(*) > 50;


-- Task 9: Rank salespeople within region
WITH rev AS (
  SELECT region, salesperson, SUM(quantity * unit_price * (1 - discount_pct)) AS revenue
  FROM sales GROUP BY region, salesperson
)
SELECT region, salesperson, ROUND(revenue, 2) AS revenue,
       RANK() OVER (PARTITION BY region ORDER BY revenue DESC) AS rank_in_region
FROM rev;
