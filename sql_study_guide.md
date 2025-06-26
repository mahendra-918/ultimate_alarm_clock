# Complete SQL Study Guide for Your Exam

## Table of Contents
1. [SQL Basics](#sql-basics)
2. [Data Types](#data-types)
3. [Basic Queries](#basic-queries)
4. [Filtering Data](#filtering-data)
5. [Sorting and Grouping](#sorting-and-grouping)
6. [Joins](#joins)
7. [Functions](#functions)
8. [Subqueries](#subqueries)
9. [Data Modification](#data-modification)
10. [Database Design](#database-design)
11. [Advanced Topics](#advanced-topics)
12. [Common Exam Questions](#common-exam-questions)

---

## SQL Basics

### What is SQL?
- **SQL** = Structured Query Language
- Used to communicate with databases
- Standard language for relational database management systems (RDBMS)

### Key Database Concepts
- **Database**: Collection of related tables
- **Table**: Collection of rows and columns (like a spreadsheet)
- **Row/Record**: Individual entry in a table
- **Column/Field**: Attribute of the data
- **Primary Key**: Unique identifier for each row
- **Foreign Key**: Links to primary key in another table

---

## Data Types

### Common SQL Data Types
```sql
-- Numeric Types
INT, INTEGER          -- Whole numbers
DECIMAL(p,s)         -- Fixed-point numbers
FLOAT, REAL          -- Floating-point numbers

-- String Types
VARCHAR(n)           -- Variable-length string
CHAR(n)             -- Fixed-length string
TEXT                -- Large text

-- Date/Time Types
DATE                -- Date (YYYY-MM-DD)
TIME                -- Time (HH:MM:SS)
DATETIME, TIMESTAMP -- Date and time

-- Boolean
BOOLEAN             -- TRUE/FALSE
```

---

## Basic Queries

### SELECT Statement
```sql
-- Basic syntax
SELECT column1, column2
FROM table_name;

-- Select all columns
SELECT * FROM employees;

-- Select specific columns
SELECT first_name, last_name, salary
FROM employees;

-- Using aliases
SELECT first_name AS "First Name", 
       last_name AS "Last Name"
FROM employees;
```

### DISTINCT
```sql
-- Remove duplicates
SELECT DISTINCT department
FROM employees;
```

---

## Filtering Data

### WHERE Clause
```sql
-- Basic filtering
SELECT * FROM employees
WHERE salary > 50000;

-- Multiple conditions
SELECT * FROM employees
WHERE salary > 50000 AND department = 'IT';

SELECT * FROM employees
WHERE department = 'HR' OR department = 'Finance';
```

### Comparison Operators
```sql
=    -- Equal
<>   -- Not equal (also !=)
>    -- Greater than
<    -- Less than
>=   -- Greater than or equal
<=   -- Less than or equal
```

### Pattern Matching with LIKE
```sql
-- Wildcards
% -- Represents zero or more characters
_ -- Represents exactly one character

-- Examples
SELECT * FROM employees
WHERE first_name LIKE 'J%';        -- Names starting with 'J'

SELECT * FROM employees
WHERE first_name LIKE '%son';      -- Names ending with 'son'

SELECT * FROM employees
WHERE first_name LIKE 'J_hn';      -- John, Jahn, etc.
```

### IN and BETWEEN
```sql
-- IN operator
SELECT * FROM employees
WHERE department IN ('HR', 'IT', 'Finance');

-- BETWEEN operator
SELECT * FROM employees
WHERE salary BETWEEN 40000 AND 60000;

-- NOT operator
SELECT * FROM employees
WHERE department NOT IN ('HR', 'IT');
```

### NULL Values
```sql
-- Check for NULL values
SELECT * FROM employees
WHERE phone IS NULL;

SELECT * FROM employees
WHERE phone IS NOT NULL;
```

---

## Sorting and Grouping

### ORDER BY
```sql
-- Sort ascending (default)
SELECT * FROM employees
ORDER BY salary;

-- Sort descending
SELECT * FROM employees
ORDER BY salary DESC;

-- Multiple columns
SELECT * FROM employees
ORDER BY department, salary DESC;
```

### GROUP BY
```sql
-- Group data
SELECT department, COUNT(*)
FROM employees
GROUP BY department;

-- Average salary by department
SELECT department, AVG(salary) as avg_salary
FROM employees
GROUP BY department;
```

### HAVING
```sql
-- Filter groups (use HAVING instead of WHERE with GROUP BY)
SELECT department, COUNT(*) as employee_count
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;
```

---

## Joins

### Types of Joins

#### INNER JOIN
```sql
-- Returns only matching records from both tables
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;
```

#### LEFT JOIN (LEFT OUTER JOIN)
```sql
-- Returns all records from left table, matching from right
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id;
```

#### RIGHT JOIN (RIGHT OUTER JOIN)
```sql
-- Returns all records from right table, matching from left
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
RIGHT JOIN departments d ON e.department_id = d.department_id;
```

#### FULL OUTER JOIN
```sql
-- Returns all records when there's a match in either table
SELECT e.first_name, e.last_name, d.department_name
FROM employees e
FULL OUTER JOIN departments d ON e.department_id = d.department_id;
```

#### CROSS JOIN
```sql
-- Cartesian product of both tables
SELECT e.first_name, d.department_name
FROM employees e
CROSS JOIN departments d;
```

### Self Join
```sql
-- Join a table with itself
SELECT e1.first_name as Employee, e2.first_name as Manager
FROM employees e1
INNER JOIN employees e2 ON e1.manager_id = e2.employee_id;
```

---

## Functions

### Aggregate Functions
```sql
COUNT(*)         -- Count all rows
COUNT(column)    -- Count non-NULL values
SUM(column)      -- Sum of values
AVG(column)      -- Average of values
MIN(column)      -- Minimum value
MAX(column)      -- Maximum value

-- Examples
SELECT COUNT(*) FROM employees;
SELECT AVG(salary) FROM employees;
SELECT MAX(salary), MIN(salary) FROM employees;
```

### String Functions
```sql
UPPER(string)           -- Convert to uppercase
LOWER(string)           -- Convert to lowercase
LENGTH(string)          -- Length of string
SUBSTRING(string, start, length)  -- Extract substring
CONCAT(string1, string2)          -- Concatenate strings
TRIM(string)            -- Remove leading/trailing spaces

-- Examples
SELECT UPPER(first_name), LOWER(last_name)
FROM employees;

SELECT CONCAT(first_name, ' ', last_name) as full_name
FROM employees;
```

### Date Functions
```sql
NOW()              -- Current date and time
CURDATE()          -- Current date
YEAR(date)         -- Extract year
MONTH(date)        -- Extract month
DAY(date)          -- Extract day
DATEDIFF(date1, date2)  -- Difference between dates

-- Examples
SELECT * FROM employees
WHERE YEAR(hire_date) = 2023;
```

### Mathematical Functions
```sql
ROUND(number, decimals)  -- Round number
CEIL(number)            -- Round up
FLOOR(number)           -- Round down
ABS(number)             -- Absolute value
MOD(number, divisor)    -- Modulo operation
```

---

## Subqueries

### Single-Value Subqueries
```sql
-- Find employees with salary higher than average
SELECT * FROM employees
WHERE salary > (SELECT AVG(salary) FROM employees);
```

### Multiple-Value Subqueries
```sql
-- Using IN with subquery
SELECT * FROM employees
WHERE department_id IN (
    SELECT department_id 
    FROM departments 
    WHERE location = 'New York'
);

-- Using EXISTS
SELECT * FROM employees e
WHERE EXISTS (
    SELECT 1 FROM departments d 
    WHERE d.department_id = e.department_id 
    AND d.location = 'New York'
);
```

### Correlated Subqueries
```sql
-- Find employees with salary higher than their department average
SELECT * FROM employees e1
WHERE salary > (
    SELECT AVG(salary) 
    FROM employees e2 
    WHERE e2.department_id = e1.department_id
);
```

---

## Data Modification

### INSERT
```sql
-- Insert single row
INSERT INTO employees (first_name, last_name, salary, department_id)
VALUES ('John', 'Doe', 50000, 1);

-- Insert multiple rows
INSERT INTO employees (first_name, last_name, salary, department_id)
VALUES 
    ('Jane', 'Smith', 55000, 2),
    ('Bob', 'Johnson', 48000, 1);

-- Insert from another table
INSERT INTO employees_backup
SELECT * FROM employees WHERE department_id = 1;
```

### UPDATE
```sql
-- Update single column
UPDATE employees
SET salary = 55000
WHERE employee_id = 1;

-- Update multiple columns
UPDATE employees
SET salary = salary * 1.1, last_modified = NOW()
WHERE department_id = 1;

-- Update with JOIN
UPDATE employees e
INNER JOIN departments d ON e.department_id = d.department_id
SET e.salary = e.salary * 1.05
WHERE d.department_name = 'IT';
```

### DELETE
```sql
-- Delete specific rows
DELETE FROM employees
WHERE employee_id = 1;

-- Delete with condition
DELETE FROM employees
WHERE salary < 30000;

-- Delete all rows (but keep table structure)
DELETE FROM employees;
```

---

## Database Design

### CREATE TABLE
```sql
CREATE TABLE employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);
```

### Constraints
```sql
PRIMARY KEY     -- Unique identifier
FOREIGN KEY     -- References another table
UNIQUE          -- Must be unique
NOT NULL        -- Cannot be empty
CHECK           -- Custom validation
DEFAULT         -- Default value

-- Example with constraints
CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) CHECK (price > 0),
    category_id INT DEFAULT 1,
    created_date DATE DEFAULT CURDATE()
);
```

### ALTER TABLE
```sql
-- Add column
ALTER TABLE employees
ADD COLUMN phone VARCHAR(15);

-- Modify column
ALTER TABLE employees
MODIFY COLUMN salary DECIMAL(12,2);

-- Drop column
ALTER TABLE employees
DROP COLUMN phone;

-- Add constraint
ALTER TABLE employees
ADD CONSTRAINT fk_department 
FOREIGN KEY (department_id) REFERENCES departments(department_id);
```

### DROP TABLE
```sql
DROP TABLE employees;
```

---

## Advanced Topics

### Views
```sql
-- Create view
CREATE VIEW employee_summary AS
SELECT e.first_name, e.last_name, d.department_name, e.salary
FROM employees e
INNER JOIN departments d ON e.department_id = d.department_id;

-- Use view
SELECT * FROM employee_summary
WHERE salary > 50000;

-- Drop view
DROP VIEW employee_summary;
```

### Indexes
```sql
-- Create index
CREATE INDEX idx_employee_salary ON employees(salary);

-- Create composite index
CREATE INDEX idx_name_dept ON employees(last_name, department_id);

-- Drop index
DROP INDEX idx_employee_salary;
```

### Window Functions (Advanced)
```sql
-- ROW_NUMBER
SELECT first_name, last_name, salary,
       ROW_NUMBER() OVER (ORDER BY salary DESC) as rank
FROM employees;

-- PARTITION BY
SELECT first_name, last_name, salary, department_id,
       AVG(salary) OVER (PARTITION BY department_id) as dept_avg
FROM employees;
```

### CASE Statements
```sql
-- Simple CASE
SELECT first_name, last_name,
       CASE 
           WHEN salary > 60000 THEN 'High'
           WHEN salary > 40000 THEN 'Medium'
           ELSE 'Low'
       END as salary_category
FROM employees;
```

---

## Common Exam Questions

### 1. Find the Nth highest salary
```sql
-- Second highest salary
SELECT MAX(salary) as second_highest
FROM employees
WHERE salary < (SELECT MAX(salary) FROM employees);

-- Using LIMIT (MySQL)
SELECT salary
FROM employees
ORDER BY salary DESC
LIMIT 1 OFFSET 1;
```

### 2. Find duplicate records
```sql
SELECT email, COUNT(*)
FROM employees
GROUP BY email
HAVING COUNT(*) > 1;
```

### 3. Find employees without departments
```sql
SELECT e.*
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
WHERE d.department_id IS NULL;
```

### 4. Rank employees by salary within department
```sql
SELECT first_name, last_name, department_id, salary,
       RANK() OVER (PARTITION BY department_id ORDER BY salary DESC) as dept_rank
FROM employees;
```

### 5. Find department with highest average salary
```sql
SELECT department_id, AVG(salary) as avg_salary
FROM employees
GROUP BY department_id
ORDER BY avg_salary DESC
LIMIT 1;
```

---

## Quick Reference - SQL Order of Execution

```sql
SELECT column_list      -- 5. Select specific columns
FROM table_name         -- 1. Get data from table
WHERE condition         -- 2. Filter rows
GROUP BY column_list    -- 3. Group rows
HAVING condition        -- 4. Filter groups
ORDER BY column_list    -- 6. Sort results
LIMIT number           -- 7. Limit results
```

---

## Tips for Your Exam

1. **Practice writing queries by hand** - Many exams are written
2. **Understand JOIN types** - Very commonly tested
3. **Know aggregate functions** - COUNT, SUM, AVG, MIN, MAX
4. **Understand GROUP BY vs WHERE vs HAVING**
5. **Practice subqueries** - Both correlated and non-correlated
6. **Know the difference between UNION and UNION ALL**
7. **Understand NULL handling** - IS NULL, IS NOT NULL
8. **Practice with sample data** - Create your own examples

## Common Mistakes to Avoid

1. Using WHERE instead of HAVING with GROUP BY
2. Forgetting to handle NULL values
3. Mixing aggregate and non-aggregate columns without GROUP BY
4. Using = NULL instead of IS NULL
5. Forgetting table aliases in complex JOINs
6. Not understanding the difference between INNER and OUTER JOINs

Good luck with your exam! 🍀 