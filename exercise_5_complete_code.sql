-- =====================================================
-- EXERCISE 5: PL/SQL PROGRAMMING - COMPLETE CODE
-- Topic: Create PL/SQL programs with declaration, 
--        executable, and exception handling sections
-- =====================================================

-- Step 1: Create sample database and tables
CREATE DATABASE IF NOT EXISTS company_db;
USE company_db;

-- Create employees table
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    department VARCHAR(50),
    hire_date DATE,
    manager_id INT
);

-- Insert sample data
INSERT INTO employees (first_name, last_name, email, salary, department, hire_date, manager_id) VALUES
('John', 'Smith', 'john.smith@company.com', 75000, 'IT', '2020-01-15', NULL),
('Jane', 'Doe', 'jane.doe@company.com', 65000, 'HR', '2020-03-20', 1),
('Mike', 'Johnson', 'mike.johnson@company.com', 80000, 'Finance', '2019-05-10', NULL),
('Sarah', 'Wilson', 'sarah.wilson@company.com', 70000, 'IT', '2021-02-28', 1),
('Tom', 'Brown', 'tom.brown@company.com', 85000, 'Finance', '2018-08-12', 3),
('Lisa', 'Davis', 'lisa.davis@company.com', 60000, 'HR', '2021-06-15', 1),
('David', 'Miller', 'david.miller@company.com', 72000, 'Marketing', '2020-11-30', NULL),
('Amy', 'Garcia', 'amy.garcia@company.com', 58000, 'Marketing', '2022-01-10', 7);

-- Create departments table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL,
    budget DECIMAL(12,2),
    location VARCHAR(100)
);

-- Insert department data
INSERT INTO departments (dept_name, budget, location) VALUES
('IT', 500000, 'Building A'),
('HR', 200000, 'Building B'),
('Finance', 300000, 'Building C'),
('Marketing', 150000, 'Building D');

-- =====================================================
-- PL/SQL EXAMPLE 1: Basic Procedure with All Sections
-- =====================================================

DELIMITER //
CREATE PROCEDURE employee_statistics()
BEGIN
    -- DECLARATION SECTION
    DECLARE emp_count INT DEFAULT 0;
    DECLARE avg_salary DECIMAL(10,2) DEFAULT 0;
    DECLARE max_salary DECIMAL(10,2) DEFAULT 0;
    DECLARE min_salary DECIMAL(10,2) DEFAULT 0;
    DECLARE total_salary DECIMAL(15,2) DEFAULT 0;
    DECLARE message VARCHAR(200);
    
    -- EXECUTABLE SECTION
    BEGIN
        -- Get employee statistics
        SELECT COUNT(*), AVG(salary), MAX(salary), MIN(salary), SUM(salary)
        INTO emp_count, avg_salary, max_salary, min_salary, total_salary
        FROM employees;
        
        -- Create summary message
        SET message = CONCAT('Company has ', emp_count, ' employees with average salary $', 
                           ROUND(avg_salary, 2));
        
        -- Display results
        SELECT 'EMPLOYEE STATISTICS REPORT' as report_title;
        SELECT emp_count as 'Total Employees', 
               CONCAT('$', FORMAT(avg_salary, 2)) as 'Average Salary',
               CONCAT('$', FORMAT(max_salary, 2)) as 'Highest Salary',
               CONCAT('$', FORMAT(min_salary, 2)) as 'Lowest Salary',
               CONCAT('$', FORMAT(total_salary, 2)) as 'Total Payroll';
        SELECT message as 'Summary Message';
        
    END;
    
    -- EXCEPTION HANDLING SECTION
    -- Note: MySQL uses different syntax for exception handling
    -- We'll show error handling in next example
    
END //
DELIMITER ;

-- Execute the procedure
CALL employee_statistics();

-- Expected Output:
-- +---------------------------+
-- | report_title              |
-- +---------------------------+
-- | EMPLOYEE STATISTICS REPORT|
-- +---------------------------+

