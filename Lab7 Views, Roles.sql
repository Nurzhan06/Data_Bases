2.1
CREATE VIEW emp_info AS
SELECT employees.emp_name, employees.salary,departments.dept_name, departments.location
FROM employees, departments
WHERE employees.dept_id = departments.dept_id;

SELECT * FROM emp_info;
Q1: 4 rows returned, Tom Brown does not appear since his dept id is not assigned

2.2
CREATE VIEW dept_statistics AS
SELECT departments.dept_name, count(employees.dept_id) AS emp_count, avg(employees.salary), max(salary), min(salary)
FROM departments
LEFT JOIN employees ON departments.dept_id = employees.dept_id
GROUP BY departments.dept_id, dept_name;

SELECT * FROM dept_statistics
ORDER BY emp_count DESC;

2.3
CREATE VIEW project_overview AS
SELECT projects.project_name, projects.budget, departments.dept_name, location, count(employees.dept_id) AS team_size
FROM projects
LEFT JOIN departments ON projects.dept_id = departments.dept_id
LEFT JOIN employees ON departments.dept_id = employees.dept_id
GROUP BY project_name, budget, dept_name, location;

SELECT * FROM project_overview;

2.4
CREATE VIEW high_earners AS
SELECT employees.emp_name, employees.salary, departments.dept_name
FROM employees
LEFT JOIN departments ON employees.dept_id = departments.dept_id
WHERE salary > 55000
ORDER BY salary DESC;

SELECT * FROM high_earners;
Q2: query returns 2 employees, all high high_earners

3.1
CREATE OR REPLACE VIEW emp_info AS
SELECT employees.emp_name, employees.salary,departments.dept_name, departments.location,
CASE
    WHEN salary > 60000 THEN 'High'
    WHEN salary > 50000 THEN 'Medium'
    ELSE 'standerd'
    END AS salary_level
FROM employees, departments
WHERE employees.dept_id = departments.dept_id;

SELECT * FROM emp_info;

3.2
ALTER VIEW high_earners RENAME TO top_performers;

SELECT * FROM top_performers;

3.3
CREATE VIEW temp_view AS
SELECT employees.emp_name, employees.salary
FROM employees
WHERE salary < 50000;

SELECT * FROM temp_view;

DROP VIEW temp_view;

4.1
CREATE VIEW emp_salaries AS
SELECT employees.emp_id, employees.emp_name,  employees.dept_id, employees.salary
FROM employees;

4.2
UPDATE emp_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT * FROM employees WHERE emp_name = 'John Smith';
Q3: Yes, underlying base table get updated because our view is simple select, based on one table, contains actual columns from table and has no join or aggregates

4.3
INSERT INTO emp_salaries (emp_id, emp_name, dept_id, salary)
VALUES (6,'Alice Johnson', 102, 58000);

SELECT * FROM employees WHERE emp_name = 'Alice Johnson';
Q4: Insert also affected base table

4.4
CREATE VIEW it_employees AS
SELECT employees.emp_id, employees.emp_name, employees.dept_id, employees.salary
FROM employees
WHERE dept_id = 101
WITH LOCAL CHECK OPTION;

INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
Q5: ERROR: new row violates check option for view "it_employees", because in values dept it is 103, instead of 101

5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
SELECT
    departments.dept_id,
    departments.dept_name,
    count(employees.emp_id) AS total_employees,
    coalesce(sum(employees.salary), 0) AS total_salaries,
    count(projects.project_id) AS total_projects,
    coalesce(sum(projects.budget), 0) AS total_project_budget
FROM departments
LEFT JOIN employees ON departments.dept_id = employees.dept_id
LEFT JOIN projects ON departments.dept_id = projects.dept_id
GROUP BY departments.dept_id, dept_name
WITH DATA;

SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary, manager_id)
VALUES (8, 'Charlie Brown',101, 54000, NULL);

5.3
CREATE UNIQUE INDEX  dept_summary_mv_dept_id_idx ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW concurrently dept_summary_mv;
Q6: concurrently allows to read while refreshing

5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    projects.project_id,
    projects.project_name,
    projects.budget,
    departments.dept_name,
    coalesce(count(employees.dept_id), 0) AS assigned_employees
