# DBMS Lab Exam Guide - Specific Questions (1-10)

## **Essential Definitions - Quick Reference**

### **Key Database Terms**
- **Primary Key**: Unique identifier for each row (cannot be NULL)
- **Foreign Key**: Column that references primary key in another table
- **Constraint**: Rule that limits data that can be stored (NOT NULL, UNIQUE, CHECK, DEFAULT)
- **Schema**: Logical structure of database (tables, relationships, constraints)
- **Referential Integrity**: Foreign keys must match existing primary keys

### **SQL Command Types**
- **DDL**: Data Definition Language (CREATE, ALTER, DROP)
- **DML**: Data Manipulation Language (SELECT, INSERT, UPDATE, DELETE)
- **Aggregate Functions**: COUNT(), SUM(), AVG(), MAX(), MIN()
- **Join Types**: INNER, LEFT, RIGHT, FULL OUTER, CROSS, SELF

### **Query Clauses (Execution Order)**
1. **FROM** - Specify tables
2. **WHERE** - Filter rows  
3. **GROUP BY** - Group rows
4. **HAVING** - Filter groups
5. **SELECT** - Choose columns
6. **ORDER BY** - Sort results

### **Subquery Types**
- **Scalar**: Returns single value
- **Correlated**: References outer query columns
- **EXISTS**: Checks if subquery returns any rows
- **ANY/ALL**: Compares with any/all values from subquery

### **PL/SQL Structure**
```sql
DECLARE
    -- Variable declarations
BEGIN
    -- Executable statements
EXCEPTION
    -- Error handling
END;
```

---

Based on your syllabus, here are the 10 possible lab exercises. You'll get **ONE** of these in your exam.

---

## **Exercise 1: Table Operations & Constraints**
**Topic:** Creation, altering and dropping of tables and inserting rows into a table (use constraints while creating tables) examples using SELECT command.

### **Key Definitions for This Exercise:**
- **CREATE TABLE**: DDL command to create new table with columns and constraints
- **ALTER TABLE**: Modify existing table structure (ADD, MODIFY, DROP columns)
- **DROP TABLE**: Remove table and all its data permanently
- **Constraints**: Rules that enforce data integrity (PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, DEFAULT)

### What you need to know:
```sql
-- CREATE TABLE with constraints
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    age INT CHECK (age >= 18),
    department VARCHAR(30) DEFAULT 'General',
    gpa DECIMAL(3,2) CHECK (gpa >= 0.0 AND gpa <= 4.0)
);

-- ALTER TABLE
ALTER TABLE students ADD COLUMN phone VARCHAR(15);
ALTER TABLE students MODIFY COLUMN name VARCHAR(100);
ALTER TABLE students DROP COLUMN phone;

-- DROP TABLE
DROP TABLE students;

-- INSERT with constraints
INSERT INTO students (name, email, age, department, gpa)
VALUES ('John Doe', 'john@email.com', 20, 'CS', 3.5);

-- SELECT examples
SELECT * FROM students;
SELECT name, gpa FROM students WHERE gpa > 3.0;
```

---

## **Exercise 2: Advanced Queries**
**Topic:** Queries (along with sub Queries) using ANY, ALL, IN, EXISTS, NOTEXISTS, UNION, INTERSECT, Constraints.

### **Key Definitions for This Exercise:**
- **Subquery**: Query nested inside another query
- **ANY**: Condition true if comparison is true for any value returned by subquery
- **ALL**: Condition true if comparison is true for all values returned by subquery
- **EXISTS**: Returns true if subquery returns at least one row
- **UNION**: Combines results from two queries, removes duplicates
- **INTERSECT**: Returns common rows from two result sets

### What you need to know:
```sql
-- ANY
SELECT * FROM employees 
WHERE salary > ANY (SELECT salary FROM employees WHERE department = 'HR');

-- ALL
SELECT * FROM employees 
WHERE salary > ALL (SELECT salary FROM employees WHERE department = 'HR');

-- IN
SELECT * FROM employees 
WHERE department_id IN (SELECT department_id FROM departments WHERE location = 'NYC');

-- EXISTS
SELECT * FROM employees e
WHERE EXISTS (SELECT 1 FROM departments d WHERE d.dept_id = e.dept_id AND d.budget > 100000);

-- NOT EXISTS
SELECT * FROM employees e
WHERE NOT EXISTS (SELECT 1 FROM projects p WHERE p.emp_id = e.emp_id);

-- UNION
SELECT name FROM employees
UNION
SELECT name FROM managers;

-- UNION ALL (includes duplicates)
SELECT department FROM employees
UNION ALL
SELECT department FROM contractors;

-- INTERSECT (MySQL doesn't support, use INNER JOIN)
SELECT e.name FROM employees e
INNER JOIN managers m ON e.name = m.name;
```

