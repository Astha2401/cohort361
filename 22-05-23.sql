use Cohort361;

CREATE TABLE nodes (
  node_id INT NOT NULL AUTO_INCREMENT,
  parent_id INT,
  PRIMARY KEY (node_id)
);

INSERT INTO nodes (node_id, parent_id) VALUES
(1, 2),
(2, 5),
(3, 5),
(4, 3),
(5, NULL);

-- Select number of children nodes for each node available
-- And also their parent node's id

WITH join_node AS (SELECT cur.node_id, cur.parent_id, 
COUNT(next.node_id) AS num_children FROM nodes cur
LEFT JOIN nodes next ON (next.parent_id = cur.node_id) 
GROUP BY cur.node_id, cur.parent_id)
SELECT node_id, 
CASE WHEN parent_id IS NULL THEN "Root"
WHEN num_children = 0 THEN "Leaf"
ELSE "Inner" END AS Node_Type
FROM  join_node;

-- Once we'll get the inner query, we'll be able to get the parent node 
-- for each node and also the number of child nodes for each node.
-- Now, by using this info, we can easily find the type of node for each node
-- if parent node is null then ROOT
-- if no. of child nodes is zero then LEAF
-- otherwise, it'll be INNER node
-- So, case when is used to do the above thing


CREATE TABLE user_activity (
  user_id INT NOT NULL,
  date DATE NOT NULL,
  PRIMARY KEY (user_id, date)
);

INSERT INTO user_activity (user_id, date) VALUES
(1, '2018-07-01'),
(234, '2018-07-02'),
(3, '2018-07-02'),
(1, '2018-07-02'),
(234, '2018-10-04');

INSERT INTO user_activity (user_id, date) VALUES
(1, '2018-06-01');
INSERT INTO user_activity (user_id, date) VALUES
(234, '2018-06-01');

-- To find the retained users in the table.
-- The users which have logged in the current month as well as the 
-- previous month

WITH a AS
(SELECT user_id, MONTH(date) AS Logged_Month, YEAR(date) AS Logged_Year 
FROM user_activity),
B AS
(SELECT user_id, Logged_Month, Logged_Year, LAG(Logged_Month) OVER() AS Prev_Month,
LAG(Logged_Year) OVER() AS Prev_Year
FROM a)
SELECT COUNT(user_id) AS Retained_Users FROM B WHERE Prev_Month = Logged_Month - 1 
OR ((Prev_Month = 12 AND Logged_Month = 1) AND (Prev_Year = Logged_Year - 1));

-- Sir:
SELECT EXTRACT(DAY FROM a.date) AS day_timestamp, 
COUNT(distinct a.user_id) AS retained_users FROM user_activity a
JOIN user_activity b ON a.user_id = b.user_id 
AND EXTRACT(DAY FROM a.date) = 
EXTRACT(DAY FROM b.date) + 1
GROUP BY EXTRACT(MONTH FROM a.date), a.date, a.user_id;

-- Use Extract in the Above Query to make things work right.
SELECT EXTRACT(MONTH FROM '22-10-18');

-- Now if we wanna find out the non-retained users (number 
-- of churned users), in that case we can 
-- just update the condition by verifying that the previous month is not
-- equal to the next month;

WITH a AS
(SELECT user_id, MONTH(date) AS Logged_Month, YEAR(date) AS Logged_Year 
FROM user_activity),
B AS
(SELECT user_id, Logged_Month, Logged_Year, LAG(Logged_Month) OVER() AS Prev_Month,
LAG(Logged_Year) OVER() AS Prev_Year
FROM a)
SELECT COUNT(user_id) AS Retained_Users FROM B WHERE Prev_Month != Logged_Month - 1 
OR ((Prev_Month = 12 AND Logged_Month = 1) AND (Prev_Year != Logged_Year - 1));

-- Another way can be using sir's query and changing the join condition

-- In MySQL, FULL OUTER JOIN DOES NOT EXIST
-- So the same output can be extracted by using UNION ALL
-- for LEFT and RIGHT joins 
select a.date , a.user_id, extract(month from a.date) as day_timestamp,
count(distinct a.user_id) as churned_users from user_activity as a 
LEFT JOIN user_activity AS b on a.user_id=b.user_id
AND extract(month from a.date)=extract(month from b.date)+ 1
where b.user_id is null
group by extract(month from a.date), a.date, a .user_id
UNION ALL
select a.date , a.user_id, extract(month from a.date) as day_timestamp,
count(distinct a.user_id) as churned_users from user_activity as a 
RIGHT JOIN user_activity AS b on a.user_id=b.user_id
AND extract(month from a.date)=extract(month from b.date)+ 1
where b.user_id is null
group by extract(month from a.date), a.date, a .user_id;


-- Find the users where the user has returned back after 1 month
-- irrespective of the gaps in months.

WITH a AS
(SELECT user_id, MONTH(date) AS Logged_Month, YEAR(date) AS Logged_Year 
FROM user_activity),
B AS
(SELECT user_id, Logged_Month, Logged_Year, LAG(Logged_Month) OVER() AS Prev_Month,
LAG(Logged_Year) OVER() AS Prev_Year
FROM a)
SELECT * FROM B WHERE Logged_Month >= Prev_Month + 2 
OR ((Prev_Month = 12 AND Logged_Month = 1) AND (Logged_Year + 1 != Prev_Year));

SELECT * FROM user_activity;

-- Sir:-

SELECT a.date , a.user_id, extract(month from a.date) as day_timestamp,
count(distinct a.user_id) as reactivated_user, max(extract(month from a.date)) 
AS Max_dur from user_activity as a 
LEFT JOIN user_activity AS b on a.user_id=b.user_id
AND extract(month from a.date) > extract(month from b.date)
group by extract(month from a.date), a.date, a .user_id
having day_timestamp < Max_dur + 1;

