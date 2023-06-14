use Cohort361;

select * from student;
select distinct username, gender from student;
-- Here, DISTINCT col1, col2 creates unique pairs of those columns
-- BUT
-- select DISTINCT username, DISTINCT gender from student;
-- THIS is not possible (as it will contradict the repeated values
-- in one column to the non-repeated values of the other column)



CREATE TABLE employees (
  employee_id INT NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(255) NOT NULL,
  last_name VARCHAR(255) NOT NULL,
  dept_id INT NOT NULL,
  manager_id INT,
  salary INT NOT NULL,
  expertise VARCHAR(255) NOT NULL,
  PRIMARY KEY (employee_id)
);

INSERT INTO employees (employee_id, first_name, last_name, dept_id, 
manager_id, salary, expertise) VALUES
(100, 'John', 'White', 103, 103, 120000, 'Senior'),
(101, 'Mary', 'Danner', 109, 109, 80000, 'Junior'),
(102, 'Ann', 'Lynn', 107, 107, 140000, 'Semisenior'),
(103, 'Peter', 'Oconnor', 110, 110, 130000, 'Senior'),
(106, 'Sue', 'Sanchez', 107, 107, 110000, 'Junior'),
(107, 'Marta', 'Doe', 110, 110, 180000, 'Senior'),
(109, 'Ann', 'Danner', 110, 110, 90000, 'Senior'),
(110, 'Simon', 'Yang', 110, NULL, 250000, 'Senior');

INSERT INTO employees (employee_id, first_name, last_name, dept_id, 
manager_id, salary, expertise) VALUES
(111, 'George', 'Reynolds', 103, 103, 120000, 'Senior');

-- RANKING IN MySQL
-- Now ordering is fine but if we wanna rank the contents of a table
-- based on a particular column or even more than one columns.

select employee_id, last_name, first_name, salary,
rank() over(order by salary desc) as rank_emp from employees
order by rank_emp limit 5;

-- The above query will show the ranked table (with top 5 entries as limit is used)
-- Now this is RANK() so if two values are given the same value, they'll have the 
-- same rank and the rest will be skipped until a different value.
-- LIKE:
-- A 20 1
-- B 30 2
-- C 30 2
-- D 35 4   * notice the absence of 3
-- Solution : DENSE_RANK()

-- Now, if you wanna LIMIT without using LIMIT then rank can be used:

with cte as
(select employee_id, last_name, first_name, salary,
rank() over(order by salary desc) as rank_emp from employees)
select employee_id, last_name, first_name, salary from cte 
where rank_emp <= 5;

-- * So that's the same output but kinda different approach

-- Now, usecase of DENSE_RANK()
select employee_id, last_name, first_name, salary,
dense_rank() over(order by salary desc) as rank_emp from employees; 

-- Here we can notice that even there are 2 5th ranks, the 6th 
-- one is not skipped
-- So this is a better ranking method with no gaps in between

-- PARTITION BY

-- Now suppose, we need the details of all employees who have second 
-- highest salary in each department. So we'll have to partition the departments
-- as well. 

with cte1 as 
(select employee_id, dept_id, last_name, first_name, salary,
rank() over(partition by dept_id order by salary desc) as rank_emp 
from employees) select dept_id, employee_id, last_name, first_name, salary
from cte1 where rank_emp = 2;

-- This partition by is creating the view.. It's not actually 
-- creating the partitions

-- Now if we want to give a unique identity to reach row irrespective or
-- repetative values then we can use ROW_NUMBER()

select employee_id, dept_id, last_name, first_name, salary,
row_number() over(order by salary desc) as rownumber from employees;

-- Here we can also partition just like rank and dense rank


-- SHOW all roes who are above average salary
select * from employees where salary > (select avg(salary) from employees);


-- SELF JOIN or EQUI JOIN (joining the table with itself)
-- Suppose you need to find the manager for each employee from the 
-- same table itself based on their employee ids:
select concat(e1.first_name,' ',e1.last_name) as EmployeeName,
concat(e2.first_name,' ',e2.last_name) as ManagerName
from employees e1 join employees e2
where e1.employee_id = e2.manager_id;

-- To Reduce the cost of concat operation,
-- CONCAT_WS() can be used

-- ANOTHER important concept is that we can find the duplicate rows using the 
-- group by as:
select  last_name , first_name , dept_id , manager_id, salary from employees
group by  last_name , first_name , dept_id , manager_id, salary
having count(*) > 1;
-- So after grouping if the count of that particular row is greater than 0,
-- then it'll be considered as duplicate

-- EXPLAIN:
-- This can be added before any query to acquire the details of the current query
-- like:
explain select concat(e1.first_name,' ',e1.last_name) as EmployeeName,
concat(e2.first_name,' ',e2.last_name) as ManagerName
from employees e1 join employees e2
where e1.employee_id = e2.manager_id;

-- Creating a Function in SQL

CREATE FUNCTION getNthHighestSalary(N INT) RETURNS INT
BEGIN
DECLARE M INT;
SET M = N-1;
RETURN 
(SELECT DISTINCT Salary from Employees order by Salary desc limit M,1 )
END

-- This wont run here, you'll need to create a function from the Schemas
-- side and then paste the above query there Refer : 23-05-23 