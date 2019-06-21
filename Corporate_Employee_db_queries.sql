-- Corporate employee database 1980 - 1990
-- Create table schema for each of the six CSV files. 
-- specify data types, primary keys, foreign keys, and other constraints.

-- Drop tables if they already exist
DROP TABLE departments CASCADE;
DROP TABLE employees CASCADE;
DROP TABLE IF EXISTS dept_manager;
DROP TABLE IF EXISTS dept_emp;
DROP TABLE IF EXISTS titles;
DROP TABLE IF EXISTS salaries;

-- Create tables
CREATE TABLE departments (
  	dept_no VARCHAR(4) NOT NULL,
  	dept_name VARCHAR(20) NOT NULL,
	CONSTRAINT pk_departments PRIMARY KEY (dept_no)
);

CREATE TABLE employees (
  	emp_no INT NOT NULL,
	birth_date DATE,
  	first_name VARCHAR(20),
	last_name VARCHAR(20),
	gender CHAR(1) CHECK (gender IN ('M','F')),
	hire_date DATE,
	CONSTRAINT pk_employees PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
  	dept_no VARCHAR(4) NOT NULL,
  	emp_no INT NOT NULL,
	from_date DATE,
	to_date DATE,
	CONSTRAINT pk_dept_manager PRIMARY KEY (emp_no, dept_no),
	CONSTRAINT fk_dept_manager_dept FOREIGN KEY (dept_no)
		REFERENCES departments (dept_no),
	CONSTRAINT fk_dept_manager_emp FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

CREATE TABLE dept_emp (
  	emp_no INT NOT NULL,
	dept_no VARCHAR(4) NOT NULL,
  	from_date DATE,
	to_date DATE,
	CONSTRAINT pk_dept_emp PRIMARY KEY (emp_no, dept_no),
	CONSTRAINT fk_dept_emp_dept FOREIGN KEY (dept_no)
		REFERENCES departments (dept_no),
	CONSTRAINT fk_dept_emp_emp FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

CREATE TABLE salaries (
  	emp_no INT NOT NULL,
	salary INT,
	from_date DATE,
	to_date DATE,
	CONSTRAINT pk_salaries PRIMARY KEY (emp_no),
	CONSTRAINT fk_salaries FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

CREATE TABLE titles (
  	emp_no INT NOT NULL,
  	title character varying(30) NOT NULL,
	from_date DATE,
	to_date DATE,
	CONSTRAINT pk_titles PRIMARY KEY (emp_no, title),
	CONSTRAINT fk_titles FOREIGN KEY (emp_no)
		REFERENCES employees (emp_no)
);

-- Use DESC to confirm 'departments' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='departments';

-- Use DESC to confirm 'employees' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='employees';

-- Use DESC to confirm 'dept_manager' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='dept_manager';

-- Use DESC to confirm 'dept_emp' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='dept_emp';

-- Use DESC to confirm 'salaries' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='salaries';

-- Use DESC to confirm 'titles' table was created as intended
select column_name, data_type, character_maximum_length
from INFORMATION_SCHEMA.COLUMNS where table_name ='titles';

-- Import csv files for each table using the IMPORT/EXPORT tool

-- Data Analysis
-- 1. List the following details of each employee: employee number, last name, first name, gender, and salary.
-- Perform an INNER JOIN  on employees and salaries tables
-- Perform an INNER JOIN on the two tables
-- Make it a View and use SELECT * "view_name" to check
CREATE VIEW employee_name_gender_salary AS
SELECT e.emp_no, e.last_name, e.first_name, e.gender, s.salary
FROM employees AS e
INNER JOIN salaries AS s ON
e.emp_no = s.emp_no;

SELECT *
FROM employee_name_gender_salary;

--2. List employees who were hired in 1986.
-- Create a new view "employees_hired_1986"
CREATE VIEW employees_hired_1986 AS
SELECT emp_no, last_name, first_name, hire_date
FROM employees
WHERE '1986-01-01' <= hire_date
AND hire_date < '1987-01-01';

SELECT *
FROM employees_hired_1986
ORDER BY "hire_date" DESC;

-- 3. List the manager of each department with the following information:
-- department number, department name, the manager's employee number, last name, first name, and start and end employment dates.
--NOTE: still need to add dept name with one additional join with this view
CREATE VIEW department_managers AS
SELECT dm.dept_no, e.emp_no, e.last_name, e.first_name, dm.from_date, dm.to_date
FROM employees AS e
INNER JOIN dept_manager AS dm ON
e.emp_no =dm.emp_no;

SELECT *
FROM department_managers
ORDER BY "dept_no";


-- 4. List the department of each employee with the following information: 
--employee number, last name, first name, and department name.
--NOTE: Create a new view that joins the first view with the departments table on dept_no
CREATE VIEW department_employees AS
SELECT e.emp_no, e.last_name, e.first_name, de.dept_no
FROM employees AS e
INNER JOIN dept_emp AS de ON
e.emp_no =de.emp_no;

CREATE VIEW department_employees_with_dept_name AS
SELECT de.emp_no, de.last_name, de.first_name, de.dept_no, d.dept_name
FROM department_employees AS de
INNER JOIN departments AS d ON
de.dept_no =d.dept_no;

SELECT *
FROM department_employees_with_dept_name
ORDER BY dept_no;

