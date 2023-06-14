USE Cohort361;

-- Toady we'll get along with functions in SQL
-- To begin with this, we need to initialize the function usability first

SET GLOBAL log_bin_trust_function_creators = 1;
-- this ensures the creater to edit and make functions globally thorught the 
-- workbench
-- Actually, by default function creation is not allowed in SQL


-- Now see, you can't just simply execute the below code
-- to create a particular function
CREATE DEFINER=`root`@`localhost` 
FUNCTION `getNthHighestSalary`(N INT) RETURNS int
BEGIN
DECLARE M INTEGER;
SET M = N-1;
RETURN (
SELECT DISTINCT Salary from Employees order by Salary desc limit M,1 
);
END;

-- So, in order to create one, In the Navigator Section,
-- Go to Schemas and then Select the DB you are in
-- Then, right click on Functions under the DB and Create New
-- Now input the above script in the space provided and Apply
-- The function will we hence created

-- Now, see, we usually craete funtions to retun single valued
-- attributes. 
-- If you wanna store or return mpore than 1 rows then
-- it is preferred that you must use Views/Temporary Tables

SELECT * FROM Employees;

-- Calling the function
SELECT getNthHighestSalary(2);
-- now, each time this function is called, it'll return 
-- values based on the table, even after upodations/modifications

-- Trying Creating a function in SQL to return the sum of 
-- dept_id and manager_id for given employee id:

SELECT get_sum(103); 

-- Now using the Stored Procedure update_emp_sal
-- See the procedure created, for syntax

CALL update_emp_sal(101,95000);
-- So after using this, just as we expected, the stored procedure
-- modified the salary of employee just by calling it

-- MAIN DIFFERENCE BETWEEN Stored Procedures and Functions:
-- Functions have to have a RETURN value
-- But in case of Stored Procedures, we can execute the queries
-- without any requirement to return something.


-- Now let's see this case:
CREATE TABLE new_employee (
	emp_id int primary key,
    name varchar(200),
    age int,
    salary decimal(7,2),
    joining_date date,
    department varchar(200)
);

INSERT INTO new_employee (emp_id, name, age, salary, joining_date, department)
VALUES
    (1, 'John Doe', 30, 5000.00, '2022-01-01', 'Finance'),
    (2, 'Jane Smith', 35, 6000.00, '2021-09-15', 'HR'),
    (3, 'Michael Johnson', 28, 4500.00, '2022-03-10', 'Sales'),
    (4, 'Emily Davis', 32, 5500.00, '2022-02-20', 'Marketing'),
    (5, 'David Wilson', 40, 7000.00, '2021-07-01', 'IT'),
    (6, 'Sarah Brown', 27, 4000.00, '2022-05-05', 'Operations'),
    (7, 'Robert Lee', 33, 6000.00, '2022-01-15', 'Finance'),
    (8, 'Jennifer Clark', 31, 5500.00, '2022-04-02', 'HR'),
    (9, 'Daniel Taylor', 29, 4800.00, '2022-03-20', 'Sales'),
    (10, 'Olivia Moore', 34, 6500.00, '2021-12-10', 'Marketing');

-- Q) Find out the percentage of expenditure for every department

WITH A AS
(SELECT department, SUM(salary) as summ FROM new_employee
GROUP BY department)
SELECT department, 
(summ/(SELECT SUM(salary) FROM new_employee)*100) AS Sal_Per
FROM A;


-- Now done a litte bit editing in the creation of 
-- Stored Procedure.. So basically, added a varibale that 
-- Increases the emp_id by 1 and then pasess it to the 
-- update procedure

SELECT * FROM employees;
-- Now let us assume we want to edit for 103, so 
-- we'll enter 102 (prev sal 140000)
CALL new_update_sal(102,145000);
-- So see, after declaring the varibale to inc
-- sal for an ID, we get the updated version for iD+1

-- So just a usecase of using variables.

-- ---------------------------------------------------------------
-- From the given data, find the highest, second highest, so on
-- salaries without using RANK function
-- Also, handle ties (if two emps with same sal, display both)

CREATE TABLE employee2 (
  emp_id int NOT NULL AUTO_INCREMENT,
  depname varchar(200),
  empno int,
  salary decimal(7,2),
  PRIMARY KEY (emp_id)
);

DROP TABLE employee2;

INSERT INTO employee2 (depname, empno, salary)
VALUES
  ('develop', 11, 5200),
  ('develop', 7, 4200),
  ('develop', 9, 4500),
  ('develop', 8, 6000),
  ('develop', 10, 5200),
  ('personnel', 5, 3500),
  ('personnel', 2, 3900),
  ('sales', 3, 4800),
  ('sales', 1, 5000),
  ('sales', 4, 4800);
  
-- Hightest Salary
SELECT empno FROM employee2 WHERE salary = 
(SELECT MAX(salary) FROM employee2);
  
-- Second Highest Salary
WITH A AS
(SELECT empno, salary FROM employee2 WHERE salary < 
(SELECT MAX(salary) FROM employee2))
SELECT empno FROM A WHERE salary = 
(SELECT MAX(salary) FROM A);

-- Let's discuss about different types of SQL Queries
-- which are usually used

-- Questions can be of types:
-- 1 Time Constraints
-- 2 Calculations/Requirements
-- 3 Comparisions/Ranking 

-- Eg of SQL query types:  
--      SELECT all
--      SELECT something 
--      SELECT everything except something

-- So, try to resolve any question in either of these formats

-- COLUMNS : (Playerid, deviceid, timestamp, game_no_played)
-- Find the first login and logout for each game played and each player
-- Example of Time Constraint Problem:

