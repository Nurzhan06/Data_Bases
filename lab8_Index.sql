1.1
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);

INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');

INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);

INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);

2.1
CREATE INDEX emp_salary_idx ON employees(salary);

SELECT pg_indexes.indexname, pg_indexes.indexdef
FROM pg_indexes
WHERE tablename = 'employees';
Q1: there are 2 indexes on employees table

2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;
Q2: they speed up FK-related operations such as JOINs and lookups

2.3
SELECT pg_indexes.tablename,
       pg_indexes.indexname,
       pg_indexes.indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
Q3: employees_pkey, departments_pkey, projects_pkey created automatically, emp_salary_idx and emp_dept_idx was created by user


3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
Q4: No, B-tree index on (dept_id, salary) most efficient for queries filter on dept_id, because it it leading column

3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
Q5: order in multicolumn index matter because it is filtered by first column

4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);

UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
Q6: ERROR: duplicate key value violates unique constraint "emp_email_unique_idx"

4.2
ALTER TABLE employees ADD COLUMN phone VARCHAR(20);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
Q7: postgresql create b-tree index to enforce unique constraint

5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT employees.emp_name, employees.salary
FROM employees
ORDER BY salary DESC;
Q8: if index stores values in descending oreder, queries will perform faster because they skip sorting step

5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

6.1
CREATE INDEX emp_name_lower_idx ON employees(lower(emp_name));

SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;

UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

CREATE INDEX emp_hire_year_idx ON employees (extract(year FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

7.2
DROP INDEX emp_salary_dept_idx;
Q9:

7.3
REINDEX INDEX employees_salary_index;
Q10: index consume disk space and slow down writes like insert, delete, update

8.1
SELECT employees.emp_name,  employees.salary,  departments.dept_name
FROM employees
JOIN departments ON employees.dept_id = departments.dept_id
WHERE salary > 50000
ORDER BY salary DESC;

CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
CREATE INDEX emp_dept_idx ON employees(dept_id);
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

8.2
CREATE INDEX proj_high_budget_idx ON projects(budget)
WHERE budget > 80000;

SELECT projects.proj_name, projects.budget
FROM projects
WHERE budget > 80000;

8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
Q11: Seq Scan on employees

9.1
CREATE INDEX dept_name_hash_idx ON departments USING hash(dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
Q12: hash indecies are great for eqality searches (=, <=>), faster than b-tree for specific lookups

9.2
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
CREATE INDEX proj_name_hash_idx ON projects USING hash(proj_name);

SELECT * FROM projects WHERE proj_name = 'Website Redesign';
SELECT * FROM projects WHERE proj_name > 'Database';

10.1
SELECT
    pg_indexes.schemaname,
    pg_indexes.tablename,
    pg_indexes.indexname,
    pg_size_pretty(pg_relation_size(indexname::regclass)) AS index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
Q13: hash based indecies are largest, becuase thye srore hash value of each key and pointers of rows in hash table

10.2
DROP INDEX IF EXISTS proj_name_hash_idx;

10.3
CREATE VIEW index_documentation AS
    SELECT
        pg_indexes.tablename,
        pg_indexes.indexname,
        pg_indexes.indexdef,
        'Improves salary_based queries' AS purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';

SELECT * FROM index_documentation;
