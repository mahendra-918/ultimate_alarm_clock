# Complete SQL Definitions Guide for DBMS Lab Exam

## **Database Fundamentals**

### **Database**
A structured collection of related data stored electronically in a computer system. It organizes data into tables, rows, and columns for efficient storage, retrieval, and management.

### **Database Management System (DBMS)**
Software that provides an interface between users and databases. It manages data storage, retrieval, security, and integrity. Examples: MySQL, PostgreSQL, Oracle, SQL Server.

### **Relational Database**
A database that stores data in tables (relations) with rows and columns. Tables are related through common fields called keys.

### **SQL (Structured Query Language)**
A standardized programming language designed for managing and manipulating relational databases. It includes commands for querying, updating, and managing database structures.

---

## **Database Structure Components**

### **Table (Relation)**
A collection of related data organized in rows and columns. Each table represents an entity (like Students, Employees, Products).

### **Row (Record/Tuple)**
A single entry in a table containing data for one instance of the entity. For example, one student's complete information.

### **Column (Field/Attribute)**
A vertical element in a table that contains all values for a specific data type. For example, all student names in a "name" column.

### **Schema**
The logical structure of a database, including table definitions, relationships, constraints, and other database objects.

### **Instance**
The actual data stored in a database at a particular moment in time.

---

## **Keys and Relationships**

### **Primary Key**
A column or combination of columns that uniquely identifies each row in a table. Cannot contain NULL values and must be unique.
```sql
CREATE TABLE students (
    student_id INT PRIMARY KEY,  -- Primary key
    name VARCHAR(50)
);
```

### **Foreign Key**
A column that creates a link between two tables by referencing the primary key of another table. Ensures referential integrity.
```sql
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    FOREIGN KEY (student_id) REFERENCES students(student_id)
);
```

### **Composite Key**
A primary key consisting of multiple columns combined to uniquely identify a row.
```sql
CREATE TABLE enrollments (
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id, semester)
);
```

### **Candidate Key**
A column or set of columns that could serve as a primary key (unique and not null).

### **Super Key**
Any combination of columns that can uniquely identify a row in a table.

---

## **Constraints**

### **NOT NULL Constraint**
Ensures that a column cannot have empty (NULL) values.
```sql
CREATE TABLE students (
    name VARCHAR(50) NOT NULL  -- Cannot be empty
);
```

### **UNIQUE Constraint**
Ensures all values in a column are different (no duplicates allowed).
```sql
CREATE TABLE students (
    email VARCHAR(100) UNIQUE  -- No duplicate emails
);
```

### **CHECK Constraint**
Ensures that values in a column meet a specific condition.
```sql
CREATE TABLE students (
    age INT CHECK (age >= 18),  -- Age must be 18 or more
    gpa DECIMAL(3,2) CHECK (gpa >= 0.0 AND gpa <= 4.0)
);
```

### **DEFAULT Constraint**
Provides a default value for a column when no value is specified.
```sql
CREATE TABLE students (
    status VARCHAR(20) DEFAULT 'Active',  -- Default value
    admission_date DATE DEFAULT CURDATE()
);
```

### **Referential Integrity**
Ensures that foreign key values match primary key values in the referenced table, maintaining consistency between related tables.

---

## **SQL Command Categories**

### **DDL (Data Definition Language)**
Commands that define database structure:
- **CREATE**: Creates database objects (tables, indexes, views)
- **ALTER**: Modifies existing database objects
- **DROP**: Deletes database objects
- **TRUNCATE**: Removes all data from a table but keeps structure

### **DML (Data Manipulation Language)**
Commands that manipulate data:
- **SELECT**: Retrieves data from tables
- **INSERT**: Adds new data to tables
- **UPDATE**: Modifies existing data
- **DELETE**: Removes data from tables

### **DCL (Data Control Language)**
Commands that control access:
- **GRANT**: Gives permissions to users
- **REVOKE**: Removes permissions from users

### **TCL (Transaction Control Language)**
Commands that manage transactions:
- **COMMIT**: Saves changes permanently
- **ROLLBACK**: Undoes changes
- **SAVEPOINT**: Creates a point to rollback to

---

## **Query Operations**

### **SELECT Statement**
The primary command for retrieving data from one or more tables.
```sql
SELECT column1, column2 FROM table_name WHERE condition;
```