---

## **Exercise 3: Aggregate Functions & Grouping**
**Topic:** Queries using Aggregate functions (COUNT, SUM, AVG, MAX and MIN), GROUP BY, HAVING and Creation and dropping of Views.

### **Key Definitions for This Exercise:**
- **Aggregate Functions**: Functions that perform calculations on multiple rows (COUNT, SUM, AVG, MAX, MIN)
- **GROUP BY**: Groups rows with same values in specified columns
- **HAVING**: Filters groups (used with GROUP BY, similar to WHERE but for groups)
- **View**: Virtual table based on SELECT statement, doesn't store data physically

### What you need to know:
```sql
-- Aggregate Functions
SELECT COUNT(*) as total_employees FROM employees;
SELECT SUM(salary) as total_salary FROM employees;
SELECT AVG(salary) as avg_salary FROM employees;
SELECT MAX(salary) as highest_salary FROM employees;
SELECT MIN(salary) as lowest_salary FROM employees;

-- GROUP BY
SELECT department, COUNT(*) as emp_count, AVG(salary) as avg_sal
FROM employees
GROUP BY department;

-- HAVING (filter groups)
SELECT department, COUNT(*) as emp_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;

-- Complex grouping
SELECT department, 
       COUNT(*) as total_emp,
       AVG(salary) as avg_salary,
       MAX(salary) as max_salary,
       MIN(salary) as min_salary
FROM employees
GROUP BY department
HAVING AVG(salary) > 50000;

-- CREATE VIEW
CREATE VIEW high_earners AS
SELECT name, salary, department
FROM employees
WHERE salary > 60000;

-- Use VIEW
SELECT * FROM high_earners WHERE department = 'IT';

-- DROP VIEW
DROP VIEW high_earners;
```

---

## **Exercise 4: Built-in Functions**
**Topic:** Queries using Conversion functions (to_char, to_number and to_date), string functions (Concatenation, lpad, rpad, ltrim, rtrim, lower, upper, initcap, length, substr and instr), date functions (Sysdate, next_day, add_months, last_day, months_between, least, greatest, trunc, round, to_char, to_date).

### **Key Definitions for This Exercise:**
- **String Functions**: Functions that manipulate text data (CONCAT, UPPER, LOWER, LENGTH, SUBSTRING, TRIM)
- **Date Functions**: Functions that work with date/time data (NOW, CURDATE, YEAR, MONTH, DATEDIFF)
- **Conversion Functions**: Functions that convert data types (CAST, STR_TO_DATE, DATE_FORMAT)
- **Mathematical Functions**: Functions for numeric calculations (ROUND, CEIL, FLOOR, ABS)

### What you need to know:
```sql
-- String Functions
SELECT CONCAT(first_name, ' ', last_name) as full_name FROM employees;
SELECT UPPER(name), LOWER(email) FROM employees;
SELECT LENGTH(name) as name_length FROM employees;
SELECT SUBSTRING(name, 1, 3) as first_three_chars FROM employees;
SELECT TRIM(name) FROM employees; -- removes leading/trailing spaces
SELECT LPAD(name, 10, '*') FROM employees; -- left pad
SELECT RPAD(name, 10, '*') FROM employees; -- right pad

-- Date Functions
SELECT NOW() as current_datetime;
SELECT CURDATE() as current_date;
SELECT YEAR(hire_date) as hire_year FROM employees;
SELECT MONTH(hire_date) as hire_month FROM employees;
SELECT DAY(hire_date) as hire_day FROM employees;
SELECT DATEDIFF(NOW(), hire_date) as days_employed FROM employees;

-- Conversion Functions (MySQL syntax)
SELECT CAST(salary AS CHAR) as salary_string FROM employees;
SELECT CAST('123' AS SIGNED) as number_value;
SELECT STR_TO_DATE('2023-12-25', '%Y-%m-%d') as date_value;
SELECT DATE_FORMAT(hire_date, '%Y-%m-%d') as formatted_date FROM employees;

-- Mathematical Functions
SELECT ROUND(salary/12, 2) as monthly_salary FROM employees;
SELECT CEIL(salary/1000) FROM employees;
SELECT FLOOR(salary/1000) FROM employees;
```

---

