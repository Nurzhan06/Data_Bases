CREATE DATABASE advanced_Lab
OWNER = postgres
ENCODING = UTF8;

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    department VARCHAR(30),
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(30),
    budget INT,
    manager_id INT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(30),
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (101,'John', 'Smith', 'Finance');

INSERT INTO employees
VALUES (102, 'Kate', 'Moss', 'Marketing', 150000, '2024-09-14', DEFAULT);

INSERT INTO departments
VALUES (11, 'Finance', 1000000, 101),
       (12, 'Marketing', 1200000, 102),
       (13, 'HR', 500000, 103);


INSERT INTO employees
VALUES (103, 'Lana', 'Raven', 'HR', 500000 * 1.1, CURRENT_DATE, DEFAULT);

CREATE TEMP TABLE temp_employees (
      t_emp_id SERIAL PRIMARY KEY, t_first_name VARCHAR(30), t_last_name VARCHAR(30), department VARCHAR(30))

INSERT INTO temp_employees (t_emp_id, t_first_name, t_last_name, department)
SELECT employees.emp_id, employees.first_name, employees.last_name, employees.department
FROM employees
WHERE department = 'IT';

UPDATE employees
SET salary = salary * 1.1
WHERE status = 'Active';

UPDATE employees
SET status = 'Senior'
WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees
SET department = CASE
    WHEN salary > 80000 THEN 'Management'
    WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
ELSE 'Junior'
END;

UPDATE employees
SET department = DEFAULT
WHERE status = 'Inactive';

UPDATE departments
SET budget = (SELECT avg(employees.salary) * 1.2
              FROM employees
              WHERE department = dept_name);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees
WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;

DELETE FROM departments
WHERE dept_name NOT IN (
    SELECT DISTINCT employees.department
    FROM employees
    WHERE department IS NOT NULL
    );

DELETE FROM projects
WHERE end_date < '2023-01-01'
RETURNING *;

INSERT INTO employees
VALUES (106, 'Amir', 'Sabit', NULL, NULL, '2024-01-01', DEFAULT);

UPDATE employees
SET department = 'Unassigned'
WHERE department IS NULL;

DELETE FROM employees
WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees
VALUES (107, 'Ian', 'Curtis', 'Finance', 170000, '2023-01-01', DEFAULT)
RETURNING emp_id, concat(first_name, last_name);

UPDATE employees
SET salary = salary + 5000
WHERE department = 'IT'
RETURNING emp_id, salary - 5000 AS old-salary, salary AS new_salary;

DELETE FROM employees
WHERE hire_date < '2020-01-01'
RETURNING *;