### **WHERE Clause**
Filters rows based on specified conditions.
```sql
SELECT * FROM students WHERE age > 20;
```

### **ORDER BY Clause**
Sorts the result set by one or more columns.
```sql
SELECT * FROM students ORDER BY name ASC, age DESC;
```

### **GROUP BY Clause**
Groups rows that have the same values in specified columns, often used with aggregate functions.
```sql
SELECT department, COUNT(*) FROM students GROUP BY department;
```

### **HAVING Clause**
Filters groups created by GROUP BY (similar to WHERE but for groups).
```sql
SELECT department, COUNT(*) FROM students 
GROUP BY department HAVING COUNT(*) > 5;
```

---

## **Join Operations**

### **JOIN**
Combines rows from two or more tables based on a related column.

### **INNER JOIN**
Returns only rows that have matching values in both tables.
```sql
SELECT s.name, d.dept_name 
FROM students s INNER JOIN departments d ON s.dept_id = d.dept_id;
```

### **LEFT JOIN (LEFT OUTER JOIN)**
Returns all rows from the left table and matching rows from the right table.
```sql
SELECT s.name, d.dept_name 
FROM students s LEFT JOIN departments d ON s.dept_id = d.dept_id;
```

### **RIGHT JOIN (RIGHT OUTER JOIN)**
Returns all rows from the right table and matching rows from the left table.

### **FULL OUTER JOIN**
Returns all rows when there's a match in either table.

### **CROSS JOIN**
Returns the Cartesian product of both tables (all possible combinations).

### **SELF JOIN**
Joins a table with itself to compare rows within the same table.

---

## **Subqueries**

### **Subquery (Nested Query)**
A query nested inside another query, used to provide data for the main query.
```sql
SELECT * FROM students WHERE dept_id IN (SELECT dept_id FROM departments WHERE location = 'Building A');
```

### **Correlated Subquery**
A subquery that references columns from the outer query and is executed once for each row.
```sql
SELECT * FROM employees e1 WHERE salary > (SELECT AVG(salary) FROM employees e2 WHERE e2.dept_id = e1.dept_id);
```

### **Scalar Subquery**
A subquery that returns a single value.

### **Row Subquery**
A subquery that returns a single row with multiple columns.

### **Table Subquery**
A subquery that returns multiple rows and columns.

---

## **Set Operations**

### **UNION**
Combines results from two SELECT statements, removing duplicates.
```sql
SELECT name FROM students UNION SELECT name FROM teachers;
```

### **UNION ALL**
Combines results from two SELECT statements, including duplicates.

### **INTERSECT**
Returns rows that appear in both result sets (not supported in MySQL, use INNER JOIN).

### **EXCEPT/MINUS**
Returns rows from the first result set that don't appear in the second.

---

## **Aggregate Functions**

### **COUNT()**
Returns the number of rows or non-NULL values.
```sql
SELECT COUNT(*) FROM students;  -- Total rows
SELECT COUNT(email) FROM students;  -- Non-NULL emails
```

### **SUM()**
Returns the sum of numeric values.
```sql
SELECT SUM(salary) FROM employees;
```

### **AVG()**
Returns the average of numeric values.
```sql
SELECT AVG(gpa) FROM students;
```

### **MAX()**
Returns the maximum value.
```sql
SELECT MAX(salary) FROM employees;
```

### **MIN()**
Returns the minimum value.
```sql
SELECT MIN(age) FROM students;
```

---

## **String Functions**

### **CONCAT()**
Combines two or more strings.
```sql
SELECT CONCAT(first_name, ' ', last_name) AS full_name FROM students;
```

### **UPPER()**
Converts string to uppercase.
```sql
SELECT UPPER(name) FROM students;
```

### **LOWER()**
Converts string to lowercase.

### **LENGTH()**
Returns the length of a string.

### **SUBSTRING()**
Extracts part of a string.
```sql
SELECT SUBSTRING(name, 1, 3) FROM students;  -- First 3 characters
```

### **TRIM()**
Removes leading and trailing spaces.

### **LIKE Operator**
Used for pattern matching with wildcards:
- **%**: Represents zero or more characters
- **_**: Represents exactly one character

---

## **Date Functions**

### **NOW()**
Returns current date and time.

### **CURDATE()**
Returns current date.

