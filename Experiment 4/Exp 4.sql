-- Experiment 4: Joins, subqueries, set-operation equivalents, EXPLAIN
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS DBMS_LAB;
USE DBMS_LAB;

DROP TABLE IF EXISTS Project;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;

CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    dept_id INT,
    manager_id INT,
    salary DECIMAL(10,2)
);

CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT
);

INSERT INTO Department VALUES
(1, 'IT'), (2, 'HR'), (3, 'Finance'), (4, 'Marketing');

INSERT INTO Employee VALUES
(101, 'Raj', 1, NULL, 80000),
(102, 'Aman', 1, 101, 60000),
(103, 'Priya', 2, NULL, 70000),
(104, 'Rohan', 2, 103, 50000),
(105, 'Neha', 3, NULL, 75000),
(106, 'Karan', 3, 105, 55000),
(107, 'Simran', 4, NULL, 65000),
(108, 'Arjun', 1, 101, 55000);

INSERT INTO Project VALUES
(201, 'Website Development', 1),
(202, 'Mobile Application', 1),
(203, 'Recruitment System', 2),
(204, 'Financial Analysis', 3),
(205, 'Marketing Campaign', 4);

SELECT * FROM Department;
SELECT * FROM Employee;
SELECT * FROM Project;

-- 1. INNER JOIN: employees with matching departments
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e INNER JOIN Department d ON e.dept_id = d.dept_id;

-- 2. LEFT JOIN: all employees, including those without a matching department
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e LEFT JOIN Department d ON e.dept_id = d.dept_id;

-- 3. SELF JOIN: employee and manager
SELECT e.emp_name AS Employee, m.emp_name AS Manager
FROM Employee e LEFT JOIN Employee m ON e.manager_id = m.emp_id;

-- 4. THREE-WAY JOIN: employee, department, and that department's projects
SELECT e.emp_name, d.dept_name, p.project_name
FROM Employee e
INNER JOIN Department d ON e.dept_id = d.dept_id
INNER JOIN Project p ON d.dept_id = p.dept_id;

-- 5. CORRELATED SUBQUERY: employees earning above their department average
SELECT e.emp_id, e.emp_name, e.salary
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary) FROM Employee e2 WHERE e2.dept_id = e.dept_id
);

-- 6. EXISTS: employees in a department with a project
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE EXISTS (SELECT 1 FROM Project p WHERE p.dept_id = e.dept_id);

-- 7. Simulated INTERSECT: employees whose department occurs in Project
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE EXISTS (SELECT 1 FROM Project p WHERE p.dept_id = e.dept_id);

-- 8. Simulated EXCEPT: employees whose department has no project
SELECT e.emp_id, e.emp_name
FROM Employee e
WHERE NOT EXISTS (SELECT 1 FROM Project p WHERE p.dept_id = e.dept_id);

-- 9. EXPLAIN: inspect the join execution plan
EXPLAIN
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e INNER JOIN Department d ON e.dept_id = d.dept_id;