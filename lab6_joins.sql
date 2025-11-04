1.1
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);

CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);

CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

1.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
    (1, 'John Smith', 101, 50000),
    (2, 'Jane Doe', 102, 60000),
    (3, 'Mike Johnson', 101, 55000),
    (4, 'Sarah Williams', 103, 65000),
    (5, 'Tom Brown', NULL, 45000);

INSERT INTO departments (dept_id, dept_name, location)
VALUES
    (101, 'IT', 'Building A'),
    (102, 'HR', 'Building B'),
    (103, 'Finance', 'Building C'),
    (104, 'Marketing', 'Building D');

INSERT INTO projects (project_id, project_name, dept_id, budget)
VALUES
    (1, 'Website Redesign', 101, 100000),
    (2, 'Employee Training', 102, 50000),
    (3, 'Budget Analysis', 103, 75000),
    (4, 'Cloud Migration', 101, 150000),
    (5, 'AI Research', NULL, 200000);

2.1
SELECT employees.emp_name, departments.dept_name
FROM employees CROSS JOIN departments;

5 emps * 4 depts = 20 combinations

2.2
a
SELECT employees.emp_name, departments.dept_name
FROM employees, departments;

b
SELECT employees.emp_name, departments.dept_name
FROM employees
INNER JOIN departments ON TRUE;

2.3
SELECT employees.emp_name, projects.project_name
FROM employees CROSS JOIN projects;

3.1
SELECT employees.emp_name, departments.dept_name, departments.location
FROM employees
INNER JOIN departments ON employees.dept_id = departments.dept_id;

4 rows returned, instead of 5 because Tom Brown has NULL dept_id

3.2
SELECT employees.emp_name, departments.dept_name, departments.location
FROM employees
INNER JOIN departments USING (dept_id);

3.3
SELECT employees.emp_name, departments.dept_name, departments.location
FROM employees
NATURAL INNER JOIN departments;

3.4
SELECT employees.emp_name, departments.dept_name, projects.project_name
FROM employees
INNER JOIN departments ON employees.dept_id = departments.dept_id
INNER JOIN projects ON departments.dept_id = projects.dept_id;

4.1
SELECT employees.emp_name, employees.dept_id AS emp_dept, departments.dept_id AS dept_dept, dept_name
FROM employees
LEFT JOIN departments ON employees.dept_id = departments.dept_id;

Tom Brown <null> <null> <null>

4.2
SELECT employees.emp_name, employees.dept_id, departments.dept_name
FROM employees
LEFT JOIN departments USING (dept_id);

4.3
SELECT employees.emp_name, employees.dept_id
FROM employees
LEFT JOIN departments ON employees.dept_id = departments.dept_id
WHERE departments.dept_id IS NULL;

4.4
SELECT departments.dept_name, count(employees.emp_id) AS employee_count
FROM departments
LEFT JOIN employees ON departments.dept_id = employees.dept_id
GROUP BY employees.dept_id, dept_name
ORDER BY employee_count DESC;

5.1
SELECT employees.emp_name, departments.dept_name
FROM employees
RIGHT JOIN departments ON  employees.dept_id = departments.dept_id;

5.2
SELECT employees.emp_name, departments.dept_name
FROM departments
LEFT JOIN employees ON employees.dept_id = departments.dept_id;

5.3
SELECT departments.dept_name, departments.location
FROM employees
RIGHT JOIN departments ON employees.dept_id =  departments.dept_id
WHERE emp_id IS NULL;

6.1
SELECT employees.emp_name, employees.dept_id AS emp_dept, departments.dept_id AS dept_dept, departments.dept_name
FROM employees
FULL JOIN departments ON employees.dept_id = departments.dept_id;

6.2
SELECT departments.dept_name, projects.project_name, projects.budget
FROM departments
FULL JOIN projects ON departments.dept_id = projects.dept_id;

6.3
SELECT
    CASE
        WHEN employees.emp_id IS NULL THEN 'department without employees'
        WHEN departments.dept_id IS NULL THEN 'employee without department'
        ELSE 'matched'
        END AS record_status, employees.emp_name, departments.dept_name
FROM employees
FULL JOIN  departments ON employees.dept_id = departments.dept_id
WHERE emp_id IS NULL OR departments.dept_id IS NULL;

7.1
SELECT employees.emp_name, departments.dept_name, employees.salary
FROM employees
LEFT JOIN departments ON employees.dept_id = departments.dept_id AND location = 'Building A';

7.2
SELECT employees.emp_name, departments.dept_name, employees.salary
FROM employees
LEFT JOIN departments ON employees.dept_id = departments.dept_id
WHERE location = 'Building A';

7.3
SELECT employees.emp_name, departments.dept_name, employees.salary
FROM employees
INNER JOIN departments ON employees.dept_id = departments.dept_id AND location = 'Building A';

SELECT employees.emp_name, departments.dept_name, employees.salary
FROM employees
INNER JOIN departments ON employees.dept_id = departments.dept_id
WHERE location = 'Building A';

8.1
SELECT
    departments.dept_name,
    employees.emp_name,
    employees.salary,
    projects.project_name,
    projects.budget
FROM departments
LEFT JOIN employees ON departments.dept_id = employees.dept_id
LEFT JOIN projects ON departments.dept_id = projects.dept_id
ORDER BY dept_name, emp_name;

8.2
ALTER TABLE employees ADD COLUMN manager_id INT;

UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

SELECT e.emp_name AS employee, m.emp_name AS manager
FROM employees e, employees m
WHERE e.manager_id = m.emp_id;

8.3
SELECT departments.dept_name, avg(employees.salary) AS average_salary
FROM departments
INNER JOIN employees ON departments.dept_id = employees.dept_id
GROUP BY employees.dept_id, dept_name
HAVING avg(salary) > 50000;