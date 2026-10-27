USE hr_analytics;
SELECT * FROM employees;
SELECT * FROM departments;
SELECT * FROM performance_reviews;
SELECT * FROM salary_history;


-- Task 1: Basic Filtering & Text Formatting
-- Objective: Produce a clean active roster for the Human Resources and Data & Analytics departments.
-- Retrieve the full name (combined first_name and last_name formatted as "First Last"), job_title, hire_date, and employment_status.
-- Filter only for Active employees working in Human Resources or Data & Analytics.
-- Sort the results alphabetically by last_name.
SELECT
	CONCAT_WS(' ', e.first_name, e.last_name) AS full_name,
    e.job_title,
    e.hire_date,
    d.department_name,
    e.employment_status
FROM employees AS e
JOIN departments AS d
	ON e.department_id = d.department_id
WHERE e.employment_status = 'Active'
	AND department_name IN ('Human Resources', 'Data & Analytics')
ORDER BY e.last_name ASC;




-- Task 2: Aggregations & Department Headcount Summary
-- Objective: Calculate key headcount and turnover metrics per department.
-- Write a query that groups by department_name and calculates =
-- 1. Total_Employees: Total count of all employees ever hired.
-- 2. Active_Employees: Total count of currently Active employees.
-- 3. Terminated_Employees: Total count of Terminated employees.
-- 4. Turnover_Rate_%: (Terminated_Employees / Total_Employees) * 100 rounded to 2 decimal places.
SELECT
	d.department_name,
    COUNT(e.employee_id) AS Total_employees,
    SUM(CASE
		WHEN e.employment_status = 'Active' THEN 1 ELSE 0
        END) AS Active_employees,
	SUM(CASE
		WHEN e.employment_status = 'Terminated' THEN 1 ELSE 0
        END) AS Terminated_employees,
	ROUND(
		(
			SUM(CASE
				WHEN e.employment_status = 'Terminated' THEN 1 ELSE 0
                END) * 100.0 
		) / NULLIF(COUNT(e.employee_id), 0), 
		2
	) AS 'Turnover_rate_%'
FROM departments AS d
LEFT JOIN employees AS e
	ON d.department_id = e.department_id
GROUP BY d.department_name;




-- Task 3: Self-Join for Organizational Hierarchy
-- Objective: Map out employee-manager reporting relationships.
-- Retrieve employee_id, the employee's full name (Employee_Name), their job_title, and their direct manager's full name (Manager_Name).
-- If an employee has no manager (e.g., VPs/Directors), display 'Top Executive' instead of NULL.
-- Order by manager name, then employee name.
SELECT
	e.employee_id,
    CONCAT_WS(' ', e.first_name, e.last_name) AS Employee_Name,
    e.job_title,
    CASE
		WHEN e.manager_id IS NULL THEN 'Top Executve'
        ELSE CONCAT_WS(' ', m.first_name, m.last_name)
	END AS Manager_Name
FROM employees AS e
LEFT JOIN employees AS m
	ON e.manager_id = m.employee_id
ORDER BY Manager_Name ASC, Employee_Name ASC;

-- syntax ini benar, tapi jika menggunakan COALESCE(CONCAT_WS..) maka NULL yang ada di kolom manager_id dianggap kosong
-- karena COALESCE hanya mengganti nilai jika yang diterima adalah NULL
-- sedangkan CONCAT_WS ini untuk menghindari adanya NULL
SELECT
	e.employee_id,
    CONCAT_WS(' ', e.first_name, e.last_name) AS Employee_Name,
    e.job_title,
    COALESCE(CONCAT_WS(' ', m.first_name, m.last_name), 'Top Executive') AS Manager_Name
FROM employees AS e
LEFT JOIN employees AS m
	ON e.manager_id = m.employee_id
ORDER BY Manager_Name ASC, Employee_Name ASC;




-- Task 4: Subqueries & Current Compensation Retrieval
-- Objective: Retrieve current salary information without hardcoding dates.
-- Because salary_history maintains historical compensation records, find the most recent salary for every Active employee.
-- Display employee_id, first_name, last_name, job_title, and current_salary.
-- Order the results by current_salary descending.
SELECT
	e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    sh.salary AS current_salary
FROM employees AS e
JOIN salary_history AS sh
	ON e.employee_id = sh.employee_id
