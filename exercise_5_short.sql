-- EXERCISE 5: PL/SQL PROGRAMMING (SHORT VERSION)

-- Create database and table
CREATE DATABASE company;
USE company;

CREATE TABLE employees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50),
    salary DECIMAL(10,2),
    department VARCHAR(30)
);

INSERT INTO employees VALUES
(1, 'John', 70000, 'IT'),
(2, 'Jane', 60000, 'HR'),
(3, 'Mike', 80000, 'Finance');

-- 1. BASIC PL/SQL PROCEDURE (All 3 sections)
DELIMITER //
CREATE PROCEDURE emp_stats()
BEGIN
    -- DECLARATION SECTION
    DECLARE emp_count INT;
    DECLARE avg_sal DECIMAL(10,2);
    
    -- EXECUTABLE SECTION
    BEGIN
        SELECT COUNT(*), AVG(salary) INTO emp_count, avg_sal FROM employees;
        SELECT emp_count as 'Total', avg_sal as 'Average Salary';
    END;
    
    -- EXCEPTION SECTION (MySQL style)
    -- Exception handling done with EXIT HANDLER
END //
DELIMITER ;

CALL emp_stats();
-- Output: Total: 3, Average Salary: 70000.00

-- 2. PL/SQL WITH IF-ELSE
DELIMITER //
CREATE PROCEDURE salary_category(IN emp_id INT)
BEGIN
    DECLARE sal DECIMAL(10,2);
    DECLARE category VARCHAR(20);
    
    SELECT salary INTO sal FROM employees WHERE id = emp_id;
    
    IF sal > 75000 THEN
        SET category = 'High';
    ELSEIF sal > 65000 THEN
        SET category = 'Medium';
    ELSE
        SET category = 'Low';
    END IF;
    
    SELECT sal as 'Salary', category as 'Category';
END //
DELIMITER ;

CALL salary_category(1);
-- Output: Salary: 70000.00, Category: Medium

-- 3. PL/SQL WITH WHILE LOOP
DELIMITER //
CREATE PROCEDURE count_loop()
BEGIN
    DECLARE counter INT DEFAULT 1;
    
    CREATE TEMPORARY TABLE temp_numbers (num INT);
    
    WHILE counter <= 3 DO
        INSERT INTO temp_numbers VALUES (counter);
        SET counter = counter + 1;
    END WHILE;
    
    SELECT * FROM temp_numbers;
    DROP TEMPORARY TABLE temp_numbers;
END //
DELIMITER ;

CALL count_loop();
-- Output: 1, 2, 3

-- 4. PL/SQL WITH EXCEPTION HANDLING
DELIMITER //
CREATE PROCEDURE safe_update(IN emp_id INT, IN new_salary DECIMAL(10,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'Error occurred' as message;
    END;
    
    START TRANSACTION;
    
    IF new_salary < 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Invalid salary';
    END IF;
    
    UPDATE employees SET salary = new_salary WHERE id = emp_id;
    COMMIT;
    
    SELECT 'Update successful' as message;
END //
DELIMITER ;

CALL safe_update(1, 75000);
-- Output: Update successful

-- 5. USER-DEFINED FUNCTION
DELIMITER //
CREATE FUNCTION bonus_calc(sal DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    RETURN sal * 0.1;
END //
DELIMITER ;

SELECT name, salary, bonus_calc(salary) as bonus FROM employees;
-- Output: Shows name, salary, and 10% bonus for each employee 