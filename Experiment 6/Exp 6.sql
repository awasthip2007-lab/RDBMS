-- Experiment 6: Stored procedure validation and salary triggers/audit
-- MySQL 8.0+
CREATE DATABASE IF NOT EXISTS DBMS_LAB;
USE DBMS_LAB;

DROP TRIGGER IF EXISTS salary_audit_after_update;
DROP TRIGGER IF EXISTS validate_salary_before_update;
DROP TRIGGER IF EXISTS validate_salary_before_insert;
DROP PROCEDURE IF EXISTS transfer_employee;
DROP TABLE IF EXISTS salary_audit;
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
    salary DECIMAL(10,2),
    FOREIGN KEY (department_id) REFERENCES department(department_id)
);

INSERT INTO department VALUES
(1, 'IT'), (2, 'HR'), (3, 'Finance');

INSERT INTO employee VALUES
(101, 'Amit', 1, 90000),
(102, 'Neha', 1, 65000),
(103, 'Rahul', 2, 60000),
(104, 'Priya', 3, 80000);

CREATE TABLE salary_audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

DELIMITER //
CREATE PROCEDURE transfer_employee(IN emp_id INT, IN new_dept_id INT)
BEGIN
    DECLARE employee_count INT DEFAULT 0;
    DECLARE department_count INT DEFAULT 0;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;
    SELECT COUNT(*) INTO employee_count FROM employee WHERE employee_id = emp_id;
    IF employee_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;

    SELECT COUNT(*) INTO department_count FROM department WHERE department_id = new_dept_id;
    IF department_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Department does not exist';
    END IF;

    UPDATE employee SET department_id = new_dept_id WHERE employee_id = emp_id;
    COMMIT;
END //

CREATE TRIGGER validate_salary_before_insert
BEFORE INSERT ON employee FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //

CREATE TRIGGER validate_salary_before_update
BEFORE UPDATE ON employee FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //

CREATE TRIGGER salary_audit_after_update
AFTER UPDATE ON employee FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO salary_audit (employee_id, old_salary, new_salary)
        VALUES (OLD.employee_id, OLD.salary, NEW.salary);
    END IF;
END //
DELIMITER ;

-- Valid transfer: employee 102 moves from IT to HR
CALL transfer_employee(102, 2);
SELECT * FROM employee WHERE employee_id = 102;

-- Invalid calls demonstrate validation errors; run separately if your SQL client
-- stops the script after an error. Uncomment each call to observe the error.
-- CALL transfer_employee(999, 2);
-- CALL transfer_employee(102, 99);

-- Invalid salary update must fail; run separately to observe the trigger error.
-- UPDATE employee SET salary = -5000 WHERE employee_id = 101;

-- Valid salary update is recorded by the audit trigger
UPDATE employee SET salary = 95000 WHERE employee_id = 101;
SELECT * FROM salary_audit;