JOIN (
	SELECT employee_id,
	MAX(salary_id) AS max_salary_id
    FROM salary_history
    GROUP BY employee_id
) AS latest
	ON sh.employee_id = latest.employee_id
    AND sh.salary_id = latest.max_salary_id
WHERE e.employment_status = 'Active'
ORDER BY current_salary DESC;

-- menggunakan CTE
WITH latest_salary AS (
	SELECT employee_id, MAX(salary_id) AS max_salary_id
    FROM salary_history
    GROUP BY employee_id
)
SELECT
	e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    sh.salary AS current_salary
FROM employees AS e
JOIN salary_history AS sh
	ON e.employee_id = sh.employee_id
JOIN latest_salary AS ls
	ON sh.employee_id = ls.employee_id
    AND sh.salary_id = ls.max_salary_id
WHERE e.employment_status = 'Active'
ORDER BY current_salary DESC;




-- Task 5: Multi-Table JOIN & Budget Utilization
-- Objective: Analyze departmental budget allocation against active payroll expenditure.
-- Calculate total current annual salary expenditure per department.
-- Join departments with active employee current salaries (from Task 4 logic).
-- Display department_name, annual_budget, total_current_payroll, and budget_variance (annual_budget - total_current_payroll).
-- Include departments even if they have no active employees.
WITH latest_salary AS (
	SELECT employee_id, MAX(salary_id) AS max_salary_id
    FROM salary_history
    GROUP BY employee_id
),
active_employee_salaries AS (
	SELECT
		e.department_id,
        sh.salary
	FROM employees AS e
    JOIN latest_salary AS ls
		ON e.employee_id = ls.employee_id
	JOIN salary_history AS sh
		ON ls.max_salary_id = sh.salary_id
	WHERE e.employment_status = 'Active'
)
SELECT
	d.department_name,
    d.annual_budget,
    COALESCE(SUM(aes.salary), 0) AS total_current_payroll,
    d.annual_budget - COALESCE(SUM( aes.salary), 0) AS budget_variance
FROM departments AS d
LEFT JOIN active_employee_salaries AS aes
	ON d.department_id = aes.department_id
GROUP BY d.department_id, d.department_name,d.annual_budget;




-- Task 6: Window Functions - Salary Ranking & Percentiles
-- Objective: Rank employees within their respective departments based on their latest salary.
-- Use MySQL window functions (DENSE_RANK()) to rank Active employees by their current salary partitioned by department.
-- Output columns: department_name, employee_name, job_title, current_salary, and dept_salary_rank.
-- Filter or sort to easily highlight top earners in each department.
WITH latest_salary AS (
	SELECT employee_id, MAX(salary_id) AS max_salary_id
    FROM salary_history
    GROUP BY employee_id
)
SELECT
	d.department_name,
    CONCAT_WS(' ', e.first_name, e.last_name) AS employee_name,
    e.job_title,
    sh.salary AS current_salary,
    DENSE_RANK() OVER (PARTITION BY d.department_name 
		ORDER BY sh.salary DESC) AS dept_salary_rank
FROM employees AS e
JOIN departments AS d ON e.department_id = d.department_id
JOIN latest_salary AS ls ON e.employee_id = ls.employee_id
JOIN salary_history AS sh ON ls.max_salary_id = sh.salary_id
WHERE e.employment_status = 'Active'
ORDER BY d.department_name ASC, dept_salary_rank ASC;



-- Task 7: Window Functions - Year-Over-Year Salary Growth
-- Objective: Track individual salary progression across effective dates.
-- For each salary record in salary_history, use the LAG() window function to retrieve the employee's previous_salary.
-- Calculate salary_increase_amount (salary - previous_salary) and percentage_increase (((salary - previous_salary) / previous_salary) * 100).
-- Round the percentage increase to 2 decimal places.
-- Order by employee_id and effective_date ascending.
WITH salary_with_lag AS (
	SELECT
		sh.employee_id,
        e.first_name,
        e.last_name,
        sh.effective_date,
        sh.salary,
        LAG(sh.salary) OVER (PARTITION BY sh.employee_id
			ORDER BY sh.effective_date ASC)
            AS previous_salary
	FROM salary_history AS sh
    JOIN employees AS e ON sh.employee_id = e.employee_id
)
SELECT
	employee_id,
    CONCAT_WS(' ', first_name, last_name) AS employee_name,
    effective_date,
    salary,
    previous_salary,
    (salary - previous_salary) AS salary_increase_amount,
    ROUND(
		((salary - previous_salary) / NULLIF(previous_salary, 0)) * 100,
        2
	) AS percentage_increase
