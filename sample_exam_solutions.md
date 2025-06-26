# Sample DBMS Lab Exam Solutions (1-2 Pages Each)

## **Sample Solution 1: Table Operations & Constraints**
**Question:** Create a comprehensive database for a University Management System. Create tables with appropriate constraints, insert sample data, and demonstrate various SELECT operations.

### **Solution:**

#### **Step 1: Create Database and Tables**

```sql
-- Create Database
CREATE DATABASE university_management;
USE university_management;

-- Create Departments Table
CREATE TABLE departments (
    dept_id INT PRIMARY KEY AUTO_INCREMENT,
    dept_name VARCHAR(50) NOT NULL UNIQUE,
    dept_head VARCHAR(50),
    budget DECIMAL(12,2) CHECK (budget > 0),
    established_year INT CHECK (established_year > 1800),
    location VARCHAR(100) DEFAULT 'Main Campus'
);

-- Create Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
    last_name VARCHAR(30) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    date_of_birth DATE,
    admission_date DATE DEFAULT (CURDATE()),
    gpa DECIMAL(3,2) CHECK (gpa >= 0.0 AND gpa <= 4.0),
    dept_id INT,
    status ENUM('Active', 'Inactive', 'Graduated') DEFAULT 'Active',
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE SET NULL,
    CONSTRAINT chk_age CHECK (DATEDIFF(CURDATE(), date_of_birth) >= 6570) -- At least 18 years
);

-- Create Courses Table
CREATE TABLE courses (
    course_id VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INT CHECK (credits > 0 AND credits <= 6),
    dept_id INT NOT NULL,
    prerequisite VARCHAR(10),
    max_enrollment INT DEFAULT 50,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE CASCADE,
    FOREIGN KEY (prerequisite) REFERENCES courses(course_id) ON DELETE SET NULL
);

-- Create Enrollments Table
CREATE TABLE enrollments (
    enrollment_id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id VARCHAR(10),
    semester VARCHAR(20),
    year INT,
    grade CHAR(2) CHECK (grade IN ('A+', 'A', 'B+', 'B', 'C+', 'C', 'D', 'F')),
    enrollment_date DATE DEFAULT (CURDATE()),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE CASCADE,
    UNIQUE KEY unique_enrollment (student_id, course_id, semester, year)
);
```

#### **Step 2: Insert Sample Data**

```sql
-- Insert Departments
INSERT INTO departments (dept_name, dept_head, budget, established_year, location) VALUES
('Computer Science', 'Dr. Smith', 500000.00, 1985, 'Engineering Building'),
('Mathematics', 'Dr. Johnson', 300000.00, 1970, 'Science Building'),
('Physics', 'Dr. Brown', 450000.00, 1975, 'Science Building'),
('Business Administration', 'Dr. Davis', 600000.00, 1980, 'Business Building');

-- Insert Students
INSERT INTO students (first_name, last_name, email, phone, date_of_birth, gpa, dept_id) VALUES
('John', 'Doe', 'john.doe@university.edu', '123-456-7890', '2002-05-15', 3.75, 1),
('Jane', 'Smith', 'jane.smith@university.edu', '123-456-7891', '2001-08-22', 3.90, 1),
('Mike', 'Johnson', 'mike.johnson@university.edu', '123-456-7892', '2002-03-10', 3.25, 2),
('Sarah', 'Wilson', 'sarah.wilson@university.edu', '123-456-7893', '2001-11-05', 3.60, 3),
('Tom', 'Brown', 'tom.brown@university.edu', '123-456-7894', '2002-07-18', 2.85, 4);

-- Insert Courses
INSERT INTO courses (course_id, course_name, credits, dept_id, max_enrollment) VALUES
('CS101', 'Introduction to Programming', 3, 1, 40),
('CS201', 'Data Structures', 4, 1, 35),
('CS301', 'Database Systems', 3, 1, 30),
('MATH101', 'Calculus I', 4, 2, 50),
('MATH201', 'Linear Algebra', 3, 2, 35),
('PHYS101', 'General Physics', 4, 3, 45),
('BUS101', 'Business Fundamentals', 3, 4, 60);

-- Add prerequisite
UPDATE courses SET prerequisite = 'CS101' WHERE course_id = 'CS201';
UPDATE courses SET prerequisite = 'CS201' WHERE course_id = 'CS301';

-- Insert Enrollments
INSERT INTO enrollments (student_id, course_id, semester, year, grade) VALUES
(1, 'CS101', 'Fall', 2023, 'A'),
(1, 'MATH101', 'Fall', 2023, 'B+'),
(2, 'CS101', 'Fall', 2023, 'A+'),
(2, 'CS201', 'Spring', 2024, 'A'),
(3, 'MATH101', 'Fall', 2023, 'B'),
(3, 'MATH201', 'Spring', 2024, 'B+'),
(4, 'PHYS101', 'Fall', 2023, 'A-'),
(5, 'BUS101', 'Fall', 2023, 'C+');
```