## **Exercise 5: PL/SQL Programming**
**Topic:** Create a simple PL/SQL program which includes declaration section, executable section and exception handling section.

### **Key Definitions for This Exercise:**
- **PL/SQL**: Procedural Language extension to SQL
- **DECLARE Section**: Where variables, constants, and cursors are declared
- **BEGIN Section**: Contains executable statements
- **EXCEPTION Section**: Handles runtime errors
- **Variable**: Named storage location that holds data
- **Control Structures**: IF-ELSE, WHILE loops, FOR loops for program flow control

### What you need to know:
```sql
-- Basic PL/SQL Block Structure
DELIMITER //
CREATE PROCEDURE simple_procedure()
BEGIN
    -- Declaration section
    DECLARE 
        emp_count INT DEFAULT 0;
        avg_sal DECIMAL(10,2);
        emp_name VARCHAR(50);
        
    -- Executable section
    BEGIN
        -- Get employee count
        SELECT COUNT(*) INTO emp_count FROM employees;
        
        -- Get average salary
        SELECT AVG(salary) INTO avg_sal FROM employees;
        
        -- Display results
        SELECT CONCAT('Total Employees: ', emp_count, ', Average Salary: ', avg_sal) as result;
        
    -- Exception handling section
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            SELECT 'No data found' as error_message;
        WHEN OTHERS THEN
            SELECT 'An error occurred' as error_message;
    END;
END //
DELIMITER ;

-- Call procedure
CALL simple_procedure();

-- Expected Output:
-- +------------------------------------------+
-- | result                                   |
-- +------------------------------------------+
-- | Total Employees: 8, Average Salary: 70625.00 |
-- +------------------------------------------+

-- PL/SQL with IF-ELSE
DELIMITER //
CREATE PROCEDURE check_salary(IN emp_id INT)
BEGIN
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE salary_category VARCHAR(20);
    
    -- Get employee salary
    SELECT salary INTO emp_salary 
    FROM employees 
    WHERE employee_id = emp_id;
    
    -- Categorize salary
    IF emp_salary > 70000 THEN
        SET salary_category = 'High';
    ELSEIF emp_salary > 40000 THEN
        SET salary_category = 'Medium';
    ELSE
        SET salary_category = 'Low';
    END IF;
    
    SELECT CONCAT('Employee salary category: ', salary_category) as result;
END //
DELIMITER ;

-- Call with specific employee ID
CALL check_salary(101);

-- Expected Output:
-- +----------------------------------+
-- | result                           |
-- +----------------------------------+
-- | Employee salary category: High   |
-- +----------------------------------+

-- PL/SQL with LOOP
DELIMITER //
CREATE PROCEDURE demo_loop()
BEGIN
    DECLARE counter INT DEFAULT 1;
    
    WHILE counter <= 5 DO
        SELECT CONCAT('Counter: ', counter) as loop_output;
        SET counter = counter + 1;
    END WHILE;
END //
DELIMITER ;

-- Call loop procedure
CALL demo_loop();

-- Expected Output:
-- +-------------+
-- | loop_output |
-- +-------------+
-- | Counter: 1  |
-- | Counter: 2  |
-- | Counter: 3  |
-- | Counter: 4  |
-- | Counter: 5  |
-- +-------------+
```

---

## **Exercise 6: Cursors and Advanced PL/SQL**
**Topic:** Working with cursors, loops, and advanced PL/SQL constructs for data processing.

### **Key Definitions for This Exercise:**
- **Cursor**: Pointer to a result set that allows row-by-row processing
- **FETCH**: Retrieves data from cursor into variables
- **LOOP**: Iterative structure for repetitive operations
- **CURSOR FOR LOOP**: Simplified cursor handling