FROM salary_with_lag
ORDER BY employee_id ASC, effective_date ASC;




-- Task 8: Advanced CTE & Conditional Logic - Performance-to-Pay Matrix
-- Objective: Evaluate if high performance correlates with competitive compensation.
-- Write a Common Table Expression (CTE) to find each active employee's :
-- 1. Latest performance rating (from performance_reviews for 2024).
-- 2. Current salary.
-- Categorize employees using a CASE statement into :
-- 'High Performer - Below Avg Pay' if 2024 rating = 5 AND current salary is less than the overall company average active salary.
-- 'High Performer - Well Paid' if 2024 rating = 5 AND current salary is >= overall company average active salary.
-- 'Standard Performer' for all other cases.
-- Output employee_id, employee_name, performance_rating, current_salary, and compensation_category.
WITH latest_salary AS (
	SELECT employee_id, MAX(salary_id) AS max_salary_id
    FROM salary_history
    GROUP BY employee_id
),
active_salaries AS (
	SELECT
		e.employee_id,
        e.first_name,
        e.last_name,
        sh.salary AS current_salary
	FROM employees AS e
    JOIN latest_salary AS ls ON e.employee_id = ls.employee_id
    JOIN salary_history AS sh ON ls.max_salary_id= sh.salary_id
    WHERE e.employment_status = 'Active'
),
rating_2024 AS (
	SELECT employee_id, performance_rating
    FROM performance_reviews
    WHERE review_year = 2024
)
SELECT
	s.employee_id,
    CONCAT_WS(' ' , s.first_name, s.last_name) AS employee_name,
    r.performance_rating,
    s.current_salary,
    CASE
		WHEN r.performance_rating = 5 AND s.current_salary < (SELECT AVG(current_salary) FROM active_salaries
        )
			THEN 'High Performer - Below AVG Pay'
		WHEN r.performance_rating = 5 AND s.current_salary >= (SELECT AVG(current_salary) 
        FROM active_salaries)
			THEN 'High Performer - Well Paid'
		ELSE 'Standard Performer' 
	END AS compensation_category
FROM active_salaries AS s
LEFT JOIN rating_2024 AS r ON s.employee_id = r.employee_id
ORDER BY s.current_salary DESC;




-- query lain untuk TASK 1 (Solution 1: Basic Filtering & Text Formatting)
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.job_title,
    e.hire_date,
    e.employment_status,
    d.department_name
FROM employees e
JOIN departments d ON e.department_id = d.department_id
WHERE e.employment_status = 'Active'
  AND d.department_name IN ('Human Resources', 'Data & Analytics')
ORDER BY e.last_name ASC;

-- query lain untuk TASK 2 (Solution 2: Aggregations & Department Headcount Summary)
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS Total_Employees,
    COUNT(CASE WHEN e.employment_status = 'Active' THEN 1 END) AS Active_Employees,
    COUNT(CASE WHEN e.employment_status = 'Terminated' THEN 1 END) AS Terminated_Employees,
    ROUND(
        (COUNT(CASE WHEN e.employment_status = 'Terminated' THEN 1 END) * 100.0) / COUNT(e.employee_id), 
        2
    ) AS Turnover_Rate_Pct
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name
ORDER BY Turnover_Rate_Pct DESC;

-- query lain untuk TASK 3 (Solution 3: Self-Join for Organizational Hierarchy)
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS Employee_Name,
    e.job_title,
    COALESCE(CONCAT(m.first_name, ' ', m.last_name), 'Top Executive') AS Manager_Name
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.employee_id
ORDER BY Manager_Name ASC, Employee_Name ASC;

-- query lain untuk TASK 4 (Solution 4: Subqueries & Current Compensation Retrieval)
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.job_title,
    sh.salary AS current_salary
FROM employees e
JOIN salary_history sh ON e.employee_id = sh.employee_id
WHERE e.employment_status = 'Active'
  AND sh.effective_date = (
      SELECT MAX(sh_sub.effective_date)
      FROM salary_history sh_sub
      WHERE sh_sub.employee_id = e.employee_id
  )
ORDER BY current_salary DESC;

