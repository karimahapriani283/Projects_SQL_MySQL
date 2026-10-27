-- Create Database
CREATE DATABASE IF NOT EXISTS hr_analytics;
USE hr_analytics;

-- untuk melihat tabel yang ada di schema hr_analytics
SHOW TABLES FROM hr_analytics;

-- untuk melihat struktur tabel dari performance_reviews ada 2 syntax
-- syntax 1
DESCRIBE performance_reviews;
-- syntax 2
SHOW COLUMNS FROM performance_reviews;


-- untuk melihat keterangan warnings dari MySQL
SHOW WARNINGS;

-- NOTED! TIDAK UNTUK DILAKUKAN SEMBARANGAN
-- untuk menghapus tabel performance_reviews dan salary_history secara permanen dan tidak bisa di ROLLBACK (dikembalikan)
DROP TABLE performance_reviews;
DROP TABLE salary_history;

-- Drop tables if they already exist
DROP TABLE IF EXISTS salary_history;
DROP TABLE IF EXISTS performance_reviews;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

-- 1. Departments Table
CREATE TABLE departments (
    department_id INT PRIMARY KEY AUTO_INCREMENT,
    department_name VARCHAR(100) NOT NULL,
    location VARCHAR(100) NOT NULL,
    annual_budget DECIMAL(12,2) NOT NULL
);

-- 2. Employees Table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    hire_date DATE NOT NULL,
    job_title VARCHAR(100) NOT NULL,
    department_id INT,
    manager_id INT,
    employment_status ENUM('Active', 'Terminated', 'On Leave') DEFAULT 'Active',
    termination_date DATE NULL,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

-- 3. Performance Reviews Table
CREATE TABLE performance_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    review_year INT NOT NULL,
    performance_rating INT CHECK (performance_rating BETWEEN 1 AND 5),
    review_comments TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- 4. Salary History Table
CREATE TABLE salary_history (
    salary_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT NOT NULL,
    effective_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id)
);

-- Insert Sample Data into Departments
INSERT INTO departments (department_id, department_name, location, annual_budget) VALUES
(101, 'Human Resources', 'New York', 500000.00),
(102, 'Engineering', 'San Francisco', 2500000.00),
(103, 'Data & Analytics', 'San Francisco', 1200000.00),
(104, 'Sales', 'Chicago', 1800000.00),
(105, 'Marketing', 'New York', 800000.00);

-- Insert Sample Data into Employees
INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_title, 
		department_id, manager_id, employment_status, termination_date)
VALUES
(1, 'Alice', 'Smith', 'alice.smith@company.com', '2018-03-15', 'VP of Engineering', 102, NULL, 'Active', NULL),
(2, 'Bob', 'Jones', 'bob.jones@company.com', '2019-06-01', 'Engineering Manager', 102, 1, 'Active', NULL),
(3, 'Charlie', 'Brown', 'charlie.brown@company.com', '2020-01-10', 'Senior Software Engineer', 102, 2, 'Active', NULL),
(4, 'Diana', 'Prince', 'diana.prince@company.com', '2021-04-12', 'Software Engineer', 102, 2, 'Active', NULL),
(5, 'Evan', 'Wright', 'evan.wright@company.com', '2019-11-01', 'HR Director', 101, NULL, 'Active', NULL),
(6, 'Fiona', 'Gallegher', 'fiona.g@company.com', '2021-08-20', 'HR Generalist', 101, 5, 'Terminated', '2023-09-15'),
(7, 'George', 'Clark', 'george.clark@company.com', '2020-05-04', 'Lead Data Analyst', 103, NULL, 'Active', NULL),
(8, 'Hannah', 'Abbott', 'hannah.a@company.com', '2022-02-14', 'Data Analyst', 103, 7, 'Active', NULL),
(9, 'Ian', 'Malcolm', 'ian.m@company.com', '2021-10-01', 'Sales Manager', 104, NULL, 'Active', NULL),
(10, 'Julia', 'Roberts', 'julia.r@company.com', '2022-06-01', 'Sales Representative', 104, 9, 'Terminated', '2024-01-10'),
(11, 'Kevin', 'Bacon', 'kevin.b@company.com', '2023-01-15', 'Sales Representative', 104, 9, 'Active', NULL),
(12, 'Laura', 'Croft', 'laura.c@company.com', '2020-09-01', 'Marketing Director', 105, NULL, 'Active', NULL);

-- Insert Sample Data into Performance Reviews
INSERT INTO performance_reviews (employee_id, review_year, performance_rating, review_comments) 
VALUES
(1, 2023, 5, 'Exceeds Expectations'),
(2, 2023, 4, 'Meets Expectations'),
(3, 2023, 5, 'Outstanding contributions'),
(4, 2023, 3, 'Meets Expectations'),
(5, 2023, 4, 'Solid leadership'),
(6, 2023, 2, 'Needs Improvement'),
(7, 2023, 5, 'Exceptional analytical work'),
(8, 2023, 4, 'Strong performance'),
(9, 2023, 3, 'Average sales targets met'),
(10, 2023, 2, 'Underperformed'),
(11, 2023, 4, 'Great potential'),
(12, 2023, 4, 'Strong campaign results'),
-- 2024
(1, 2024, 5, 'Consistent top performer'),
(2, 2024, 4, 'Strong team delivery'),
(3, 2024, 4, 'Great technical leadership'),
(4, 2024, 4, 'Improved significantly'),
(5, 2024, 4, 'Consistent'),
(7, 2024, 5, 'Outstanding leadership'),
(8, 2024, 5, 'Promoted-level work'),
(9, 2024, 3, 'Met minimum quotas'),
(11, 2024, 4, 'Solid sales growth'),
(12, 2024, 3, 'Met targets');


-- Insert Sample Data into Salary History
INSERT INTO salary_history (employee_id, effective_date, salary) 
VALUES
(1, '2018-03-15', 160000.00), (1, '2021-01-01', 185000.00), (1, '2023-01-01', 210000.00),
(2, '2019-06-01', 120000.00), (2, '2022-01-01', 135000.00), (2, '2024-01-01', 145000.00),
(3, '2020-01-10', 100000.00), (3, '2022-01-01', 115000.00), (3, '2024-01-01', 130000.00),
(4, '2021-04-12', 85000.00),  (4, '2023-01-01', 92000.00),  (4, '2024-01-01', 98000.00),
(5, '2019-11-01', 130000.00), (5, '2022-01-01', 142000.00), (5, '2024-01-01', 150000.00),
(6, '2021-08-20', 65000.00),  (6, '2023-01-01', 68000.00),
(7, '2020-05-04', 110000.00), (7, '2022-01-01', 125000.00), (7, '2024-01-01', 140000.00),
(8, '2022-02-14', 75000.00),  (8, '2023-01-01', 82000.00),  (8, '2024-01-01', 92000.00),
(9, '2021-10-01', 95000.00),  (9, '2023-01-01', 102000.00), (9, '2024-01-01', 108000.00),
(10, '2022-06-01', 60000.00), (10, '2023-01-01', 62000.00),
(11, '2023-01-15', 62000.00), (11, '2024-01-01', 67000.00),
(12, '2020-09-01', 115000.00), (12, '2022-01-01', 125000.00), (12, '2024-01-01', 132000.00);