### What you need to know:
```sql
-- Create sample data first
CREATE TABLE employee_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    audit_date DATE
);

-- Cursor Example with Manual Control
DELIMITER //
CREATE PROCEDURE process_salary_increase()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE emp_id INT;
    DECLARE emp_salary DECIMAL(10,2);
    DECLARE emp_dept VARCHAR(50);
    
    -- Declare cursor
    DECLARE emp_cursor CURSOR FOR 
        SELECT employee_id, salary, department 
        FROM employees 
        WHERE salary < 70000;
    
    -- Declare continue handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    -- Open cursor
    OPEN emp_cursor;
    
    -- Loop through cursor
    read_loop: LOOP
        FETCH emp_cursor INTO emp_id, emp_salary, emp_dept;
        
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Process each employee
        IF emp_dept = 'IT' THEN
            UPDATE employees 
            SET salary = salary * 1.15 
            WHERE employee_id = emp_id;
            
            INSERT INTO employee_audit (emp_id, old_salary, new_salary, audit_date)
            VALUES (emp_id, emp_salary, emp_salary * 1.15, CURDATE());
        END IF;
        
    END LOOP;
    
    -- Close cursor
    CLOSE emp_cursor;
    
    SELECT 'Salary increase processing completed' as message;
END //
DELIMITER ;

-- Call the procedure
CALL process_salary_increase();

-- Expected Output:
-- +------------------------------------+
-- | message                            |
-- +------------------------------------+
-- | Salary increase processing completed |
-- +------------------------------------+

-- Check audit table
SELECT * FROM employee_audit;

-- Expected Output:
-- +----------+--------+------------+------------+------------+
-- | audit_id | emp_id | old_salary | new_salary | audit_date |
-- +----------+--------+------------+------------+------------+
-- |        1 |    102 |   65000.00 |   74750.00 | 2024-01-15 |
-- +----------+--------+------------+------------+------------+

-- Simplified Cursor FOR LOOP
DELIMITER //
CREATE PROCEDURE generate_employee_report()
BEGIN
    DECLARE report_text TEXT DEFAULT '';
    
    -- Cursor FOR LOOP (simulated in MySQL)
    FOR emp_record IN (
        SELECT CONCAT(first_name, ' ', last_name) as full_name, 
               salary, department
        FROM employees 
        ORDER BY department, salary DESC
    ) DO
        SET report_text = CONCAT(report_text, 
            'Employee: ', emp_record.full_name, 
            ', Salary: $', emp_record.salary,
            ', Department: ', emp_record.department, '\n');
    END FOR;
    
    SELECT report_text as employee_report;
END //
DELIMITER ;
```

---

## **Exercise 7: Triggers and Database Events**
**Topic:** Creating triggers for automatic database operations (INSERT, UPDATE, DELETE triggers).

### **Key Definitions for This Exercise:**
- **Trigger**: Special stored procedure that automatically executes in response to database events
- **BEFORE Trigger**: Executes before the triggering event
- **AFTER Trigger**: Executes after the triggering event
- **NEW**: References new row values in INSERT/UPDATE triggers
- **OLD**: References old row values in UPDATE/DELETE triggers

### What you need to know:
```sql
-- Create audit table for triggers
CREATE TABLE salary_audit (
    audit_id INT PRIMARY KEY AUTO_INCREMENT,
    employee_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    change_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    operation VARCHAR(10),
    changed_by VARCHAR(50) DEFAULT USER()
);

-- BEFORE UPDATE Trigger
DELIMITER //
CREATE TRIGGER before_salary_update
    BEFORE UPDATE ON employees
    FOR EACH ROW
BEGIN
    -- Validate salary increase
    IF NEW.salary < OLD.salary THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Salary cannot be decreased';
    END IF;
    
    -- Log the change
    INSERT INTO salary_audit (employee_id, old_salary, new_salary, operation)
    VALUES (NEW.employee_id, OLD.salary, NEW.salary, 'UPDATE');
END //
DELIMITER ;

-- AFTER INSERT Trigger
DELIMITER //
CREATE TRIGGER after_employee_insert
    AFTER INSERT ON employees
    FOR EACH ROW
BEGIN
    -- Welcome message log
    INSERT INTO employee_logs (employee_id, message, log_date)
    VALUES (NEW.employee_id, 
            CONCAT('Welcome ', NEW.first_name, ' ', NEW.last_name), 
            NOW());
END //
DELIMITER ;

-- Test the triggers
-- Valid update (will succeed)
UPDATE employees SET salary = 80000 WHERE employee_id = 102;

-- Expected Output: Update successful, audit record created
SELECT * FROM salary_audit WHERE employee_id = 102;

-- Expected Output:
-- +----------+-------------+------------+------------+---------------------+-----------+-------------+
-- | audit_id | employee_id | old_salary | new_salary | change_date         | operation | changed_by  |
-- +----------+-------------+------------+------------+---------------------+-----------+-------------+
-- |        1 |         102 |   65000.00 |   80000.00 | 2024-01-15 10:30:00 | UPDATE    | root@localhost |
-- +----------+-------------+------------+------------+---------------------+-----------+-------------+

-- Invalid update (will fail)
UPDATE employees SET salary = 50000 WHERE employee_id = 102;

-- Expected Output: Error message
-- ERROR 1644 (45000): Salary cannot be decreased

-- BEFORE DELETE Trigger
DELIMITER //
CREATE TRIGGER before_employee_delete
    BEFORE DELETE ON employees
    FOR EACH ROW
BEGIN
    -- Archive employee data before deletion
    INSERT INTO deleted_employees (
        employee_id, first_name, last_name, salary, 
        department, deletion_date
    )
    VALUES (
        OLD.employee_id, OLD.first_name, OLD.last_name, 
        OLD.salary, OLD.department, NOW()
    );
END //
DELIMITER ;

-- Show all triggers
SHOW TRIGGERS;

-- Expected Output:
-- +------------------------+-------+----------+------+--------+
-- | Trigger                | Event | Table    | Type | Timing |
-- +------------------------+-------+----------+------+--------+
-- | before_salary_update   | UPDATE| employees| ROW  | BEFORE |
-- | after_employee_insert  | INSERT| employees| ROW  | AFTER  |
-- | before_employee_delete | DELETE| employees| ROW  | BEFORE |
-- +------------------------+-------+----------+------+--------+
```

