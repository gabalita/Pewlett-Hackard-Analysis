-- View tables.
SELECT * FROM titles; -- 443,308 employees at company. 
SELECT * FROM current_emp; -- 33,188 employees retiring. 

-- Get list of employees retiring + their title
-- Join employees & titles via emp_no

DROP TABLE ret_info;
SELECT e.emp_no,  -- 133,776 employees
e.first_name,
e.last_name,
ti.title,
ti.from_date,
ti.to_date
INTO ret_info
FROM employees as e
	INNER JOIN titles as ti
	ON (e.emp_no = ti.emp_no)
	WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
	ORDER BY e.emp_no;

SELECT * FROM ret_info;

-- Use Dictinct ON with Orderby to remove duplicate rows
SELECT DISTINCT ON (ri.emp_no) ri.emp_no,
ri.first_name,
ri.last_name,
ri.title
INTO unique_titles
FROM ret_info as ri
ORDER BY ri.emp_no, ri.to_date DESC;

-- Get total count of each job title
SELECT count(ut.title),ut.title
INTO retiring_titles
FROM unique_titles as ut
GROUP BY ut.title
ORDER BY count(ut.title) DESC;

-- Get mentorship_eligibility table
SELECT DISTINCT ON(e.emp_no) e.emp_no,
e.first_name,
e.last_name,
e.birth_date,
de.from_date,
de.to_date,
ti.title
INTO ment_elig
FROM employees as e
	INNER JOIN dept_emp as de
	ON (e.emp_no = de.emp_no)
	INNER JOIN titles as ti
	ON (e.emp_no = ti.emp_no)
WHERE e.birth_date BETWEEN '1965-01-01' AND '1965-12-31'
AND de.to_date = '9999-01-01'
ORDER BY e.emp_no;

