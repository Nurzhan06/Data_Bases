Task 1.1
SELECT concat(employees.first_name, ' ', employees.last_name), employees.department, employees.salary FROM employees;

Task 1.2
SELECT DISTINCT employees.department FROM employees;

Task 1.3
SELECT projects.project_name, projects.budget,
       CASE
           WHEN (projects.budget > 150000) THEN 'large'
           WHEN (projects.budget BETWEEN 100000 AND 150000) THEN 'medium'
           ELSE 'small'
END AS category_budget
FROM projects;

Task 1.4
SELECT concat(first_name, ' ', last_name),
       coalesce(employees.email, 'no email provided')
FROM employees;

Task 2.1
SELECT * FROM employees
WHERE hire_date > '2020-01-01';

Task 2.2
SELECT * FROM employees
WHERE salary BETWEEN 60000 AND 70000;

Task 2.3
SELECT * FROM employees
WHERE last_name LIKE 'S%' OR last_name LIKE 'J%';

Task 2.4
SELECT * FROM employees
WHERE manager_id IS NOT NULL AND department = 'IT';

Task 3.1
SELECT upper(concat(employees.first_name, ' ', employees.last_name)),
       char_length(employees.first_name),
       substr(employees.first_name, 1, 3)
FROM employees;

Task 3.2
SELECT employees.salary * 12 AS annual_salary,
       round(employees.salary,2),
       employees.salary * 1.1 AS slary_with_10_percent_raise
FROM employees;

Task 3.3
SELECT  concat('Project: ', projects.project_name, ' - Budget: $', format(budget, '###-###'), ' - Status: ', status) AS project_summary
FROM projects;

Task 3.4
SELECT concat(first_name, ' ', last_name), (current_date - employees.hire_date) / 365 AS years_worked
FROM employees;

Task 4.1
SELECT employees.department, avg(employees.salary) AS average_salary
FROM employees
GROUP BY department;

Task 4.2
SELECT projects.project_id, projects.project_name, sum(assignments.hours_worked) AS total_hours_worked
FROM projects
LEFT JOIN assignments ON assignments.project_id = projects.project_id
GROUP BY projects.project_id
ORDER BY project_id;

Task 4.3
SELECT department, count(employees.employee_id) AS number_of_employees
FROM employees
GROUP BY department
HAVING count(employees) > 1;

Task 4.4
SELECT max(employees.salary) AS max_salary,
       min(employees.salary) AS min_salary,
       sum(employees.salary) AS total_payroll
FROM employees;

Task 5.1
SELECT employees.employee_id, concat(employees.first_name, ' ', employees.last_name), employees.salary
FROM employees
WHERE salary > 65000
UNION
SELECT employees.employee_id, concat(employees.first_name, ' ', employees.last_name), employees.salary
FROM employees
WHERE hire_date > '2020-01-01';

Task 5.2
SELECT concat(employees.first_name, ' ', employees.last_name), employees.salary, employees.department
FROM employees
WHERE salary > 65000
INTERSECT
SELECT concat(employees.first_name, ' ', employees.last_name), employees.salary, employees.department
FROM employees
WHERE department = 'IT';

Task 5.3
SELECT employee_id, concat(first_name, ' ', last_name)
FROM employees
EXCEPT
SELECT employees.employee_id, concat(first_name, ' ', last_name)
FROM employees
JOIN assignments ON assignments.employee_id = employees.employee_id;

Task 6.1
SELECT employees.employee_id, concat(employees.first_name, ' ', employees.last_name)
FROM employees
WHERE exists(
    SELECT 1
    FROM assignments
    WHERE assignments.employee_id = employees.employee_id
);

Taks 6.2
SELECT employees.employee_id, concat(employees.first_name, ' ', employees.last_name)
FROM employees
WHERE employee_id IN (
    SELECT employee_id
    FROM assignments
    JOIN projects ON assignments.project_id = projects.project_id
    WHERE status = 'Active'
    );

Task 6.3
SELECT employees.employee_id, concat(employees.first_name, ' ', employees.last_name), employees.salary
FROM employees
WHERE salary > ANY (
    SELECT salary
    FROM employees
    WHERE department = 'Sales'
    );

Task 7.1
SELECT concat(employees.first_name, ' ', employees.last_name), employees.department,
       avg(assignments.hours_worked) AS average_hours_worked,
       rank() OVER (partition by employees.department ORDER BY employees.salary DESC) AS salary_rank
FROM employees
LEFT JOIN assignments ON assignments.employee_id = employees.employee_id
GROUP BY concat(employees.first_name, ' ', employees.last_name), employees.department, salary
ORDER BY department, salary_rank;

Taks 7.2
SELECT projects.project_name,
       sum(assignments.hours_worked) AS total_hours,
       count(DISTINCT assignments.employee_id) AS number_of_employees
FROM projects
JOIN assignments ON projects.project_id = assignments.project_id
GROUP BY projects.project_id, project_name
HAVING sum(hours_worked) > 150
ORDER BY total_hours DESC;

Taks 7.3
SELECT employees.department,
       count(*) AS total_employees,
       avg(employees.salary) AS average_salary,
       max(employees.salary) AS highest_salary,
       (SELECT concat(employees.first_name, ' ', employees.last_name)
        FROM employees
        ORDER BY salary DESC
        LIMIT 1) AS highest_paid_employee
FROM employees
GROUP BY department
ORDER BY department;