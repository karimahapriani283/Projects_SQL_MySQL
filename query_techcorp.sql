SHOW DATABASES;
CREATE DATABASE techcorp;
USE techcorp;
SHOW TABLES FROM techcorp;

CREATE TABLE Products (
	product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(10,2),
    stock_quantity INT
);
SELECT * FROM Products;

CREATE TABLE Customers (
	customer_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL UNIQUE,
    address VARCHAR(200) NOT NULL
);
SELECT * FROM Customers;

CREATE TABLE Orders (
	order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10,2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
SELECT * FROM Orders;

CREATE TABLE OrderDetails (
	order_detail_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10,2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);
SELECT * FROM OrderDetails;

CREATE TABLE Employees (
	employee_id INT AUTO_INCREMENT PRIMARY KEY,
	first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone VARCHAR(50) NOT NULL UNIQUE,
    hire_date DATE NOT NULL,
    department VARCHAR(50) NOT NULL
);

CREATE TABLE SupportTickets (
	ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    issue TEXT,
    status VARCHAR(50),
    created_at DATETIME,
    resolved_at DATETIME,
    FOREIGN KEY (Customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES Employees(employee_id)
);
SELECT * FROM Products;

ALTER TABLE Products ADD COLUMN discount DECIMAL(5,2) DEFAULT 0;