### **YEAR(), MONTH(), DAY()**
Extract specific parts from a date.

### **DATEDIFF()**
Returns difference between two dates.
```sql
SELECT DATEDIFF(NOW(), hire_date) AS days_employed FROM employees;
```

---

## **Advanced Concepts**

### **View**
A virtual table based on a SELECT statement. Doesn't store data physically.
```sql
CREATE VIEW active_students AS 
SELECT * FROM students WHERE status = 'Active';
```

### **Index**
A database object that improves query performance by creating shortcuts to data.
```sql
CREATE INDEX idx_student_name ON students(name);
```

### **Stored Procedure**
A prepared SQL code that can be saved and reused.

### **Function**
A reusable piece of code that returns a value.

### **Trigger**
Special stored procedure that automatically executes in response to database events.

---

## **PL/SQL Concepts**

### **PL/SQL Block Structure**
```sql
DECLARE
    -- Variable declarations
BEGIN
    -- Executable statements
EXCEPTION
    -- Error handling
END;
```

### **Variables**
Storage locations with names that hold data.
```sql
DECLARE
    emp_name VARCHAR(50);
    emp_count INT DEFAULT 0;
```

### **Control Structures**

#### **IF-THEN-ELSE**
```sql
IF condition THEN
    statements;
ELSIF condition THEN
    statements;
ELSE
    statements;
END IF;
```

#### **WHILE Loop**
```sql
WHILE condition DO
    statements;
END WHILE;
```

#### **FOR Loop**
```sql
FOR counter IN start_value..end_value DO
    statements;
END FOR;
```

### **Exception Handling**
```sql
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Handle no data found
    WHEN OTHERS THEN
        -- Handle all other errors
```

---

## **Database Design Concepts**

### **Normalization**
Process of organizing data to reduce redundancy and improve data integrity.

### **First Normal Form (1NF)**
Each column contains atomic (indivisible) values, and each row is unique.

### **Second Normal Form (2NF)**
Meets 1NF and all non-key columns are fully dependent on the primary key.

### **Third Normal Form (3NF)**
Meets 2NF and no transitive dependencies exist.

### **Entity-Relationship (ER) Model**
A conceptual model that describes entities, attributes, and relationships in a database.

### **Cardinality**
Describes the relationship between entities:
- **One-to-One (1:1)**
- **One-to-Many (1:M)**
- **Many-to-Many (M:N)**

---

## **Transaction Concepts**

### **Transaction**
A sequence of database operations that are treated as a single unit of work.

### **ACID Properties**
- **Atomicity**: All operations succeed or all fail
- **Consistency**: Database remains in valid state
- **Isolation**: Concurrent transactions don't interfere
- **Durability**: Committed changes persist

### **Commit**
Makes transaction changes permanent.

### **Rollback**
Undoes all changes made in the current transaction.

---

## **Query Optimization Terms**

### **Query Execution Plan**
Shows how the database engine will execute a query.

### **Index Scan**
Reading data using an index.

### **Table Scan**
Reading all rows in a table sequentially.

### **Cost-Based Optimization**
Database chooses execution plan based on estimated cost.

---

## **Common SQL Operators**

### **Comparison Operators**
- **=**: Equal
- **<>** or **!=**: Not equal
- **>**: Greater than
- **<**: Less than
- **>=**: Greater than or equal
- **<=**: Less than or equal

### **Logical Operators**
- **AND**: Both conditions must be true
- **OR**: Either condition can be true
- **NOT**: Negates a condition

### **Special Operators**
- **IN**: Value matches any in a list
- **BETWEEN**: Value is within a range
- **IS NULL**: Value is NULL
- **IS NOT NULL**: Value is not NULL
- **EXISTS**: Subquery returns at least one row
- **ANY**: Condition is true for any value
- **ALL**: Condition is true for all values

---

## **Quick Reference - Order of SQL Execution**

1. **FROM** - Specify tables
2. **WHERE** - Filter rows
3. **GROUP BY** - Group rows
4. **HAVING** - Filter groups
5. **SELECT** - Choose columns
6. **ORDER BY** - Sort results
7. **LIMIT** - Limit number of rows

---

This comprehensive definitions guide covers all the essential SQL and database concepts you need to know for your DBMS lab exam. Study these definitions alongside the practical examples in your other guides! 