#### **Step 3: Demonstrate ALTER TABLE Operations**

```sql
-- Add new column to students table
ALTER TABLE students ADD COLUMN middle_name VARCHAR(30) AFTER first_name;

-- Modify existing column
ALTER TABLE students MODIFY COLUMN phone VARCHAR(20);

-- Add new constraint
ALTER TABLE students ADD CONSTRAINT chk_gpa_range 
CHECK (gpa IS NULL OR (gpa >= 0.0 AND gpa <= 4.0));

-- Drop a column
ALTER TABLE students DROP COLUMN middle_name;

-- Add index for better performance
CREATE INDEX idx_student_email ON students(email);
CREATE INDEX idx_enrollment_semester ON enrollments(semester, year);
```

#### **Step 4: Complex SELECT Queries**

```sql
-- 1. Basic SELECT with WHERE
SELECT first_name, last_name, gpa 
FROM students 
WHERE gpa > 3.5 
ORDER BY gpa DESC;

-- 2. JOIN operations
SELECT s.first_name, s.last_name, d.dept_name, s.gpa
FROM students s
INNER JOIN departments d ON s.dept_id = d.dept_id
WHERE s.status = 'Active';

-- 3. Complex query with multiple JOINs
SELECT s.first_name, s.last_name, c.course_name, e.grade, e.semester, e.year
FROM students s
INNER JOIN enrollments e ON s.student_id = e.student_id
INNER JOIN courses c ON e.course_id = c.course_id
WHERE e.grade IN ('A+', 'A', 'A-')
ORDER BY s.last_name, e.year DESC, e.semester;

-- 4. Aggregate functions with GROUP BY
SELECT d.dept_name, 
       COUNT(s.student_id) as total_students,
       AVG(s.gpa) as average_gpa,
       MAX(s.gpa) as highest_gpa,
       MIN(s.gpa) as lowest_gpa
FROM departments d
LEFT JOIN students s ON d.dept_id = s.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING COUNT(s.student_id) > 0;

-- 5. Subquery example
SELECT first_name, last_name, gpa
FROM students
WHERE gpa > (SELECT AVG(gpa) FROM students WHERE gpa IS NOT NULL)
ORDER BY gpa DESC;
```

#### **Step 5: Demonstrate Constraints in Action**

```sql
-- These will FAIL due to constraints:

-- 1. Duplicate email (UNIQUE constraint)
-- INSERT INTO students (first_name, last_name, email, dept_id) 
-- VALUES ('Test', 'User', 'john.doe@university.edu', 1);

-- 2. Invalid GPA (CHECK constraint)
-- INSERT INTO students (first_name, last_name, email, gpa, dept_id) 
-- VALUES ('Test', 'User', 'test@university.edu', 5.0, 1);

-- 3. Foreign key violation
-- INSERT INTO students (first_name, last_name, email, dept_id) 
-- VALUES ('Test', 'User', 'test2@university.edu', 999);

-- Valid insertions:
INSERT INTO students (first_name, last_name, email, date_of_birth, gpa, dept_id) 
VALUES ('Alice', 'Cooper', 'alice.cooper@university.edu', '2001-12-01', 3.45, 2);
```

#### **Conclusion:**
This solution demonstrates comprehensive table creation with various constraint types (PRIMARY KEY, FOREIGN KEY, UNIQUE, NOT NULL, CHECK, DEFAULT), proper data insertion, table alterations, and complex SELECT operations. The constraints ensure data integrity while the queries showcase different ways to retrieve and analyze data from the university management system.

---

## **Sample Solution 2: Advanced Queries with Subqueries**
**Question:** Write comprehensive queries using subqueries, set operations (UNION, INTERSECT), and advanced filtering (ANY, ALL, EXISTS, IN). Use an Employee Management System.

### **Solution:**

#### **Step 1: Create Sample Database Structure**