---

## **Exercise 8: Indexes and Query Optimization**
**Topic:** Creating indexes, analyzing query performance, and optimization techniques.

### **Key Definitions for This Exercise:**
- **Index**: Database object that improves query performance by creating shortcuts to data
- **Primary Index**: Automatically created for primary key
- **Secondary Index**: User-created index on non-key columns
- **Composite Index**: Index on multiple columns
- **Query Execution Plan**: Shows how database executes a query

### What you need to know:
```sql
-- Create sample table with large dataset simulation
CREATE TABLE large_employee_table (
    id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    hire_date DATE,
    status VARCHAR(20)
);

-- Insert sample data (simulating large dataset)
INSERT INTO large_employee_table 
(first_name, last_name, email, department, salary, hire_date, status)
VALUES 
('John', 'Smith', 'john.smith@company.com', 'IT', 75000, '2020-01-15', 'Active'),
('Jane', 'Doe', 'jane.doe@company.com', 'HR', 65000, '2020-03-20', 'Active'),
('Mike', 'Johnson', 'mike.johnson@company.com', 'Finance', 80000, '2019-05-10', 'Active'),
('Sarah', 'Wilson', 'sarah.wilson@company.com', 'IT', 70000, '2021-02-28', 'Inactive'),
('Tom', 'Brown', 'tom.brown@company.com', 'Marketing', 72000, '2020-11-30', 'Active');

-- Query without index (slower)
SELECT * FROM large_employee_table WHERE department = 'IT';

-- Expected Output:
-- +----+------------+-----------+---------------------------+------------+--------+------------+----------+
-- | id | first_name | last_name | email                     | department | salary | hire_date  | status   |
-- +----+------------+-----------+---------------------------+------------+--------+------------+----------+
-- |  1 | John       | Smith     | john.smith@company.com    | IT         |  75000 | 2020-01-15 | Active   |
-- |  4 | Sarah      | Wilson    | sarah.wilson@company.com  | IT         |  70000 | 2021-02-28 | Inactive |
-- +----+------------+-----------+---------------------------+------------+--------+------------+----------+

-- Create single column index
CREATE INDEX idx_department ON large_employee_table(department);

-- Create composite index
CREATE INDEX idx_dept_salary ON large_employee_table(department, salary);

-- Create unique index
CREATE UNIQUE INDEX idx_email ON large_employee_table(email);

-- Show all indexes on table
SHOW INDEXES FROM large_employee_table;

-- Expected Output:
-- +---------------------+------------+----------------+--------------+-------------+
-- | Table               | Non_unique | Key_name       | Seq_in_index | Column_name |
-- +---------------------+------------+----------------+--------------+-------------+
-- | large_employee_table|          0 | PRIMARY        |            1 | id          |
-- | large_employee_table|          0 | idx_email      |            1 | email       |
-- | large_employee_table|          1 | idx_department |            1 | department  |
-- | large_employee_table|          1 | idx_dept_salary|            1 | department  |
-- | large_employee_table|          1 | idx_dept_salary|            2 | salary      |
-- +---------------------+------------+----------------+--------------+-------------+

-- Query with index (faster)
SELECT * FROM large_employee_table WHERE department = 'IT' AND salary > 70000;

-- Expected Output:
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+
-- | id | first_name | last_name | email                  | department | salary | hire_date  | status |
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+
-- |  1 | John       | Smith     | john.smith@company.com | IT         |  75000 | 2020-01-15 | Active |
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+

-- Analyze query performance
EXPLAIN SELECT * FROM large_employee_table WHERE department = 'IT';

-- Expected Output:
-- +----+-------------+---------------------+------+----------------+----------------+
-- | id | select_type | table               | type | possible_keys  | key            |
-- +----+-------------+---------------------+------+----------------+----------------+
-- |  1 | SIMPLE      | large_employee_table| ref  | idx_department | idx_department |
-- +----+-------------+---------------------+------+----------------+----------------+

-- Drop index
DROP INDEX idx_department ON large_employee_table;

-- Create functional index (if supported)
CREATE INDEX idx_upper_lastname ON large_employee_table((UPPER(last_name)));

-- Query using functional index
SELECT * FROM large_employee_table WHERE UPPER(last_name) = 'SMITH';

-- Expected Output:
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+
-- | id | first_name | last_name | email                  | department | salary | hire_date  | status |
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+
-- |  1 | John       | Smith     | john.smith@company.com | IT         |  75000 | 2020-01-15 | Active |
-- +----+------------+-----------+------------------------+------------+--------+------------+--------+
```

