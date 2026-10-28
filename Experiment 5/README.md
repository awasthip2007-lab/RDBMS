# Experiment 5 — SQL Views and Recursive Reporting Chain

## Aim
Create a department salary summary view and an employee hierarchy view, verify that a simple view can be updated, and use a recursive CTE to display reporting paths.

## Description
`department_salary_summary` aggregates headcount, total salary, and average salary by department. `employee_hierarchy` joins each employee to their manager. `employee_basic` is a single-table view used for a salary update. The recursive CTE begins with employees without managers and repeatedly adds their direct reports while building a readable path.

## Requirements and run
MySQL 8.0 or later (for `WITH RECURSIVE`). Run [`experiment_5.sql`](experiment_5.sql) in order. It creates the three departments and seven employees, creates the views, performs the view update, then returns the reporting chain.

## Code
The full runnable source is [`experiment_5.sql`](experiment_5.sql), included below:

```sql
-- Experiment 5: SQL views, view updatability, recursive reporting chain
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS DBMS_LAB;
USE DBMS_LAB;

DROP VIEW IF EXISTS department_salary_summary;
DROP VIEW IF EXISTS employee_hierarchy;
DROP VIEW IF EXISTS employee_basic;
DROP TABLE IF EXISTS employee;
DROP TABLE IF EXISTS department;

CREATE TABLE department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL
);

CREATE TABLE employee (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(100) NOT NULL,
    department_id INT,
    manager_id INT NULL,
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES department(department_id),
    FOREIGN KEY (manager_id) REFERENCES employee(employee_id)
);

INSERT INTO department VALUES
(1, 'IT'), (2, 'HR'), (3, 'Finance');

INSERT INTO employee VALUES
(101, 'Amit', 1, NULL, 90000),
(102, 'Neha', 1, 101, 65000),
(103, 'Rahul', 1, 101, 60000),
(104, 'Priya', 2, NULL, 80000),
(105, 'Karan', 2, 104, 55000),
(106, 'Riya', 3, NULL, 85000),
(107, 'Arjun', 3, 106, 50000);

-- 1. Aggregate department salary view
CREATE VIEW department_salary_summary AS
SELECT d.department_id, d.department_name,
       COUNT(e.employee_id) AS employee_count,
       SUM(e.salary) AS total_salary,
       AVG(e.salary) AS average_salary
FROM department d LEFT JOIN employee e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

SELECT * FROM department_salary_summary;

-- 2. Employee and manager hierarchy view
CREATE VIEW employee_hierarchy AS
SELECT e.employee_id, e.employee_name, e.department_id, e.manager_id,
       m.employee_name AS manager_name, e.salary
FROM employee e LEFT JOIN employee m ON e.manager_id = m.employee_id;

SELECT * FROM employee_hierarchy;

-- 3. Updatable single-table view
CREATE VIEW employee_basic AS
SELECT employee_id, employee_name, salary FROM employee;

UPDATE employee_basic SET salary = salary + 5000 WHERE employee_id = 102;
SELECT * FROM employee_basic WHERE employee_id = 102;

-- 4. Recursive reporting chain from top-level employees to their reports
WITH RECURSIVE reporting_chain AS (
    SELECT employee_id, employee_name, manager_id, 0 AS level,
           CAST(employee_name AS CHAR(1000)) AS reporting_path
    FROM employee WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.employee_name, e.manager_id,
           rc.level + 1,
           CONCAT(rc.reporting_path, ' -> ', e.employee_name)
    FROM employee e
    INNER JOIN reporting_chain rc ON e.manager_id = rc.employee_id
)
SELECT employee_id, employee_name, manager_id, level, reporting_path
FROM reporting_chain ORDER BY reporting_path;
```

## Output

Department summary before the update:

| Department | Employees | Total salary | Average salary |
|---|---:|---:|---:|
| IT | 3 | 215,000.00 | 71,666.67 |
| HR | 2 | 135,000.00 | 67,500.00 |
| Finance | 2 | 135,000.00 | 67,500.00 |

The hierarchy view returns seven employees; Amit, Priya, and Riya have no manager, while the other four show their manager's name. The `employee_basic` update raises Neha's salary from 65,000 to 70,000. The recursive CTE returns seven rows with levels 0 and 1 and paths such as `Amit -> Neha`, `Amit -> Rahul`, `Priya -> Karan`, and `Riya -> Arjun`.