```sql
-- Create database and tables
CREATE DATABASE employee_management;
USE employee_management;

CREATE TABLE departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50),
    budget DECIMAL(12,2)
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    email VARCHAR(100),
    salary DECIMAL(10,2),
    hire_date DATE,
    dept_id INT,
    manager_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id),
    FOREIGN KEY (manager_id) REFERENCES employees(emp_id)
);

CREATE TABLE projects (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    start_date DATE,
    end_date DATE,
    budget DECIMAL(12,2),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

CREATE TABLE project_assignments (
    assignment_id INT PRIMARY KEY AUTO_INCREMENT,
    emp_id INT,
    project_id INT,
    role VARCHAR(50),
    hours_per_week INT,
    FOREIGN KEY (emp_id) REFERENCES employees(emp_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id)
);

-- Insert sample data
INSERT INTO departments VALUES
(1, 'IT', 'Building A', 1000000),
(2, 'HR', 'Building B', 500000),
(3, 'Finance', 'Building C', 800000),
(4, 'Marketing', 'Building D', 600000);

INSERT INTO employees VALUES
(101, 'John', 'Smith', 'john@company.com', 75000, '2020-01-15', 1, NULL),
(102, 'Jane', 'Doe', 'jane@company.com', 65000, '2020-03-20', 1, 101),
(103, 'Mike', 'Johnson', 'mike@company.com', 80000, '2019-05-10', 2, NULL),
(104, 'Sarah', 'Wilson', 'sarah@company.com', 70000, '2021-02-28', 2, 103),
(105, 'Tom', 'Brown', 'tom@company.com', 85000, '2018-08-12', 3, NULL),
(106, 'Lisa', 'Davis', 'lisa@company.com', 60000, '2021-06-15', 3, 105),
(107, 'David', 'Miller', 'david@company.com', 72000, '2020-11-30', 4, NULL),
(108, 'Amy', 'Garcia', 'amy@company.com', 58000, '2022-01-10', 4, 107);

INSERT INTO projects VALUES
(1, 'Website Redesign', '2023-01-01', '2023-06-30', 150000, 1),
(2, 'HR System Upgrade', '2023-03-01', '2023-09-30', 200000, 2),
(3, 'Financial Audit', '2023-02-15', '2023-05-15', 100000, 3),
(4, 'Marketing Campaign', '2023-04-01', '2023-12-31', 250000, 4);

INSERT INTO project_assignments VALUES
(1, 101, 1, 'Project Manager', 40),
(2, 102, 1, 'Developer', 35),
(3, 103, 2, 'Project Manager', 30),
(4, 104, 2, 'Analyst', 25),
(5, 105, 3, 'Lead Auditor', 40),
(6, 106, 3, 'Junior Auditor', 30),
(7, 107, 4, 'Campaign Manager', 35),
(8, 108, 4, 'Content Creator', 20);
```

#### **Step 2: Subqueries with ANY and ALL**

```sql
-- 1. Find employees whose salary is higher than ANY employee in HR department
SELECT first_name, last_name, salary, dept_id
FROM employees
WHERE salary > ANY (
    SELECT salary 
    FROM employees 
    WHERE dept_id = 2
)
ORDER BY salary DESC;

-- 2. Find employees whose salary is higher than ALL employees in Marketing department
SELECT first_name, last_name, salary, dept_id
FROM employees
WHERE salary > ALL (
    SELECT salary 
    FROM employees 
    WHERE dept_id = 4
)
ORDER BY salary DESC;

-- 3. Find departments with budget higher than ANY project budget
SELECT dept_name, budget
FROM departments
WHERE budget > ANY (
    SELECT budget 
    FROM projects 
    WHERE budget IS NOT NULL
);

-- 4. Find employees earning more than ALL employees hired after 2021
SELECT first_name, last_name, salary, hire_date
FROM employees
WHERE salary > ALL (
    SELECT salary 
    FROM employees 
    WHERE hire_date > '2021-01-01'
);
```

#### **Step 3: Subqueries with IN, EXISTS, NOT EXISTS**

```sql
-- 1. Find employees working in departments located in Building A or Building B
SELECT first_name, last_name, dept_id
FROM employees
WHERE dept_id IN (
    SELECT dept_id 
    FROM departments 
    WHERE location IN ('Building A', 'Building B')
);

-- 2. Find employees who are assigned to projects (using EXISTS)
SELECT e.first_name, e.last_name, e.dept_id
FROM employees e
WHERE EXISTS (
    SELECT 1 
    FROM project_assignments pa 
    WHERE pa.emp_id = e.emp_id
);

-- 3. Find employees who are NOT assigned to any project (using NOT EXISTS)
SELECT e.first_name, e.last_name, e.dept_id
FROM employees e
WHERE NOT EXISTS (
    SELECT 1 
    FROM project_assignments pa 
    WHERE pa.emp_id = e.emp_id
);

-- 4. Find departments that have employees working on projects
SELECT DISTINCT d.dept_name, d.location
FROM departments d
WHERE EXISTS (
    SELECT 1 
    FROM employees e 
    INNER JOIN project_assignments pa ON e.emp_id = pa.emp_id
    WHERE e.dept_id = d.dept_id
);

-- 5. Complex EXISTS with multiple conditions
SELECT e.first_name, e.last_name, e.salary
FROM employees e
WHERE EXISTS (
    SELECT 1 
    FROM project_assignments pa 
    INNER JOIN projects p ON pa.project_id = p.project_id
    WHERE pa.emp_id = e.emp_id 
    AND p.budget > 150000
    AND pa.hours_per_week >= 30
);
```

