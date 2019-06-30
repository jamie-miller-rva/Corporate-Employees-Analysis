-- SQL Script (and Schema) for Corporate Employee db and queries
-----------------------------------------------------------------------------------------------------------------------
-- CORPORATE-EMPLOYEE-ANALYSIS
-----------------------------------------------------------------------------------------------------------------------

-- Given six csv files from the Corporate employee database from 1980 - 1990
-- Create table schema for each of the six CSV files the includes: 
-- data types, primary keys, foreign keys, and other constraints.

-- Drop tables if they already exist
-- Note: the use of CASCADE is to drop a table that contains a primary key listed
-- in another table as a foreign key
DROP TABLE departments CASCADE;
DROP TABLE employees CASCADE;
DROP TABLE IF EXISTS dept_manager;
DROP TABLE IF EXISTS dept_emp;
DROP TABLE IF EXISTS titles;
DROP TABLE IF EXISTS salaries;

-- Create table
CREATE TABLE departments (
  	dept_no VARCHAR(4) NOT NULL,
  	dept_name VARCHAR(20) NOT NULL,
	CONSTRAINT pk_departments PRIMARY KEY (dept_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY departments(dept_no, dept_name)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\departments.csv' DELIMITER ',' CSV HEADER;

-- View the table to confirm import results
SELECT *
FROM departments;

-- Create table
CREATE TABLE employees (
  	emp_no INT NOT NULL,
	birth_date DATE,
  	first_name VARCHAR(20),
	last_name VARCHAR(20),
	gender CHAR(1) CHECK (gender IN ('M','F')),
	hire_date DATE,
	CONSTRAINT pk_employees PRIMARY KEY (emp_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY employees(emp_no, birth_date, first_name, last_name, gender, hire_date)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\employees.csv' DELIMITER ',' CSV HEADER;

-- View the table to confirm import results
SELECT *
FROM employees;

-- Create table
CREATE TABLE dept_manager (
  	dept_no VARCHAR(4) NOT NULL,
  	emp_no INT NOT NULL,
	from_date DATE,
	to_date DATE,
	CONSTRAINT fk_dept_manager_dept FOREIGN KEY (dept_no)
		REFERENCES departments (dept_no),
	CONSTRAINT fk_dept_manager_emp FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY dept_manager(dept_no, emp_no, from_date, to_date)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\dept_manager.csv' DELIMITER ',' CSV HEADER;

-- View the table to confirm import results
SELECT *
FROM dept_manager;

-- Create table
CREATE TABLE dept_emp (
  	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
  	from_date DATE,
	to_date DATE,
	CONSTRAINT fk_dept_emp_dept FOREIGN KEY (dept_no)
		REFERENCES departments (dept_no),
	CONSTRAINT fk_dept_emp_emp FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY dept_emp(emp_no, dept_no, from_date, to_date)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\dept_emp.csv' DELIMITER ',' CSV HEADER;

--View the table to confirm import results
SELECT *
FROM dept_emp;

-- Create table
CREATE TABLE salaries (
  	emp_no INT NOT NULL,
	salary INT,
	from_date DATE,
	to_date DATE,
	CONSTRAINT fk_salaries FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY salaries(emp_no, salary, from_date, to_date)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\salaries.csv' DELIMITER ',' CSV HEADER;

--View the table to confirm import results
SELECT *
FROM salaries;

-- Create table
CREATE TABLE titles (
  	emp_no INT NOT NULL,
  	title character varying(30) NOT NULL,
	from_date DATE,
	to_date DATE,
	CONSTRAINT fk_titles FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

-- Import data from C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data
COPY titles(emp_no, title, from_date, to_date)
FROM 'C:\Users\jamie\RICH201904DATA3\9-SQL\Homework\data\titles.csv' DELIMITER ',' CSV HEADER;

--View the table to confirm import results
SELECT *
FROM titles;

-----------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
-- DATA ANALYSIS

-- 1. List the following details of each employee: employee number, last name, first name, gender, and salary.
-- Perform an INNER JOIN  on employees and salaries tables on emp_no
-- Make it a View and use SELECT * FROM "view_name" to review results
CREATE VIEW employee_name_gender_salary AS
SELECT e.emp_no, e.last_name, e.first_name, e.gender, s.salary
FROM employees AS e
INNER JOIN salaries AS s 
ON e.emp_no = s.emp_no
ORDER BY s.salary DESC;

SELECT *
FROM employee_name_gender_salary;

--2. List employees who were hired in 1986.
-- Two methods shown using BETWEEN or the <= and <=
-- Create a new view "employees_hired_1986"
CREATE VIEW employees_hired_1986 AS
SELECT emp_no, last_name, first_name, hire_date
FROM employees
WHERE '1986-01-01' <= hire_date
AND hire_date <= '1986-12-31'
ORDER BY hire_date;

SELECT *
FROM employees_hired_1986
ORDER BY hire_date;

-- Note: alternate method is to use BETWEEN
-- Note: dates are inclusive when using BETWEEN
SELECT emp_no, last_name, first_name, hire_date
FROM employees
WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31'
ORDER BY hire_date;



-- 3. List the manager of each department with the following information:
-- department number, department name, the manager's employee number, 
-- last name, first name, and start and end employment dates.
-- This can be done a number of ways.  Two methods are shown (in two steps and one step)
-- Two step process to join three tables; step one join two talbles and create a view, step two join this new view with a table
-- Join dept_manager with employee tables and create view department_managers (first step)
-- Join view department_managers with table department and create view department_managers_dept (second step)

-- Step One
CREATE VIEW department_managers AS
SELECT dm.dept_no, e.emp_no, e.last_name, e.first_name, dm.from_date, dm.to_date
FROM employees AS e
INNER JOIN dept_manager AS dm ON
e.emp_no =dm.emp_no;

-- View created view to confirm join was performed
SELECT *
FROM department_managers
ORDER BY dept_no;

-- Step Two
-- Join view with table "departments" and create a new view                   
CREATE VIEW department_managers_dept AS
SELECT dm.dept_no, d.dept_name, dm.emp_no, dm.last_name, dm.first_name, dm.from_date, dm.to_date
FROM department_managers AS dm
INNER JOIN departments AS d ON
dm.dept_no =d.dept_no;

-- View the created view to confirm join was performed
SELECT *
FROM department_managers_dept
ORDER BY dept_name;

-- Alternative method linking three tables using subqueries
CREATE VIEW department_managers_alternative AS
SELECT dm.dept_no, d.dept_name, e.emp_no, e.last_name, e.first_name, dm.from_date, dm.to_date
FROM employees AS e INNER JOIN dept_manager AS dm ON
	e.emp_no =dm.emp_no
	INNER JOIN departments as d
	On dm.dept_no = d.dept_no
ORDER BY d.dept_name, dm.from_date;

SELECT *
FROM department_managers_alternative;
-- 4. List the department of each employee with the following information: 
--employee number, last name, first name, and department name.

CREATE VIEW department_employees AS
SELECT d.dept_name, de.dept_no, e.emp_no, e.last_name, e.first_name
FROM employees AS e
INNER JOIN dept_emp AS de 
	ON e.emp_no =de.emp_no
	INNER JOIN departments as d
	ON de.dept_no = d.dept_no
ORDER BY d.dept_name, e.last_name, e.first_name;

SELECT *
FROM department_employees;

--5. List all employees whose 
-- first name is "Hercules" and last names begin with "B."
-- NOTE: Use LIKE and wildcard % to find last names begin with B
CREATE VIEW hercules_b AS
SELECT emp_no, first_name, last_name
FROM employees
WHERE first_name = 'Hercules'
	AND last_name LIKE 'B%'
ORDER BY emp_no;

SELECT *
FROM hercules_b
ORDER BY emp_no;

-- 6. List all employees in the Sales department, 
-- including their employee number, last name, first name, and department name.
-- NOTE: This is an example of linking three tables (employee, department, dept_emp)for one query.
CREATE VIEW employees_sales_dept AS
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name 
FROM employees AS e INNER JOIN dept_emp AS de
	ON e.emp_no = de.emp_no
	INNER JOIN departments As d
	ON de.dept_no = d.dept_no
WHERE d.dept_name ='Sales';

SELECT *
FROM employees_sales_dept
ORDER BY last_name;

-- 7. List all employees in the Sales and Development departments, 
-- including their employee number, last name, first name, and department name.
CREATE VIEW employees_sales_and_development AS
SELECT e.emp_no, e.last_name, e.first_name, d.dept_name
FROM employees AS e INNER JOIN dept_emp AS de
	ON e.emp_no = de.emp_no
	INNER JOIN departments AS d
	ON de.dept_no = d.dept_no
WHERE d.dept_name IN ('Sales', 'Development')
ORDER BY d.dept_name, e.last_name, e.emp_no;

SELECT *
FROM employees_sales_and_development;

--8. In descending order, list the frequency count of employee last names,
-- i.e., how many employees share each last name.
-- This is an example of Grouping and Aggregates
CREATE VIEW employees_freq_lastnames AS
SELECT last_name, COUNT(*) how_many
FROM employees
GROUP BY last_name
ORDER BY how_many DESC;

SELECT *
FROM employees_freq_lastnames;

-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------
-- BONUS 
-- As you examine the data, you are overcome with a creeping suspicion that the dataset is fake. You surmise that your boss handed you spurious data in order to test the data engineering skills of a new employee. To confirm your hunch, you decide to take the following steps to generate a visualization of the data, with which you will confront your boss:
--1. Direction and Guidance: Import the SQL database into Pandas. This step may require some research. Feel free to use the code below to get started. Be sure to make any necessary modifications for your username, password, host, port, and database name:
-- ```sql
-- from sqlalchemy import create_engine
-- engine = create_engine('postgresql://localhost:5432/<your_db_name>')
-- connection = engine.connect()
-- ```
--* Consult [SQLAlchemy documentation](https://docs.sqlalchemy.org/en/latest/core/engines.html#postgresql) for more information.
--* If using a password, do not upload your password to your GitHub repository. See [https://www.youtube.com/watch?v=2uaTPmNvH0I](https://www.youtube.com/watch?v=2uaTPmNvH0I) and [https://martin-thoma.com/configuration-files-in-python/](https://martin-thoma.com/configuration-files-in-python/) for more information.

--1. As executed: Create a new view called corporate_emp_analysis_that includes 
-- the columns listed below from the following tables:
-- employees AS e, dept_emp AS de, departments AS d, titles AS t, salaries AS s:
--and the following columns:
--e.emp_no, e.gender, e.hire_date, de.dept_no, d.dept_name, t.title, s.salary

-- Export the view as a .csv file and then import into pandas using 
-- SLQAlchemy

--2. Create a bar chart of average salary by title using pandas.
--3. include a technical report in markdown format, in which you outline the data engineering steps taken.--

-- Create a view for the resulting query
-- Join the title and salary tables on emp_no
CREATE VIEW salary_by_title AS
SELECT t.title, s.salary
FROM salaries AS s
INNER JOIN titles as t
ON s.emp_no = t.emp_no
ORDER BY t.title, s.salary;
                          
SELECT DISTINCT title
FROM salary_by_title;
                        
-- How many unique (DISTINCT titles are there?)
-- Resulting view shows 7 unique titles
CREATE VIEW distinct_titles AS
SELECT DISTINCT title
FROM salary_by_title
ORDER BY title;

-- Create view for the resulting query
-- Find max and min salary for each title
-- Group By title
CREATE VIEW salary_by_unique_title AS
SELECT title,
	MAX(salary) max_salary,
	MIN(salary) min_salary,
	AVG(salary) avg_salary
FROM salary_by_title
GROUP BY title
ORDER BY max_salary DESC;



------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
-- ## Epilogue
-- Evidence in hand, you march into your boss's office and present the visualization. 
-- With a sly grin, your boss thanks you for your work. On your way out of the office, you hear the words, 
-- "Search your ID number." You look down at your badge to see that your employee ID number is 499942.

CREATE VIEW your_employee_no AS
SELECT *
FROM employees
WHERE emp_no = 499942;

SELECT * 
FROM your_employee_no;
-- "April Fools"

