-- Creating tables for PH-EmployeeDB
CREATE TABLE departments (
     dept_no VARCHAR(4) NOT NULL,
     dept_name VARCHAR(40) NOT NULL,
     PRIMARY KEY (dept_no),
     UNIQUE (dept_name)
);

CREATE TABLE employees (emp_no INT NOT NULL,
     birth_date DATE NOT NULL,
     first_name VARCHAR NOT NULL,
     last_name VARCHAR NOT NULL,
     gender VARCHAR NOT NULL,
     hire_date DATE NOT NULL,
     PRIMARY KEY (emp_no)
);

CREATE TABLE dept_manager (
    dept_no VARCHAR(4) NOT NULL,
    emp_no INT NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
    PRIMARY KEY (emp_no, dept_no)
);

CREATE TABLE salaries (
  emp_no INT NOT NULL,
  salary INT NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no)
);

-- With keys, you want fewest number that still gives you def

CREATE TABLE dept_emp (
  emp_no INT NOT NULL,
  dept_no VARCHAR(4) NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  FOREIGN KEY (dept_no) REFERENCES departments (dept_no),
  PRIMARY KEY (emp_no,dept_no)
);

CREATE TABLE titles (
  emp_no INT NOT NULL,
  title VARCHAR NOT NULL,
  from_date DATE NOT NULL,
  to_date DATE NOT NULL,
  FOREIGN KEY (emp_no) REFERENCES employees (emp_no),
  PRIMARY KEY (emp_no, from_date, to_date)
);


-- Successfully imported and executed.
SELECT * FROM departments;
SELECT * FROM employees;
SELECT * FROM salaries;
SELECT * FROM dept_emp;
SELECT * FROM dept_manager;
SELECT * FROM titles;

-- Anyone born between 1952 and 1955 
SELECT first_name,last_name
FROM employees 
WHERE birth_date BETWEEN '1952-01-01' AND '1955-12-31';

-- Employees born in 1952, also hired 1985-1988
SELECT first_name, last_name
FROM employees
WHERE birth_date BETWEEN '1952-01-01' AND '1952-12-31'
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Number of employees retiring
SELECT COUNT(first_name)
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- Save retirement folks into a table
SELECT first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- View results
SELECT * FROM retirement_info;

-- Number of people retiring soon.= 41,380 (include people who may have retired already)
SELECT count(emp_no) FROM retirement_info;

-- Do an inner join on Departments and Managers to find the manager for each department
SELECT d.dept_name, dm.emp_no, 
dm.from_date, dm.to_date
FROM departments as d
INNER JOIN dept_manager as dm
ON d.dept_no = dm.dept_no;

-- Figure out if any of these people are retired by linking to the dept_emp
SELECT * FROM dept_emp;

-- View retirement info with employee end dates to see 
-- who is no longer with the company.
SELECT ri.emp_no,
ri.first_name, ri.last_name, 
de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- Number of people retiring soon. = 33,118
SELECT count(ri.emp_no)
FROM retirement_info as ri
LEFT JOIN dept_emp as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');

-- dept_emp is a list of all 331,603 employees and their departments 
SELECT * FROM dept_emp;

-- Group the retiring people by department
SELECT count(ce.emp_no), de.dept_no
INTO ret_dept
FROM current_emp as ce
LEFT JOIN dept_emp as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;

--
SELECT * FROM salaries
ORDER BY to_date DESC;

SELECT * FROM dept_emp
ORDER BY to_date DESC;


-- Regrab retiring folks + their gender
SELECT emp_no, first_name, last_name,
gender
INTO emp_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');

-- View new table
SELECT * FROM emp_info;
SELECT * FROM salaries;

-- Drop table
DROP TABLE emp_info;

-- What we need: 
SELECT e.emp_no, e.first_name, e.last_name,
e.gender, s.salary, de.to_date
INTO emp_info
FROM employees as e
	INNER JOIN salaries as s
	ON e.emp_no = s.emp_no
	INNER JOIN dept_emp as de
	ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = ('9999-01-01'));

-- Management: A list of managers for each department, including the 
-- department number, name, and the manager's
-- employee number, last name, first name, and the starting and ending employment dates

-- Tables to use:
-- employees (first_name, last_name)
-- departments (dept_name)
-- dept_manager (from_date, to_date)

-- List of managers per department
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
	
-- Previous try
SELECT d.dept_no,
d.dept_name,
dm.emp_no, 
ce.first_name,
ce.last_name,
dm.from_date,
dm.to_date
INTO manager_info
FROM departments as d
	INNER JOIN current_emp as ce
	ON d.dept_no = e.dept_no
	INNER JOIN dept_manager as dm
	ON d.emp_no = dm.emp_no

SELECT * FROM manager_info;

-- Add department names to the current_emp list
-- current_emp.emp_no --> dept_emp.emp_no --> dept_emp.dept_no --> departments.dept_no(dept_name)


-- Gabby's codes. Which one is better? 303 msec. 36,619
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info_test
FROM dept_emp as de
	INNER JOIN departments as d
	ON de.dept_no = d.dept_no
	INNER JOIN current_emp as ce
	ON de.emp_no = ce.emp_no;
SELECT * FROM dept_info_test;


SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info_test
FROM dept_emp as de
	INNER JOIN current_emp as ce
	ON de.emp_no = ce.emp_no
	INNER JOIN departments as d
	ON de.dept_no = d.dept_no;
SELECT * FROM dept_info_test;

-- Module code. 514 msec. 36,619
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO dept_info
FROM current_emp as ce
	INNER JOIN dept_emp AS de
	ON (ce.emp_no = de.emp_no)
	INNER JOIN departments AS d
	ON (de.dept_no = d.dept_no);
SELECT * FROM dept_info;

-- Create a list of only Sales people retiring
-- curent_emp -- (emp_no)--> dept_emp -- (dept_no) -- > departments 
-- WHERE departments.dept_name = 'Sales'

-- 5,860 retiring employees in Sales
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO sales_ret
FROM dept_emp as de
	INNER JOIN current_emp as ce
	ON (de.emp_no = ce.emp_no)
	INNER JOIN departments as d
	ON (de.dept_no = d.dept_no)
	WHERE (d.dept_name = 'Sales');
SELECT count(*) FROM sales_ret;

-- Sales and Development people retiring. -- 15,141 people
DROP TABLE sales_dev_ret;
SELECT ce.emp_no,
ce.first_name,
ce.last_name,
d.dept_name
INTO sales_dev_ret
FROM dept_emp as de
	INNER JOIN current_emp as ce
	ON (de.emp_no = ce.emp_no)
	INNER JOIN departments as d
	ON (de.dept_no = d.dept_no)
	WHERE d.dept_name IN ('Sales','Development');
SELECT * FROM sales_dev_ret;

-- Use Dictinct with Orderby to remove duplicate rows
SELECT DISTINCT ON (ri.emp_no) ri.emp_no,
ri.first_name,
ri.last_name,
ri.title
INTO unique_titles
FROM ret_info as ri
ORDER BY ri.emp_no, ri.to_date DESC;


-- Why does this not work?
SELECT * FROM unique_titles;
GROUP BY unique_titles.title;