-- +-----------------+----------------+----------------+---------------+----------------+
-- | Total Employees | Average Salary | Highest Salary | Lowest Salary | Total Payroll  |
-- +-----------------+----------------+----------------+---------------+----------------+
-- |               8 | $70,625.00     | $85,000.00     | $58,000.00    | $565,000.00    |
-- +-----------------+----------------+----------------+---------------+----------------+

-- +----------------------------------------------------------+
-- | Summary Message                                          |
-- +----------------------------------------------------------+
-- | Company has 8 employees with average salary $70625.00   |
-- +----------------------------------------------------------+

-- =====================================================
-- PL/SQL EXAMPLE 2: Procedure with IF-ELSE Logic
-- =====================================================

DELIMITER //
CREATE PROCEDURE categorize_employee_salary(IN emp_id INT)
BEGIN
    -- DECLARATION SECTION
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE emp_name VARCHAR(100);
    DECLARE salary_category VARCHAR(20);
    DECLARE bonus_percentage DECIMAL(5,2);
    DECLARE annual_bonus DECIMAL(10,2);
    DECLARE emp_not_found CONDITION FOR SQLSTATE '02000';
    
    -- EXECUTABLE SECTION
    BEGIN
        -- Get employee information
        SELECT CONCAT(first_name, ' ', last_name), salary
        INTO emp_name, emp_salary
        FROM employees
        WHERE employee_id = emp_id;
        
        -- Categorize salary using IF-ELSE
        IF emp_salary >= 80000 THEN
            SET salary_category = 'High';
            SET bonus_percentage = 15.0;
        ELSEIF emp_salary >= 65000 THEN
            SET salary_category = 'Medium';
            SET bonus_percentage = 10.0;
        ELSE
            SET salary_category = 'Low';
            SET bonus_percentage = 5.0;
        END IF;
        
        -- Calculate bonus
        SET annual_bonus = emp_salary * (bonus_percentage / 100);
        
        -- Display results
        SELECT emp_name as 'Employee Name',
               CONCAT('$', FORMAT(emp_salary, 2)) as 'Current Salary',
               salary_category as 'Salary Category',
               CONCAT(bonus_percentage, '%') as 'Bonus Percentage',
               CONCAT('$', FORMAT(annual_bonus, 2)) as 'Annual Bonus';
               
    END;
    
    -- EXCEPTION HANDLING SECTION
    -- Handle case when employee not found
    -- Note: MySQL syntax for exception handling
    
END //
DELIMITER ;

-- Test the procedure with different employees
CALL categorize_employee_salary(1);

-- Expected Output:
-- +---------------+----------------+-----------------+------------------+--------------+
-- | Employee Name | Current Salary | Salary Category | Bonus Percentage | Annual Bonus |
-- +---------------+----------------+-----------------+------------------+--------------+
-- | John Smith    | $75,000.00     | Medium          | 10.0%            | $7,500.00    |
-- +---------------+----------------+-----------------+------------------+--------------+

CALL categorize_employee_salary(5);

-- Expected Output:
-- +---------------+----------------+-----------------+------------------+--------------+
-- | Employee Name | Current Salary | Salary Category | Bonus Percentage | Annual Bonus |
-- +---------------+----------------+-----------------+------------------+--------------+
-- | Tom Brown     | $85,000.00     | High            | 15.0%            | $12,750.00   |
-- +---------------+----------------+-----------------+------------------+--------------+

-- =====================================================
-- PL/SQL EXAMPLE 3: Procedure with WHILE Loop
-- =====================================================