---

## **Exercise 9: Transactions and Concurrency Control**
**Topic:** Managing transactions, ACID properties, isolation levels, and handling concurrent access.

### **Key Definitions for This Exercise:**
- **Transaction**: Sequence of database operations treated as single unit
- **ACID**: Atomicity, Consistency, Isolation, Durability
- **COMMIT**: Makes transaction changes permanent
- **ROLLBACK**: Undoes all changes in current transaction
- **SAVEPOINT**: Creates checkpoint within transaction

### What you need to know:
```sql
-- Create accounts table for transaction demo
CREATE TABLE bank_accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100),
    balance DECIMAL(12,2),
    account_type VARCHAR(20)
);

-- Insert sample data
INSERT INTO bank_accounts VALUES
(1001, 'John Smith', 5000.00, 'Savings'),
(1002, 'Jane Doe', 3000.00, 'Checking'),
(1003, 'Mike Johnson', 7500.00, 'Savings');

-- Basic Transaction Example
START TRANSACTION;

-- Check initial balances
SELECT account_id, account_holder, balance FROM bank_accounts;

-- Expected Output:
-- +------------+---------------+---------+
-- | account_id | account_holder| balance |
-- +------------+---------------+---------+
-- |       1001 | John Smith    | 5000.00 |
-- |       1002 | Jane Doe      | 3000.00 |
-- |       1003 | Mike Johnson  | 7500.00 |
-- +------------+---------------+---------+

-- Transfer money from John to Jane
UPDATE bank_accounts SET balance = balance - 500 WHERE account_id = 1001;
UPDATE bank_accounts SET balance = balance + 500 WHERE account_id = 1002;

-- Check balances before commit
SELECT account_id, account_holder, balance FROM bank_accounts;

-- Expected Output:
-- +------------+---------------+---------+
-- | account_id | account_holder| balance |
-- +------------+---------------+---------+
-- |       1001 | John Smith    | 4500.00 |
-- |       1002 | Jane Doe      | 3500.00 |
-- |       1003 | Mike Johnson  | 7500.00 |
-- +------------+---------------+---------+

-- Commit the transaction
COMMIT;

-- Transaction with Rollback
START TRANSACTION;

-- Attempt invalid operation
UPDATE bank_accounts SET balance = balance - 6000 WHERE account_id = 1001;

-- Check if balance went negative
SELECT account_id, balance FROM bank_accounts WHERE account_id = 1001;

-- Expected Output:
-- +------------+---------+
-- | account_id | balance |
-- +------------+---------+
-- |       1001 | -1500.00|
-- +------------+---------+

-- Rollback because balance cannot be negative
ROLLBACK;

-- Check balance after rollback
SELECT account_id, balance FROM bank_accounts WHERE account_id = 1001;

-- Expected Output:
-- +------------+---------+
-- | account_id | balance |
-- +------------+---------+
-- |       1001 | 4500.00 |
-- +------------+---------+

-- Transaction with Savepoints
START TRANSACTION;

-- Create savepoint
SAVEPOINT sp1;

-- First operation
UPDATE bank_accounts SET balance = balance - 200 WHERE account_id = 1001;

-- Create another savepoint
SAVEPOINT sp2;

-- Second operation
UPDATE bank_accounts SET balance = balance - 300 WHERE account_id = 1001;

-- Check current balance
SELECT balance FROM bank_accounts WHERE account_id = 1001;

-- Expected Output:
-- +---------+
-- | balance |
-- +---------+
-- | 4000.00 |
-- +---------+

-- Rollback to savepoint sp2
ROLLBACK TO SAVEPOINT sp2;

-- Check balance (should be 4300.00)
SELECT balance FROM bank_accounts WHERE account_id = 1001;

-- Expected Output:
-- +---------+
-- | balance |
-- +---------+
-- | 4300.00 |
-- +---------+

-- Commit the transaction
COMMIT;

-- Complex Transaction with Error Handling
DELIMITER //
CREATE PROCEDURE transfer_money(
    IN from_account INT,
    IN to_account INT,
    IN amount DECIMAL(10,2)
)
BEGIN
    DECLARE insufficient_funds CONDITION FOR SQLSTATE '45000';
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Check if sufficient funds
    IF (SELECT balance FROM bank_accounts WHERE account_id = from_account) < amount THEN
        SIGNAL insufficient_funds SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;
    
    -- Perform transfer
    UPDATE bank_accounts SET balance = balance - amount WHERE account_id = from_account;
    UPDATE bank_accounts SET balance = balance + amount WHERE account_id = to_account;
    
    COMMIT;
    
    SELECT 'Transfer completed successfully' as message;
END //
DELIMITER ;

-- Test successful transfer
CALL transfer_money(1001, 1002, 100);

-- Expected Output:
-- +------------------------------+
-- | message                      |
-- +------------------------------+
-- | Transfer completed successfully |
-- +------------------------------+

-- Test failed transfer (insufficient funds)
CALL transfer_money(1001, 1002, 10000);

-- Expected Output:
-- ERROR 1644 (45000): Insufficient funds
```