FROM projects
LEFT JOIN departments ON projects.dept_id = departments.dept_id
LEFT JOIN employees ON projects.dept_id = employees.dept_id
GROUP BY project_id, departments.dept_id
WITH NO DATA;

SELECT * FROM project_stats_mv;

Q7: ERROR: materialized view "project_stats_mv" has not been populated

REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

6.1
CREATE ROLE analyst WITH NOLOGIN;

CREATE ROLE data_viewer WITH LOGIN PASSWORD 'viewer123';

CREATE ROLE report_user WITH LOGIN PASSWORD 'report456';

SELECT pg_roles.rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

6.2
CREATE ROLE db_creator WITH LOGIN PASSWORD 'creator789' CREATEDB;

CREATE ROLE user_manger WITH LOGIN PASSWORD 'manager101' CREATEROLE;

CREATE ROLE admin_user WITH LOGIN PASSWORD 'admin999' SUPERUSER;

6.3
GRANT SELECT ON TABLE employees, departments,  projects TO analyst;

GRANT ALL PRIVILEGES ON TABLE emp_info TO data_viewer;

GRANT SELECT, INSERT ON TABLE employees TO report_user;

6.4
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE ROLE hr_user1 WITH LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 WITH LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 WITH LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL ON TABLE emp_info FROM data_viewer;

6.6
ALTER ROLE analyst WITH LOGIN PASSWORD 'analyst123';
ALTER ROLE user_manger WITH SUPERUSER;

ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

7.1
CREATE ROLE read_only NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;

CREATE ROLE junior_analyst WITH LOGIN PASSWORD 'junior123';
CREATE ROLE senior_analyst WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE ON employees TO senior_analyst;

7.2
CREATE ROLE project_manager WITH LOGIN PASSWORD 'pm123';

ALTER VIEW dept_statistics OWNER TO project_manager;

ALTER TABLE projects OWNER TO project_manager;

SELECT pg_tables.tablename, pg_tables.tableowner
FROM pg_tables
WHERE schemaname = 'public';

7.3
CREATE ROLE temp_owner WITH LOGIN PASSWORD 'temp123';
CREATE TABLE temp_table (id INT);

ALTER TABLE temp_table OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP ROLE IF EXISTS temp_owner;

7.4
CREATE VIEW hr_employee_view AS
SELECT emp_id, emp_name, dept_id
FROM employees
WHERE dept_id = 102;

GRANT SELECT ON hr_employee_view TO hr_team;

CREATE VIEW finance_employee_view AS
SELECT emp_id, emp_name, salary
FROM employees;

GRANT SELECT ON finance_employee_view TO finance_team;

8.1
CREATE VIEW dept_dashboard AS
    SELECT departments.dept_id,
           departments.dept_name,
           departments.location,
           coalesce(count(employees.dept_id), 0),
           round(avg(employees.salary), 2),
           coalesce(count(projects.project_id), 0),
           coalesce(sum(projects.budget), 0),
           CASE
               WHEN coalesce(count(employees.dept_id), 0) = 0 THEN 0
               ELSE round(sum(projects.budget) / coalesce(count(employees.dept_id), 0))
END AS budget_per_employee
FROM departments
LEFT JOIN employees ON departments.dept_id = employees.dept_id
LEFT JOIN projects ON departments.dept_id = projects.dept_id
GROUP BY departments.dept_id, employees.dept_id;

8.2
ALTER TABLE projects ADD COLUMN IF NOT EXISTS created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
  p.project_id,
  p.project_name,
  p.budget,
  d.dept_name,
  p.created_date,
  CASE
    WHEN p.budget > 150000 THEN 'Critical Review Required'
    WHEN p.budget > 100000 THEN 'Management Approval Needed'
    ELSE 'Standard Process'
  END AS approval_status
FROM projects p
LEFT JOIN departments d ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

8.3
CREATE ROLE viewer_role NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role NOLOGIN;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role NOLOGIN;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role NOLOGIN;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE ROLE alice WITH LOGIN PASSWORD 'alice123';
CREATE ROLE bob WITH LOGIN PASSWORD 'bob123';
CREATE ROLE charlie WITH LOGIN PASSWORD 'charlie123';

GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;