-- query lain untuk TASK 5 (Solution 5: Multi-Table JOIN & Budget Utilization)
WITH LatestSalaries AS (
    SELECT 
        e.department_id,
        sh.salary
    FROM employees e
    JOIN salary_history sh ON e.employee_id = sh.employee_id
    WHERE e.employment_status = 'Active'
      AND sh.effective_date = (
          SELECT MAX(sh_sub.effective_date)
          FROM salary_history sh_sub
          WHERE sh_sub.employee_id = e.employee_id
      )
)
SELECT 
    d.department_name,
    d.annual_budget,
    COALESCE(SUM(ls.salary), 0) AS total_current_payroll,
    d.annual_budget - COALESCE(SUM(ls.salary), 0) AS budget_variance
FROM departments d
LEFT JOIN LatestSalaries ls ON d.department_id = ls.department_id
GROUP BY d.department_id, d.department_name, d.annual_budget
ORDER BY budget_variance ASC;

-- query lain untuk TASK 6 (Solution 6: Window Functions - Salary Ranking)
WITH CurrentSalaries AS (
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        e.job_title,
        e.department_id,
        sh.salary AS current_salary
    FROM employees e
    JOIN salary_history sh ON e.employee_id = sh.employee_id
    WHERE e.employment_status = 'Active'
      AND sh.effective_date = (
          SELECT MAX(sh_sub.effective_date)
          FROM salary_history sh_sub
          WHERE sh_sub.employee_id = e.employee_id
      )
)
SELECT 
    d.department_name,
    cs.employee_name,
    cs.job_title,
    cs.current_salary,
    DENSE_RANK() OVER(
        PARTITION BY cs.department_id 
        ORDER BY cs.current_salary DESC
    ) AS dept_salary_rank
FROM CurrentSalaries cs
JOIN departments d ON cs.department_id = d.department_id
ORDER BY d.department_name, dept_salary_rank;

-- query lain untuk TASK 7 (Solution 7: Window Functions - Year-Over-Year Salary Growth)
SELECT 
    sh.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
    sh.effective_date,
    sh.salary AS current_salary,
    LAG(sh.salary, 1) OVER (
        PARTITION BY sh.employee_id 
        ORDER BY sh.effective_date ASC
    ) AS previous_salary,
    sh.salary - LAG(sh.salary, 1) OVER (
        PARTITION BY sh.employee_id 
        ORDER BY sh.effective_date ASC
    ) AS salary_increase_amount,
    ROUND(
        ((sh.salary - LAG(sh.salary, 1) OVER (
            PARTITION BY sh.employee_id 
            ORDER BY sh.effective_date ASC
        )) / LAG(sh.salary, 1) OVER (
            PARTITION BY sh.employee_id 
            ORDER BY sh.effective_date ASC
        )) * 100, 
        2
    ) AS percentage_increase
FROM salary_history sh
JOIN employees e ON sh.employee_id = e.employee_id
ORDER BY sh.employee_id, sh.effective_date ASC;

-- query lain untuk TASK 8 (Solution 8: Advanced CTE & Conditional Logic - Performance-to-Pay Matrix)
WITH ActiveCurrentSalaries AS (
    SELECT 
        e.employee_id,
        CONCAT(e.first_name, ' ', e.last_name) AS employee_name,
        sh.salary AS current_salary
    FROM employees e
    JOIN salary_history sh ON e.employee_id = sh.employee_id
    WHERE e.employment_status = 'Active'
      AND sh.effective_date = (
          SELECT MAX(sh_sub.effective_date)
          FROM salary_history sh_sub
          WHERE sh_sub.employee_id = e.employee_id
      )
),
AvgSalary AS (
    SELECT AVG(current_salary) AS company_avg_salary
    FROM ActiveCurrentSalaries
)
SELECT 
    acs.employee_id,
    acs.employee_name,
    pr.performance_rating,
    acs.current_salary,
    ROUND(avg_s.company_avg_salary, 2) AS company_avg_salary,
    CASE 
        WHEN pr.performance_rating = 5 AND acs.current_salary < avg_s.company_avg_salary 
            THEN 'High Performer - Below Avg Pay'
        WHEN pr.performance_rating = 5 AND acs.current_salary >= avg_s.company_avg_salary 
            THEN 'High Performer - Well Paid'
        ELSE 'Standard Performer'
    END AS compensation_category
FROM ActiveCurrentSalaries acs
LEFT JOIN performance_reviews pr 
    ON acs.employee_id = pr.employee_id 
   AND pr.review_year = 2024
CROSS JOIN AvgSalary avg_s
ORDER BY acs.employee_id;