---

## **Exercise 10: Advanced Database Objects and Administration**
**Topic:** Creating and managing stored procedures, functions, user-defined data types, and database administration tasks.

### **Key Definitions for This Exercise:**
- **Stored Procedure**: Precompiled SQL code that can be reused
- **Function**: Returns a single value and can be used in expressions
- **User-Defined Function**: Custom function created by user
- **Database Administration**: Managing users, permissions, backup/restore

### What you need to know:
```sql
-- Create User-Defined Function
DELIMITER //
CREATE FUNCTION calculate_bonus(salary DECIMAL(10,2), years_service INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE bonus DECIMAL(10,2);
    
    IF years_service >= 10 THEN
        SET bonus = salary * 0.15;
    ELSEIF years_service >= 5 THEN
        SET bonus = salary * 0.10;
    ELSEIF years_service >= 2 THEN
        SET bonus = salary * 0.05;
    ELSE
        SET bonus = 0;
    END IF;
    
    RETURN bonus;
END //
DELIMITER ;

-- Use the function
SELECT 
    first_name,
    last_name,
    salary,
    YEAR(CURDATE()) - YEAR(hire_date) as years_service,
    calculate_bonus(salary, YEAR(CURDATE()) - YEAR(hire_date)) as bonus
FROM employees;

-- Expected Output:
-- +------------+-----------+--------+---------------+---------+
-- | first_name | last_name | salary | years_service | bonus   |
-- +------------+-----------+--------+---------------+---------+
-- | John       | Smith     |  75000 |             4 |    0.00 |
-- | Jane       | Doe       |  65000 |             4 |    0.00 |
-- | Mike       | Johnson   |  80000 |             5 | 8000.00 |
-- | Sarah      | Wilson    |  70000 |             3 | 3500.00 |
-- +------------+-----------+--------+---------------+---------+

-- Create Complex Stored Procedure
DELIMITER //
CREATE PROCEDURE generate_payroll_report(IN dept_name VARCHAR(50))
BEGIN
    DECLARE total_salary DECIMAL(15,2) DEFAULT 0;
    DECLARE total_bonus DECIMAL(15,2) DEFAULT 0;
    DECLARE emp_count INT DEFAULT 0;
    
    -- Create temporary table for report
    CREATE TEMPORARY TABLE payroll_temp (
        employee_name VARCHAR(100),
        department VARCHAR(50),
        base_salary DECIMAL(10,2),
        bonus DECIMAL(10,2),
        total_pay DECIMAL(10,2)
    );
    
    -- Insert data into temporary table
    INSERT INTO payroll_temp
    SELECT 
        CONCAT(first_name, ' ', last_name) as employee_name,
        department,
        salary as base_salary,
        calculate_bonus(salary, YEAR(CURDATE()) - YEAR(hire_date)) as bonus,
        salary + calculate_bonus(salary, YEAR(CURDATE()) - YEAR(hire_date)) as total_pay
    FROM employees
    WHERE department = dept_name OR dept_name IS NULL;
    
    -- Get summary statistics
    SELECT 
        COUNT(*) INTO emp_count,
        SUM(base_salary) INTO total_salary,
        SUM(bonus) INTO total_bonus
    FROM payroll_temp;
    
    -- Display detailed report
    SELECT * FROM payroll_temp ORDER BY total_pay DESC;
    
    -- Display summary
    SELECT 
        emp_count as 'Total Employees',
        total_salary as 'Total Base Salary',
        total_bonus as 'Total Bonus',
        (total_salary + total_bonus) as 'Total Payroll'
    FROM DUAL;
    
    -- Clean up
    DROP TEMPORARY TABLE payroll_temp;
END //
DELIMITER ;

-- Generate report for IT department
CALL generate_payroll_report('IT');

-- Expected Output (Detailed Report):
-- +---------------+------------+-------------+--------+-----------+
-- | employee_name | department | base_salary | bonus  | total_pay |
-- +---------------+------------+-------------+--------+-----------+
-- | John Smith    | IT         |    75000.00 |   0.00 |  75000.00 |
-- | Sarah Wilson  | IT         |    70000.00 |3500.00 |  73500.00 |
-- +---------------+------------+-------------+--------+-----------+

-- Expected Output (Summary):
-- +-----------------+-------------------+-------------+---------------+
-- | Total Employees | Total Base Salary | Total Bonus | Total Payroll |
-- +-----------------+-------------------+-------------+---------------+
-- |               2 |         145000.00 |     3500.00 |     148500.00 |
-- +-----------------+-------------------+-------------+---------------+

-- Database Administration Tasks
-- Create new user
CREATE USER 'hr_user'@'localhost' IDENTIFIED BY 'hr_password';

-- Grant specific permissions
GRANT SELECT, INSERT, UPDATE ON employees TO 'hr_user'@'localhost';
GRANT SELECT ON departments TO 'hr_user'@'localhost';

-- Show user privileges
SHOW GRANTS FOR 'hr_user'@'localhost';

-- Expected Output:
-- +-------------------------------------------------------------------------+
-- | Grants for hr_user@localhost                                           |
-- +-------------------------------------------------------------------------+
-- | GRANT USAGE ON *.* TO `hr_user`@`localhost`                           |
-- | GRANT SELECT, INSERT, UPDATE ON `company`.`employees` TO `hr_user`@`localhost` |
-- | GRANT SELECT ON `company`.`departments` TO `hr_user`@`localhost`      |
-- +-------------------------------------------------------------------------+

-- Create backup procedure
DELIMITER //
CREATE PROCEDURE backup_employee_data()
BEGIN
    DECLARE backup_date VARCHAR(20);
    SET backup_date = DATE_FORMAT(NOW(), '%Y%m%d_%H%i%s');
    
    -- Create backup table
    SET @sql = CONCAT('CREATE TABLE employees_backup_', backup_date, ' AS SELECT * FROM employees');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    SELECT CONCAT('Backup created: employees_backup_', backup_date) as message;
END //
DELIMITER ;

-- Run backup
CALL backup_employee_data();

-- Expected Output:
-- +----------------------------------------+
-- | message                                |
-- +----------------------------------------+
-- | Backup created: employees_backup_20240115_143022 |
-- +----------------------------------------+

-- Show all procedures and functions
SHOW PROCEDURE STATUS WHERE Db = DATABASE();
SHOW FUNCTION STATUS WHERE Db = DATABASE();

-- Expected Output:
-- +----------+------------------------+-------+----------------+---------------------+
-- | Db       | Name                   | Type  | Definer        | Modified            |
-- +----------+------------------------+-------+----------------+---------------------+
-- | company  | generate_payroll_report| PROCEDURE | root@localhost | 2024-01-15 14:30:22 |
-- | company  | backup_employee_data   | PROCEDURE | root@localhost | 2024-01-15 14:35:10 |
-- | company  | calculate_bonus        | FUNCTION  | root@localhost | 2024-01-15 14:25:15 |
-- +----------+------------------------+-------+----------------+---------------------+

-- Database maintenance
ANALYZE TABLE employees;
OPTIMIZE TABLE employees;
CHECK TABLE employees;

-- Expected Output for CHECK TABLE:
-- +-------------------+-------+----------+----------+
-- | Table             | Op    | Msg_type | Msg_text |
-- +-------------------+-------+----------+----------+
-- | company.employees | check | status   | OK       |
-- +-------------------+-------+----------+----------+
```

--- 