DELIMITER //
CREATE PROCEDURE generate_employee_numbers()
BEGIN
    -- DECLARATION SECTION
    DECLARE counter INT DEFAULT 1;
    DECLARE max_employees INT DEFAULT 5;
    DECLARE employee_code VARCHAR(10);
    
    -- Create temporary table to store results
    CREATE TEMPORARY TABLE temp_employee_codes (
        sequence_num INT,
        employee_code VARCHAR(10),
        description VARCHAR(50)
    );
    
    -- EXECUTABLE SECTION
    BEGIN
        -- Loop to generate employee codes
        WHILE counter <= max_employees DO
            -- Generate employee code
            SET employee_code = CONCAT('EMP', LPAD(counter, 3, '0'));
            
            -- Insert into temporary table
            INSERT INTO temp_employee_codes (sequence_num, employee_code, description)
            VALUES (counter, employee_code, CONCAT('Employee Code #', counter));
            
            -- Increment counter
            SET counter = counter + 1;
        END WHILE;
        
        -- Display results
        SELECT 'GENERATED EMPLOYEE CODES' as title;
        SELECT * FROM temp_employee_codes ORDER BY sequence_num;
        
        -- Clean up
        DROP TEMPORARY TABLE temp_employee_codes;
        
    END;
    
END //
DELIMITER ;

-- Execute the loop procedure
CALL generate_employee_numbers();

-- Expected Output:
-- +---------------------------+
-- | title                     |
-- +---------------------------+
-- | GENERATED EMPLOYEE CODES  |
-- +---------------------------+

-- +--------------+---------------+-------------------+
-- | sequence_num | employee_code | description       |
-- +--------------+---------------+-------------------+
-- |            1 | EMP001        | Employee Code #1  |
-- |            2 | EMP002        | Employee Code #2  |
-- |            3 | EMP003        | Employee Code #3  |
-- |            4 | EMP004        | Employee Code #4  |
-- |            5 | EMP005        | Employee Code #5  |
-- +--------------+---------------+-------------------+

-- =====================================================
-- PL/SQL EXAMPLE 4: Advanced Procedure with Exception Handling
-- =====================================================

DELIMITER //
CREATE PROCEDURE update_employee_salary(
    IN emp_id INT, 
    IN new_salary DECIMAL(10,2),
    IN increase_percentage DECIMAL(5,2)
)
BEGIN
    -- DECLARATION SECTION
    DECLARE old_salary DECIMAL(10,2);
    DECLARE emp_name VARCHAR(100);
    DECLARE calculated_salary DECIMAL(10,2);
    DECLARE salary_difference DECIMAL(10,2);
    DECLARE update_successful BOOLEAN DEFAULT FALSE;
    
    -- Exception handling variables
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SELECT 'ERROR: Transaction rolled back due to an error' as error_message;
    END;
    
    -- EXECUTABLE SECTION
    BEGIN
        -- Start transaction
        START TRANSACTION;
        
        -- Get current employee information
        SELECT CONCAT(first_name, ' ', last_name), salary
        INTO emp_name, old_salary
        FROM employees
        WHERE employee_id = emp_id;
        
        -- Calculate new salary based on percentage or fixed amount
        IF new_salary IS NOT NULL THEN
            SET calculated_salary = new_salary;
        ELSE
            SET calculated_salary = old_salary * (1 + increase_percentage / 100);
        END IF;
        
        -- Validate salary increase (business rule: max 50% increase)
        SET salary_difference = calculated_salary - old_salary;
        IF salary_difference > (old_salary * 0.5) THEN
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Salary increase cannot exceed 50% of current salary';
        END IF;
        
        -- Update employee salary
        UPDATE employees 
        SET salary = calculated_salary 
        WHERE employee_id = emp_id;
        
        -- Check if update was successful
        IF ROW_COUNT() > 0 THEN
            SET update_successful = TRUE;
            COMMIT;
        ELSE
            ROLLBACK;
            SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Employee not found';
        END IF;
        
        -- Display results
        IF update_successful THEN
            SELECT 'SALARY UPDATE SUCCESSFUL' as status;
            SELECT emp_name as 'Employee Name',
                   CONCAT('$', FORMAT(old_salary, 2)) as 'Old Salary',
                   CONCAT('$', FORMAT(calculated_salary, 2)) as 'New Salary',
                   CONCAT('$', FORMAT(salary_difference, 2)) as 'Increase Amount',
                   CONCAT(ROUND((salary_difference / old_salary) * 100, 2), '%') as 'Increase Percentage';
        END IF;
        
    END;
    
    -- EXCEPTION HANDLING is done by the EXIT HANDLER above
    