-- Generate the Cummulative Cash Flow for the Given data:

CREATE TABLE cash_flow (
  date DATE NOT NULL,
  cash_flow INT NOT NULL,
  PRIMARY KEY (date)
);

INSERT INTO cash_flow (date, cash_flow) VALUES
('2018-01-01', -1000),
('2018-01-02', -100),
('2018-01-03', 50);

INSERT INTO cash_flow (date, cash_flow) VALUES
('2018-01-04', 200),
('2018-01-05', -300),
('2018-01-06', 100),
('2018-01-07', -50);


-- The aim is to find the cummulative cash_flow for all the dates
SELECT a.date, SUM(b.cash_flow) AS Cumm
FROM cash_flow a
JOIN cash_flow b
ON a.date >= b.date
GROUP BY a.date
ORDER BY date ASC;

-- Cummulative without using Join
SELECT date, SUM(cash_flow) OVER(ORDER BY date ASC) AS Cumm FROM cash_flow;


-- -----------------------------------------------------------------------------
CREATE TABLE sign_ups (
  date DATE NOT NULL,
  sign_ups INT NOT NULL,
  PRIMARY KEY (date)
);

INSERT INTO sign_ups (date, sign_ups) VALUES
('2018-01-01', 10),
('2018-01-02', 20),
('2018-01-03', 50),
('2018-10-01', 35);

INSERT INTO sign_ups (date, sign_ups) VALUES
('2018-01-07', 40),
('2018-01-05', 30),
('2018-01-09', 15),
('2018-11-01', 10);

-- 7 day rolling average of daily sign up for each day

-- METHOD 1

SELECT date, avg(sign_ups) 
OVER(ORDER BY date ASC ROWS BETWEEN 6 PRECEDING AND 0 PRECEDING) 
AS Cumm FROM sign_ups;

-- Now the problem with this method is that we are considering ROWS
-- as a medium to count and not the actual gap between DAYS
-- So this kind of thing can only be used if it's explicitly mentioned 
-- that 7 ROW rolling avg (and not 7 DAY rolling avg.)

-- METHOD 2

SELECT a.date, AVG(b.sign_ups) AS 7dayrollingavg FROM sign_ups a 
JOIN sign_ups b 
ON a.date <= b.date + 6 AND a.date >= b.date
group by a.date;

-- Now, this will give the exact required output
-- But note something on JOIN area:
-- we have done a.date(previous) <= a.date+6 (next -> curr + 6 days)
-- So this condition needs to be true as obviously the next must be more than
-- current

-- Also look at the second condition, a.date(previous) >= b.date (next)
-- This implies that 


CREATE TABLE messages (
  id INT NOT NULL AUTO_INCREMENT,
  subject VARCHAR(255) NOT NULL,
  Msg_From VARCHAR(255) NOT NULL,
  Msg_to VARCHAR(255) NOT NULL,
  timestamp DATETIME NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO messages (subject, Msg_From, Msg_to, timestamp) VALUES
('Yosemite', 'zach@g.com', 'thomas@g.com', '2018-01-02 12:45:03'),
('Big Sur', 'sarah@g.com', 'thomas@g.com', '2018-01-02 16:30:01'),
('Yosemite', 'thomas@g.com', 'zach@g.com', '2018-01-02 16:35:04'),
('Running', 'jill@g.com', 'zach@g.com', '2018-01-03 08:12:45'),
('Yosemite', 'zach@g.com', 'thomas@g.com', '2018-01-03 14:02:01'),
('Yosemite', 'thomas@g.com', 'zach@g.com', '2018-01-03 15:01:05');

SELECT * FROM messages;

-- Write a query to get the response time per email (id) 
-- sent to zach@g.com . Do not include ids that did not receive a 
-- response from zach@g.com. Assume each email thread has a unique subject. 
-- Keep in mind a thread may have multiple responses back-and-forth 
-- between zach@g.com and another email address. Here consider that the tread 
-- is not being getting extended.


-- What I tried:
SELECT DISTINCT a.Subject, a.Msg_From, a.Msg_To, 
b.timestamp - a.timestamp AS reply_time FROM messages a
JOIN messages b ON a.Msg_From = b.Msg_To 
AND a.Msg_To = b.Msg_From AND b.timestamp > a.timestamp;

-- Sir's:
select a.id , min(b.timestamp) - a.timestamp as time_to_respond
from messages a 
join messages b
on b.subject = a.subject
and a.msg_to =b.msg_from
and a.timestamp < b.timestamp
where a .msg_to ='zach@g.com'
group by a.id;


-- Now take into account that Thread can be extended. that means there 
-- can be more than one sets of send and recieve for both the sender and
-- reciever

 
select a.id , min(b.timestamp) - a.timestamp as time_to_respond
from messages a 
join messages b
on b.subject = a.subject
and a.msg_to = b.msg_from
and a.timestamp < b.timestamp
where a .msg_to ='zach@g.com' and b.msg_from = 'zach@g.com'
group by a.id;

-- another way to do the same thing
select a.id , b.timestamp - a.timestamp as time_to_respond
from messages a 
join messages b
on b.subject = a.subject
and a.msg_to =b.msg_from
and a.timestamp < b.timestamp
where a .msg_to ='zach@g.com' and b.msg_from="zach@g.com";

-- Right now this query is returning one answer
-- but, if there were more than one positive time_to_reponds
-- consecuetively after joining, then we would have got even more 
-- answers or respond_times.

