#### **Step 4: Set Operations (UNION, INTERSECT)**

```sql
-- 1. UNION - Combine managers and project managers
SELECT DISTINCT first_name, last_name, 'Manager' as role
FROM employees
WHERE emp_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL)
UNION
SELECT DISTINCT e.first_name, e.last_name, 'Project Manager' as role
FROM employees e
INNER JOIN project_assignments pa ON e.emp_id = pa.emp_id
WHERE pa.role = 'Project Manager';

-- 2. UNION ALL - Show all high earners and project workers (with duplicates)
SELECT first_name, last_name, salary, 'High Earner' as category
FROM employees
WHERE salary > 70000
UNION ALL
SELECT e.first_name, e.last_name, e.salary, 'Project Worker' as category
FROM employees e
INNER JOIN project_assignments pa ON e.emp_id = pa.emp_id;

-- 3. Simulate INTERSECT - Find employees who are both managers and work on projects
SELECT e.first_name, e.last_name
FROM employees e
WHERE e.emp_id IN (SELECT DISTINCT manager_id FROM employees WHERE manager_id IS NOT NULL)
AND e.emp_id IN (SELECT emp_id FROM project_assignments);

-- 4. Complex UNION with aggregation
SELECT 'Department' as type, dept_name as name, budget as amount
FROM departments
WHERE budget > 600000
UNION
SELECT 'Project' as type, project_name as name, budget as amount
FROM projects
WHERE budget > 150000
ORDER BY amount DESC;
```

#### **Step 5: Correlated Subqueries**

```sql
-- 1. Find employees earning more than average in their department
SELECT e1.first_name, e1.last_name, e1.salary, e1.dept_id
FROM employees e1
WHERE e1.salary > (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id = e1.dept_id
);

-- 2. Find departments with above-average budgets
SELECT d1.dept_name, d1.budget
FROM departments d1
WHERE d1.budget > (
    SELECT AVG(d2.budget)
    FROM departments d2
);

-- 3. Find employees who work more hours than average in their project
SELECT e.first_name, e.last_name, pa1.hours_per_week, p.project_name
FROM employees e
INNER JOIN project_assignments pa1 ON e.emp_id = pa1.emp_id
INNER JOIN projects p ON pa1.project_id = p.project_id
WHERE pa1.hours_per_week > (
    SELECT AVG(pa2.hours_per_week)
    FROM project_assignments pa2
    WHERE pa2.project_id = pa1.project_id
);
```

#### **Step 6: Complex Nested Subqueries**

```sql
-- 1. Find employees in departments that have the highest budget projects
SELECT e.first_name, e.last_name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IN (
    SELECT dept_id
    FROM projects
    WHERE budget = (
        SELECT MAX(budget)
        FROM projects
    )
);

-- 2. Multi-level subquery - Find employees in departments with projects having above-average budgets
SELECT first_name, last_name, dept_id
FROM employees
WHERE dept_id IN (
    SELECT DISTINCT dept_id
    FROM projects
    WHERE budget > (
        SELECT AVG(budget)
        FROM projects
        WHERE end_date > CURDATE()
    )
);

-- 3. Complex query combining multiple concepts
SELECT e.first_name, e.last_name, e.salary,
       (SELECT COUNT(*) FROM project_assignments pa WHERE pa.emp_id = e.emp_id) as project_count
FROM employees e
WHERE e.salary > ANY (
    SELECT AVG(e2.salary)
    FROM employees e2
    WHERE e2.dept_id IN (
        SELECT dept_id
        FROM departments
        WHERE budget > 600000
    )
    GROUP BY e2.dept_id
)
AND EXISTS (
    SELECT 1
    FROM project_assignments pa
    WHERE pa.emp_id = e.emp_id
);
```

#### **Conclusion:**
This comprehensive solution demonstrates advanced SQL querying techniques including subqueries with ANY/ALL operators, EXISTS/NOT EXISTS conditions, set operations like UNION, and complex correlated subqueries. These queries showcase how to extract meaningful business insights from relational data using sophisticated filtering and combining techniques.

---

**Note:** Each solution is approximately 1-2 pages and demonstrates the depth expected in a 3-hour exam. Focus on showing multiple techniques, proper syntax, and real-world applications. 