END //
DELIMITER ;

-- Test successful salary update
CALL update_employee_salary(1, NULL, 10.0);

-- Expected Output:
-- +-------------------------+
-- | status                  |
-- +-------------------------+
-- | SALARY UPDATE SUCCESSFUL|
-- +-------------------------+

-- +---------------+------------+------------+-----------------+--------------------+
-- | Employee Name | Old Salary | New Salary | Increase Amount | Increase Percentage|
-- +---------------+------------+------------+-----------------+--------------------+
-- | John Smith    | $75,000.00 | $82,500.00 | $7,500.00       | 10.00%             |
-- +---------------+------------+------------+-----------------+--------------------+

-- Test failed salary update (too high increase)
CALL update_employee_salary(2, 200000, NULL);

-- Expected Output:
-- ERROR 1644 (45000): Salary increase cannot exceed 50% of current salary

-- =====================================================
-- PL/SQL EXAMPLE 5: Function with Return Value
-- =====================================================

DELIMITER //
CREATE FUNCTION calculate_years_of_service(hire_date DATE)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    -- DECLARATION SECTION
    DECLARE years_service INT;
    
    -- EXECUTABLE SECTION
    -- Calculate years of service
    SET years_service = TIMESTAMPDIFF(YEAR, hire_date, CURDATE());
    
    -- Return the result
    RETURN years_service;
    
    -- Note: Functions don't have explicit exception handling section
    -- But you can use SIGNAL for error handling
    
END //
DELIMITER ;

-- Use the function in queries
SELECT 
    CONCAT(first_name, ' ', last_name) as employee_name,
    hire_date,
    calculate_years_of_service(hire_date) as years_of_service,
    CASE 
        WHEN calculate_years_of_service(hire_date) >= 5 THEN 'Senior'
        WHEN calculate_years_of_service(hire_date) >= 2 THEN 'Experienced'
        ELSE 'Junior'
    END as experience_level
FROM employees
ORDER BY years_of_service DESC;

-- Expected Output:
-- +---------------+------------+------------------+------------------+
-- | employee_name | hire_date  | years_of_service | experience_level |
-- +---------------+------------+------------------+------------------+
-- | Tom Brown     | 2018-08-12 |                5 | Senior           |
-- | Mike Johnson  | 2019-05-10 |                4 | Experienced      |
-- | John Smith    | 2020-01-15 |                4 | Experienced      |
-- | Jane Doe      | 2020-03-20 |                3 | Experienced      |
-- | David Miller  | 2020-11-30 |                3 | Experienced      |
-- | Sarah Wilson  | 2021-02-28 |                2 | Experienced      |
-- | Lisa Davis    | 2021-06-15 |                2 | Experienced      |
-- | Amy Garcia    | 2022-01-10 |                2 | Experienced      |
-- +---------------+------------+------------------+------------------+

-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

-- Check final employee data
SELECT 'FINAL EMPLOYEE DATA' as title;
SELECT employee_id, 
       CONCAT(first_name, ' ', last_name) as name,
       department,
       CONCAT('$', FORMAT(salary, 2)) as salary,
       hire_date
FROM employees
ORDER BY employee_id;

-- Show all procedures and functions created
SELECT 'CREATED PROCEDURES AND FUNCTIONS' as title;
SHOW PROCEDURE STATUS WHERE Db = 'company_db';
SHOW FUNCTION STATUS WHERE Db = 'company_db';

-- =====================================================
-- CLEANUP (Optional - for testing purposes)
-- =====================================================

-- To drop the procedures and functions:
-- DROP PROCEDURE IF EXISTS employee_statistics;
-- DROP PROCEDURE IF EXISTS categorize_employee_salary;
-- DROP PROCEDURE IF EXISTS generate_employee_numbers;
-- DROP PROCEDURE IF EXISTS update_employee_salary;
-- DROP FUNCTION IF EXISTS calculate_years_of_service;

-- To drop the database:
-- DROP DATABASE IF EXISTS company_db; 