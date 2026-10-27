-- E-Commerce MySQL Project 


CREATE DATABASE ecommerce_db;
use ecommerce_db;
drop database ecommerce_db

-- 1. customers
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    name        VARCHAR(100) NOT NULL,
    email       VARCHAR(100) NOT NULL UNIQUE,
    city        VARCHAR(50),
    signup_date DATE NOT NULL
) ENGINE=InnoDB;

-- 2. categories
CREATE TABLE categories (
    category_id   INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description   VARCHAR(200),
    created_date  DATE NOT NULL,
    is_active     TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB;

-- 3. products
CREATE TABLE products (
    product_id   INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id  INT NOT NULL,
    price        DECIMAL(10,2) NOT NULL CHECK (price > 0),
    stock        INT NOT NULL DEFAULT 0,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB;

-- 4. orders
CREATE TABLE orders (
    order_id     INT PRIMARY KEY AUTO_INCREMENT,
    customer_id  INT NOT NULL,
    order_date   DATE NOT NULL,
    status       ENUM('Pending','Shipped','Delivered','Cancelled') NOT NULL,
    total_amount DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
) ENGINE=InnoDB;

-- 5. order_items
CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id      INT NOT NULL,
    product_id    INT NOT NULL,
    quantity      INT NOT NULL CHECK (quantity > 0),
    unit_price    DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
) ENGINE=InnoDB;

-- 6. payments
CREATE TABLE payments (
    payment_id     INT PRIMARY KEY AUTO_INCREMENT,
    order_id       INT NOT NULL,
    payment_date   DATE NOT NULL,
    payment_method ENUM('UPI','Credit Card','Net Banking','COD') NOT NULL,
    amount         DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
) ENGINE=InnoDB;


-- ---------------------- DATA ----------------------


INSERT INTO customers (customer_id, name, email, city, signup_date) VALUES
(1,  'Aarav Mehta',  'aarav@example.com',  'Mumbai',    '2025-01-12'),
(2,  'Priya Nair',   'priya@example.com',  'Pune',      '2025-02-03'),
(3,  'Rohan Shah',   'rohan@example.com',  'Delhi',     '2025-02-20'),
(4,  'Sneha Iyer',   'sneha@example.com',  'Bengaluru', '2025-03-15'),
(5,  'Karan Verma',  'karan@example.com',  'Mumbai',    '2025-04-01'),
(6,  'Ananya Rao',   'ananya@example.com', 'Hyderabad', '2025-05-18'),
(7,  'Vikram Singh', 'vikram@example.com', 'Delhi',     '2025-06-09'),
(8,  'Meera Joshi',  'meera@example.com',  'Pune',      '2025-07-22'),
(9,  'Arjun Kapoor', 'arjun@example.com',  'Chennai',   '2025-08-30'),
(10, 'Isha Gupta',   'isha@example.com',   'Mumbai',    '2025-09-14');

INSERT INTO categories (category_id, category_name, description, created_date, is_active) VALUES
(1, 'Electronics', 'Gadgets and computer accessories', '2025-01-01', 1),
(2, 'Stationery',  'Notebooks, pens and office items', '2025-01-01', 1),
(3, 'Home',        'Home and desk essentials',         '2025-01-01', 1),
(4, 'Accessories', 'Bags and phone accessories',       '2025-01-01', 1),
(5, 'Fitness',     'Bottles and workout gear',         '2025-01-01', 1);

INSERT INTO products (product_id, product_name, category_id, price, stock) VALUES
(1,  'Wireless Mouse',      1, 799.00,  120),
(2,  'Mechanical Keyboard', 1, 3499.00, 60),
(3,  'USB-C Hub',           1, 1499.00, 80),
(4,  'Notebook (A5)',       2, 120.00,  500),
(5,  'Gel Pen Pack',        2, 150.00,  400),
(6,  'Desk Lamp',           3, 1299.00, 45),
(7,  'Water Bottle',        5, 499.00,  200),
(8,  'Backpack',            4, 1999.00, 70),
(9,  'Phone Stand',         4, 399.00,  150),
(10, 'Bluetooth Speaker',   1, 2799.00, 35);

INSERT INTO orders (order_id, customer_id, order_date, status, total_amount) VALUES
(101, 1,  '2025-10-01', 'Delivered', 1958.00),
(102, 2,  '2025-10-03', 'Delivered', 3499.00),
(103, 3,  '2025-10-05', 'Cancelled', 1999.00),
(104, 1,  '2025-10-09', 'Delivered', 2297.00),
(105, 4,  '2025-10-12', 'Shipped',   1299.00),
(106, 5,  '2025-10-15', 'Delivered', 3797.00),
(107, 6,  '2025-10-18', 'Delivered', 1230.00),
(108, 7,  '2025-10-21', 'Pending',   3499.00),
(109, 2,  '2025-10-25', 'Delivered', 2798.00),
(110, 8,  '2025-10-28', 'Shipped',   1497.00),
(111, 9,  '2025-11-02', 'Delivered', 5797.00),
(112, 10, '2025-11-05', 'Delivered', 1596.00),
(113, 5,  '2025-11-08', 'Cancelled', 2598.00),
(114, 3,  '2025-11-11', 'Delivered', 3799.00),
(115, 6,  '2025-11-14', 'Pending',   1999.00);

INSERT INTO order_items (order_item_id, order_id, product_id, quantity, unit_price) VALUES
(1,  101, 1,  2, 799.00),
(2,  101, 4,  3, 120.00),
(3,  102, 2,  1, 3499.00),
(4,  103, 8,  1, 1999.00),
(5,  104, 3,  1, 1499.00),
(6,  104, 9,  2, 399.00),
(7,  105, 6,  1, 1299.00),
(8,  106, 10, 1, 2799.00),
(9,  106, 7,  2, 499.00),
(10, 107, 5,  5, 150.00),
(11, 107, 4,  4, 120.00),
(12, 108, 2,  1, 3499.00),
(13, 109, 1,  1, 799.00),
(14, 109, 8,  1, 1999.00),
(15, 110, 7,  3, 499.00),
(16, 111, 10, 1, 2799.00),
(17, 111, 3,  2, 1499.00),
(18, 112, 9,  4, 399.00),
(19, 113, 6,  2, 1299.00),
(20, 114, 2,  1, 3499.00),
(21, 114, 5,  2, 150.00),
(22, 115, 8,  1, 1999.00);

-- Payments exist only for Delivered and Shipped orders
INSERT INTO payments (payment_id, order_id, payment_date, payment_method, amount) VALUES
(1,  101, '2025-10-01', 'UPI',         1958.00),
(2,  102, '2025-10-03', 'Credit Card', 3499.00),
(3,  104, '2025-10-09', 'UPI',         2297.00),
(4,  105, '2025-10-12', 'Net Banking', 1299.00),
(5,  106, '2025-10-16', 'Credit Card', 3797.00),
(6,  107, '2025-10-18', 'COD',         1230.00),
(7,  109, '2025-10-25', 'UPI',         2798.00),
(8,  110, '2025-10-28', 'Net Banking', 1497.00),
(9,  111, '2025-11-02', 'Credit Card', 5797.00),
(10, 112, '2025-11-05', 'UPI',         1596.00),
(11, 114, '2025-11-11', 'COD',         3799.00);