CREATE TABLE game_table(
player_id INTEGER,                
deviceid INTEGER,
timestamp DATETIME,
game_no_played INTEGER
);

INSERT INTO game_table VALUES
(1,2,'2022-10-12 12:00:00',2),
(1,3,'2022-10-12 16:30:00',1),
(2,1,'2022-10-12 09:00:00',3),
(1,2,'2022-10-13 12:45:00',2),
(2,2,'2022-10-22 22:11:00',1),
(2,2,'2022-10-23 23:11:00',1),
(1,2,'2022-10-25 00:35:00',3),
(1,2,'2022-10-25 10:45:00',1);


WITH A AS
(SELECT game_no_played, player_id, DATE(timestamp) AS Dateplayed,
TIME(timestamp) AS Timeplayed FROM game_table), B AS
(SELECT game_no_played, player_id, MIN(Dateplayed) AS First_Day
FROM A GROUP BY game_no_played, player_id)
SELECT B.game_no_played, B.player_id, B.First_Day, 
MIN(TIME(timestamp)) AS Start_Time,
MAX(TIME(timestamp)) AS End_Time FROM B JOIN game_table
ON B.player_id = game_table.player_id
WHERE B.First_Day = DATE(game_table.timestamp)
GROUP BY B.game_no_played, B.player_id, B.First_Day 
ORDER BY Start_Time;

-- --------------------------------------------------------

-- Creating Tables Actions and Removals

CREATE TABLE actions(
user_id INTEGER,
post_id INTEGER,
action_date DATE,
action_type VARCHAR(20),
extra VARCHAR(20)
);

INSERT INTO actions VALUES
(1,2,'2023-01-01',"post","none"),
(2,2,'2023-01-01',"comment","none"),
(3,2,'2023-01-01',"report","spam"),
(2,3,'2023-01-02',"post","none"),
(1,3,'2023-01-02',"report","racism"),
(4,4,'2023-01-02',"post","none"),
(5,4,'2023-01-03',"report","spam"),
(5,4,'2023-01-03',"comment","none"),
(6,5,'2023-01-04',"post","none");

CREATE TABLE removals(
post_id INTEGER,
removal_date DATE
);

INSERT INTO removals VALUES
(2,'2023-01-01'),
(3,'2023-01-02'),
(4,'2023-01-04');

SELECT * FROM actions;
SELECT * FROM removals;

-- Selecting the Posts which are removed
-- On the same date as their repoting and
-- are of the type "Spam"

SELECT post_id, action_date FROM actions
WHERE action_type = 'report' AND extra = 'spam';

-- Now, selecting only the reports which were 
-- deleted on the same day.

WITH A AS
(SELECT post_id, action_date FROM actions
WHERE action_type = 'report' AND extra = 'spam')
SELECT A.post_id FROM A JOIN removals ON
A.post_id = removals.post_id WHERE
A.action_date = removals.removal_date;

-- Now finding what percentage of total reports are
-- removed the same day where type is spam
-- no. of removals / total spam report * 100

WITH A AS
(SELECT post_id, action_date FROM actions
WHERE action_type = 'report' AND extra = 'spam'),
B AS
(SELECT COUNT(A.post_id) AS same_removal_count 
FROM A JOIN removals ON
A.post_id = removals.post_id WHERE
A.action_date = removals.removal_date)
SELECT (same_removal_count/(SELECT COUNT(*) 
FROM actions WHERE action_type = 'report' 
AND extra = 'spam')*100) AS same_day_remove_percent
FROM B;

-- Sir's version:
SELECT ROUND(AVG(percent), 2) AS average_daily_percent
FROM (
  SELECT COUNT(r.post_id) * 100.0 / COUNT(a.post_id) AS percent
  FROM Actions a
  LEFT JOIN Removals r ON a.post_id = r.post_id
  WHERE a.action_type = 'report' AND a.extra = 'spam'
  GROUP BY a.action_date
) subquery;

SELECT * FROM actions;

-- --------------------------------------------------
CREATE TABLE add_table(
ad_id INT,
user_id INT,
action_type VARCHAR(10)
);

INSERT INTO add_table VALUES
(1,1,'clicked'),
(2,2,'clicked'),
(3,3,'viewed'),
(5,5,'ignored'),
(1,7,'ignored'),
(2,7,'viewed'),
(3,5,'clicked'),
(1,4,'viewed'),
(2,11,'viewed'),
(1,2,'clicked');

WITH A AS
(SELECT ad_id, COUNT(ad_id) AS clicks FROM add_table 
WHERE action_type = "clicked" GROUP BY ad_id),
B AS
(SELECT ad_id, COUNT(ad_id) AS not_clicks FROM add_table
WHERE action_type != "clicked" GROUP BY ad_id),
C AS
(SELECT B.ad_id, A.clicks, B.not_clicks FROM
A RIGHT JOIN B ON A.ad_id = B.ad_id)
SELECT ad_id, (clicks/not_clicks)*100 AS ctr
FROM C;

-- Another Answer: (review this -- it's actually good)
select
ad_id,round(avg(case when action_type='Clicked' then 1 
else 0 
end
)*100,2) as ctr
from Add_table
group by ad_id
order by ctr desc;

-- Sir's:
SELECT ad_id, ROUND(COUNT(CASE WHEN action = 'Clicked' THEN 1 END) * 100.0 / COUNT(*) , 2) AS ctr
FROM Ads
GROUP BY ad_id
ORDER BY ctr DESC, ad_id ASC;


















