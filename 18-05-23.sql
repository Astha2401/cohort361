use Cohort361;

-- Now there are driving engines in SQL based on which we can 
-- select what kind of processing is required for querying.
select table_name, engine from information_schema.tables 
where table_name = 'employee1';

-- Now the query engines can be of two typws:
-- MyISAM : heavy select queries
-- InnoDB : when we have PK, foriegn key relation ship

-- So, we can change the engine type
alter table employee1 engine = 'MyISAM';

-- Now, we'll have to repair the table.
-- This is done so that the new changes can be instantly applied.
-- If we dont, still, after 1 or 2 queries, It'll update to the
-- new engine automatically.
repair table employee1;

-- Now, from this point onwards, the new engine will be used.
select * from employee1;

-- ENGINE does what??

-- Parser: It breaks the query to smaller components
-- Lexer: Identifying the Tokens (where is FROM, WHERE, GROUP, etc etc)
-- Semantic Analyzer : Interprtes the meanong of the SQL query
-- Optimizer : The most efficient and best way to execute a query
-- Query Executer : Returning the query back


-- TO VIEW THE ONGOING STATUS OF EACH TABLE AND EVERYTHING RELATED TO IT

show table status;
-- Using this we can get details like the engine, rows, auto increment,
-- create time, update time, etc etc


-- ADDITIONAL INFO!
-- TEMPORARY TABLE (craeted in memory for the particular session)
-- CTE (just to create a view for that particular query)

select * from employee;

-- A GOOD EXAMPLE OF CONSISTENCY & ISOLATION ->>

-- Now, suppose we wanna LOCK this table

-- Let's lock everything except reading the table
lock table employee read;
-- Now lets try to select from table:
select * from employee;  -- This will work normally

-- Lets try to insert into table:
insert into employee values(9,'Habibi'); -- Throws an ERROR that cannot be updated

-- Now to disable the lock:
unlock tables;

-- Now if we try to do the same thing:
insert into employee values(9,'Habibi');
select * from employee;

-- IMPORTANT
-- Now, if I change the user and try to work on this locked table:
-- the query request will be on hold instead of executing until the 
-- lock on table is disabled.

-- Now, to lock a particular user: 
alter user guneet@localhost account lock;
-- While Locked, the user cannot access the account
-- Now to unlock a particular user
alter user guneet@localhost account unlock;

-- **Many featres related to lock and unlock are limited to enterprise
-- version of MySQL only. So all of this might not work.


-- CONCEPT OF VIEWS
-- Replacing a Query with a temporary alias

create view temp as select e_id from employee;

-- CREATE VIEW view_name AS (the query for which the view is being created)

-- As an example, lets insert a value into Employee table
insert into employee(e_id,e_name) values(10,'Jinesh');
select * from employee;
-- Upon the execution of this select query, we can clearly see
-- that a new row is added to the table

select * from temp;
-- So now if we'll try to see via the view, the query of "select e_id
-- from employee" will be executed first and then select * from (executed query).

-- So, views are basically used when you have to perfrom a query again 
-- and again

-- ---------------------------------------------------------------------

-- ORDER BY (used to sort the data, either as ascending/ descending)

select e_name from employee order by e_name; 
select e_name from employee order by e_name desc; 

-- GROUP BY (used to group the rows for a common value or aggregation)

-- Grouping first on the basis of fields and then 
-- calculating aggregations 
select * from student;
select gender, count(*) as no_of_stu from student
group by gender;
-- The table is ordered as per the no. of people in each gender.

-- And ofcourse, both of these can be easily used together
-- Also multiple grouping and multiple ordering is possible.

-- HAVING (can be used only upon aggregation) 
-- It is just like where but where is used in column that already exist in 
-- the table

select gender, count(*) as no_of_stu from student
group by gender having no_of_stu > 2;

-- Here the "no_of_stu" is created as a result of aggregation 'count'
-- so we cant use WHERE, and hence we'll use HAVING 

-- JOINS in MySQL

-- First creating the required tables 

create table users (u_id int not null auto_increment, 
u_name varchar(255) not null, primary key(u_id));

create table orders(o_id int not null auto_increment, 
u_id int not null, order_value int not null,
primary key (o_id), foreign key(u_id) references users(u_id));

insert into users(u_name) values('Alpha');
insert into users(u_name) values('Beta');
insert into users(u_name) values('Gamma');
insert into users(u_name) values('Delta');
insert into users(u_name) values('Theta');
insert into users(u_name) values('Omega');
insert into users(u_name) values('Zeta');

insert into orders(u_id, order_value) values(1,6200);
insert into orders(u_id, order_value) values(2,500);
insert into orders(u_id, order_value) values(3,180);
insert into orders(u_id, order_value) values(1,63);
insert into orders(u_id, order_value) values(5,1236);
insert into orders(u_id, order_value) values(3,100);
insert into orders(u_id, order_value) values(4,326);
insert into orders(u_id, order_value) values(5,50000);
insert into orders(u_id, order_value) values(6,620);
insert into orders(u_id, order_value) values(7,1800);
insert into orders(u_id, order_value) values(6,210);
insert into orders(u_id, order_value) values(8,50);
insert into orders(u_id, order_value) values(8,150);

select * from users;
select * from orders;

-- Example of inner join
select users.u_id, u_name, order_value from
users join orders
on users.u_id = orders.u_id;


-- ----------------------------------------------------------------------
CREATE TABLE ActorDirector (
  actor_id INT NOT NULL,
  director_id INT NOT NULL,
  timestamp INT NOT NULL,
  PRIMARY KEY (actor_id, director_id, timestamp)
);

INSERT INTO ActorDirector (actor_id, director_id, timestamp) VALUES
(1, 1, 0),
(1, 1, 1),
(1, 1, 2),
(1, 2, 3),
(1, 2, 4),
(2, 1, 5),
(2, 1, 6);

SELECT * FROM ActorDirector;

-- Which actor has worked as director in the same film more than 
-- or equal to 2 times
select actor_id, director_id, count(*) numbers from ActorDirector where 
actor_id = director_id group by actor_id, director_id having count(*) >= 2;
-- -----------------------------------------------------------------------

-- Write an SQL query to find all the 
-- authors that viewed at least one of their own articles, 
-- sorted in ascending order by their id.


CREATE TABLE ArticleViews (
  article_id INT NOT NULL,
  author_id INT NOT NULL,
  viewer_id INT NOT NULL,
  view_date DATE NOT NULL,
  PRIMARY KEY (article_id, viewer_id)
);

INSERT INTO ArticleViews (article_id, author_id, viewer_id, view_date) VALUES
(1, 3, 5, '2019-08-01'),
(1, 3, 6, '2019-08-02'),
(2, 7, 7, '2019-08-01'),
(2, 7, 6, '2019-08-02'),
(4, 7, 1, '2019-07-22'),
(3, 4, 4, '2019-07-21');

SELECT * FROM ArticleViews;

-- Mine
select author_id from ArticleViews where author_id = viewer_id 
order by author_id asc;
-- Sir
select distinct author_id -- distinct is important so there are no
from ArticleViews
where author_id = viewer_id
order by author_id;
-- -----------------------------------------------------------------------

CREATE TABLE Prices (
  product_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (product_id, start_date)
);

INSERT INTO Prices (product_id, start_date, end_date, price) VALUES
(1, '2019-02-17', '2019-02-28', 5.00),
(1, '2019-03-01', '2019-03-22', 20.00),
(2, '2019-02-01', '2019-02-20', 15.00),
(2, '2019-02-21', '2019-03-31', 30.00);

CREATE TABLE UnitsSold (
  product_id INT NOT NULL,
  purchase_date DATE NOT NULL,
  units INT NOT NULL,
  PRIMARY KEY (product_id, purchase_date)
);

INSERT INTO UnitsSold (product_id, purchase_date, units) VALUES
(1, '2019-02-25', 100),
(1, '2019-03-01', 15),
(2, '2019-02-10', 200),
(2, '2019-03-22', 30);

-- Write an SQL query to find the average selling price for each product.
-- average_price should be rounded to 2 decimal places.

select *  from Prices;
select * from UnitsSold;

-- Mine
with one as(
select Prices.product_id, start_date, end_date, purchase_date, units, price
from Prices join UnitsSold on 
Prices.product_id = UnitsSold.product_id),
two as
(select product_id, purchase_date, units,price from one 
where purchase_date between start_date and end_date),
three as
(select product_id, sum(price*units) as total, sum(units) as tot_u from two 
group by product_id)
select product_id, round(total/tot_u,2) as avg_val from three
group by product_id;

-- Sir
select product_id, round((sum(price*units)/sum(units)),2) as avg_selling_price
from Prices p natural join UnitsSold s
where s.purchase_date between p.start_date and p.end_date
group by product_id;

-- Here in case of natral join, we can join two tables by their common 
-- column by default. (here, we don't need to specify the ON clause for 
-- joining the tables)

-- ----------------------------------------------------------------------------

CREATE TABLE Numbers (
  num INT NOT NULL
);

INSERT INTO Numbers(num) VALUES
(8),
(8),
(3),
(3),
(1),
(4),
(5),
(6);

-- Table my_numbers contains many numbers in column num including duplicated ones.
-- Can you write a SQL query to find the biggest number, which only appears once.

SELECT max(num) as max_single_occ FROM 
(SELECT num, count(*) as count_nums from Numbers
group by num HAVING count_nums = 1) AS temp;


-- ------------------------------------------------------------------------------
-- Write a SQL query for a report that provides the following 
-- information for each person in the Person table,
-- regardless if there is an address for each of those people:

CREATE TABLE Person (
  PersonId INT NOT NULL AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  PRIMARY KEY (PersonId)
);

CREATE TABLE Address (
  AddressId INT NOT NULL AUTO_INCREMENT,
  PersonId INT NOT NULL,
  City VARCHAR(50) NOT NULL,
  State VARCHAR(50) NOT NULL,
  PRIMARY KEY (AddressId)
);

INSERT INTO Person(FirstName, LastName) VALUES('Amam','Jain');
INSERT INTO Person(FirstName, LastName) VALUES('Ram','Prasad');
INSERT INTO Person(FirstName, LastName) VALUES('Riya','Tiwari');
INSERT INTO Person(FirstName, LastName) VALUES('Aditi','Sharma');
INSERT INTO Person(FirstName, LastName) VALUES('Saksham','Kohli');

INSERT INTO Address(PersonId, City, State) VALUES(2,'Raipur','Chattisgarh');
INSERT INTO Address(PersonId, City, State) VALUES(5,'Mumbai','Maharashtra');
INSERT INTO Address(PersonId, City, State) VALUES(3,'Bhopal','Madhya Pradesh');

SELECT * FROM Person;
SELECT * FROM Address;

SELECT Person.PersonId, FirstName, LastName, City, State 
FROM Person LEFT JOIN Address ON 
Person.PersonID = Address.PersonID; 



-- ----------------------------------------------------------------

CREATE TABLE seat (
  seat_id INT NOT NULL,
  free BOOLEAN NOT NULL,
  PRIMARY KEY (seat_id)
);

INSERT INTO seat (seat_id, free) VALUES
(1, 1),
(2, 0),
(3, 1),
(4, 1),
(5, 1);

SELECT distinct a.seat_id
FROM seat a JOIN seat b
ON abs(a.seat_id - b.seat_id) = 1
AND a.free = 1 AND b.free = 1; 

SELECT distinct a.seat_id
FROM seat a JOIN seat b
ON a.free = b.free 
AND a.free = 1 AND b.free = 1;

-- Several friends at a cinema ticket office 
-- would like to reserve consecutive available seats.
-- Can you help to query all the consecutive available 
-- seats order by the seat_id using the following cinema table?

-- Note:
-- The seat_id is an auto increment int, and free is bool 
-- ('1' means free, and '0' means occupied.).
-- Consecutive available seats are more than 2(inclusive) 
-- seats consecutively available.

-- -----------------------------------------------------------------

-- Suppose that a website contains two tables, 
-- the Customers table and the Orders table. Write a SQL query to find all customers who never order anything.

-- Table: Customers.

CREATE TABLE Customers (
  id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO Customers (id, name) VALUES
(1, 'Joe'),
(2, 'Henry'),
(3, 'Sam'),
(4, 'Max');

CREATE TABLE Orders (
  id INT NOT NULL,
  customer_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES Customers(id)
);

DROP TABLE Orders;

INSERT INTO Orders (id, customer_id) VALUES
(1, 3),
(2, 1);

SELECT Customers.id, name FROM Customers LEFT JOIN Orders
ON Customers.id = Orders.customer_id WHERE Orders.id IS null;

-- -----------------------------------------------------------------

-- Select all employee's name and bonus whose bonus is < 1000.
-- Table:Employee

CREATE TABLE Employees (
  empId INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  supervisor INT,
  salary INT,
  PRIMARY KEY (empId)
);

INSERT INTO Employees (empId, name, supervisor, salary) VALUES
(1, 'John', 3, 1000),
(2, 'Dan', 3, 2000),
(3, 'Brad', NULL, 4000),
(4, 'Thomas', 3, 4000);

CREATE TABLE Bonus (
  empId INT NOT NULL,
  bonus INT,
  PRIMARY KEY (empId),
  FOREIGN KEY (empId) REFERENCES Employees(empId)
);

INSERT INTO Bonus (empId, bonus) VALUES
(2, 500),
(4, 2000);

SELECT Employees.empId, name, salary, bonus 
FROM Employees JOIN Bonus ON 
Employees.empId = Bonus.empID 
WHERE bonus < 1000;

-- ----------------------------------------------------------------

CREATE TABLE Activity (
  player_id INT NOT NULL,
  device_id INT NOT NULL,
  event_date DATE NOT NULL,
  games_played INT,
  PRIMARY KEY (player_id, event_date)
);

INSERT INTO Activity (player_id, device_id, event_date, games_played) VALUES
(1, 2, '2016-03-01', 5),
(1, 2, '2016-05-02', 6),
(2, 3, '2017-06-25', 1),
(3, 1, '2016-03-02', 0),
(3, 4, '2018-07-03', 5);

select *  from Activity;

SELECT player_id, min(event_date) AS first_log FROM
Activity GROUP BY player_id ORDER BY player_id;

-- Write an SQL query that reports the first login date for each player.


use Cohort361;

-- Now there are driving engines in SQL based on which we can 
-- select what kind of processing is required for querying.
select table_name, engine from information_schema.tables 
where table_name = 'employee1';

-- Now the query engines can be of two typws:
-- MyISAM : heavy select queries
-- InnoDB : when we have PK, foriegn key relation ship

-- So, we can change the engine type
alter table employee1 engine = 'MyISAM';

-- Now, we'll have to repair the table.
-- This is done so that the new changes can be instantly apply.
-- If we dont, still, after 1 or 2 queries, It'll update to the
-- new engine automatically.
repair table employee1;

-- Now, from this point onwards, the new engine will be used.
select * from employee1;

-- ENGINE does what??

-- Parser: It breaks the query to smaller components
-- Lexer: Identifying the Tokens (where is FROM, WHERE, GROUP, etc etc)
-- Semantic Analyzer : Interprtes the meanong of the SQL query
-- Optimizer : The most efficient and best way to execute a query
-- Query Executer : Returning the query back


-- TO VIEW THE ONGOING STATUS OF EACH TABLE AND EVERYTHING RELATED TO IT

show table status;
-- Using this we can get details like the engine, rows, auto increment,
-- create time, update time, etc etc


-- ADDITIONAL INFO!
-- TEMPORARY TABLE (craeted in memory for the particular session)
-- CTE (just to create a view for that particular query)

select * from employee;

-- A GOOD EXAMPLE OF CONSISTENCY & ISOLATION ->>

-- Now, suppose we wanna LOCK this table

-- Let's lock everything except reading the table
lock table employee read;
-- Now lets try to select from table:
select * from employee;  -- This will work normally

-- Lets try to insert into table:
insert into employee values(9,'Habibi'); -- Throws an ERROR that cannot be updated

-- Now to disable the lock:
unlock tables;

-- Now if we try to do the same thing:
insert into employee values(9,'Habibi');
select * from employee;

-- IMPORTANT
-- Now, if I change the user and try to work on this locked table:
-- the query request will be on hold instead of executing until the 
-- lock on table is disabled.

-- Now, to lock a particular user: 
alter user guneet@localhost account lock;
-- While Locked, the user cannot access the account
-- Now to unlock a particular user
alter user guneet@localhost account unlock;

-- **Many featres related to lock and unlock are limited to enterprise
-- version of MySQL only. So all of this might not work.


-- CONCEPT OF VIEWS
-- Replacing a Query with a temporary alias

create view temp as select e_id from employee;

-- As an example, lets insert a value into Employee table
insert into employee(e_id,e_name) values(10,'Jinesh');
select * from employee;
-- Upon the execution of this select query, we can clearly see
-- that a new row is added to the table

select * from temp;
-- So now if we'll try to see via the view, the query of "select e_id
-- from employee" will be executed first and then select * from (executed query).

-- So, views are basically used when you have to perfrom a query again 
-- and again

-- ---------------------------------------------------------------------

-- ORDER BY (used to sort the data, either as ascending/ descending)

select e_name from employee order by e_name; 
select e_name from employee order by e_name desc; 

-- GROUP BY (used to group the rows for a common value or aggregation)

-- Grouping first on the basis of fields and then 
-- calculating aggregations 
select * from student;
select gender, count(*) as no_of_stu from student
group by gender;
-- The table is ordered as per the no. of people in each gender.

-- And ofcourse, both of these can be easily used together
-- Also multiple grouping and multiple ordering is possible.

-- HAVING (can be used only upon aggregation) 
-- It is just like where but where is used in column that already exist in 
-- the table

select gender, count(*) as no_of_stu from student
group by gender having no_of_stu > 2;

-- Here the "no_of_stu" is created as a result of aggregation 'count'
-- so we cant use WHERE, and hence we'll use HAVING 

-- JOINS in MySQL

-- First creating the required tables 

create table users (u_id int not null auto_increment, 
u_name varchar(255) not null, primary key(u_id));

create table orders(o_id int not null auto_increment, 
u_id int not null, order_value int not null,
primary key (o_id), foreign key(u_id) references users(u_id));

insert into users(u_name) values('Alpha');
insert into users(u_name) values('Beta');
insert into users(u_name) values('Gamma');
insert into users(u_name) values('Delta');
insert into users(u_name) values('Theta');
insert into users(u_name) values('Omega');
insert into users(u_name) values('Zeta');

insert into orders(u_id, order_value) values(1,6200);
insert into orders(u_id, order_value) values(2,500);
insert into orders(u_id, order_value) values(3,180);
insert into orders(u_id, order_value) values(1,63);
insert into orders(u_id, order_value) values(5,1236);
insert into orders(u_id, order_value) values(3,100);
insert into orders(u_id, order_value) values(4,326);
insert into orders(u_id, order_value) values(5,50000);
insert into orders(u_id, order_value) values(6,620);
insert into orders(u_id, order_value) values(7,1800);
insert into orders(u_id, order_value) values(6,210);
insert into orders(u_id, order_value) values(8,50);
insert into orders(u_id, order_value) values(8,150);

select * from users;
select * from orders;

-- Example of inner join
select users.u_id, u_name, order_value from
users join orders
on users.u_id = orders.u_id;


-- ----------------------------------------------------------------------
CREATE TABLE ActorDirector (
  actor_id INT NOT NULL,
  director_id INT NOT NULL,
  timestamp INT NOT NULL,
  PRIMARY KEY (actor_id, director_id, timestamp)
);

INSERT INTO ActorDirector (actor_id, director_id, timestamp) VALUES
(1, 1, 0),
(1, 1, 1),
(1, 1, 2),
(1, 2, 3),
(1, 2, 4),
(2, 1, 5),
(2, 1, 6);

SELECT * FROM ActorDirector;

-- Which actor has worked as director in the same film more than 
-- or equal to 2 times
select actor_id, director_id, count(*) numbers from ActorDirector where 
actor_id = director_id group by actor_id, director_id having count(*) >= 2;
-- -----------------------------------------------------------------------

-- Write an SQL query to find all the 
-- authors that viewed at least one of their own articles, 
-- sorted in ascending order by their id.


CREATE TABLE ArticleViews (
  article_id INT NOT NULL,
  author_id INT NOT NULL,
  viewer_id INT NOT NULL,
  view_date DATE NOT NULL,
  PRIMARY KEY (article_id, viewer_id)
);

INSERT INTO ArticleViews (article_id, author_id, viewer_id, view_date) VALUES
(1, 3, 5, '2019-08-01'),
(1, 3, 6, '2019-08-02'),
(2, 7, 7, '2019-08-01'),
(2, 7, 6, '2019-08-02'),
(4, 7, 1, '2019-07-22'),
(3, 4, 4, '2019-07-21');

SELECT * FROM ArticleViews;

-- Mine
select author_id from ArticleViews where author_id = viewer_id 
order by author_id asc;
-- Sir
select distinct author_id -- distinct is important so there are no
from ArticleViews
where author_id = viewer_id
order by author_id;
-- -----------------------------------------------------------------------

CREATE TABLE Prices (
  product_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  PRIMARY KEY (product_id, start_date)
);

INSERT INTO Prices (product_id, start_date, end_date, price) VALUES
(1, '2019-02-17', '2019-02-28', 5.00),
(1, '2019-03-01', '2019-03-22', 20.00),
(2, '2019-02-01', '2019-02-20', 15.00),
(2, '2019-02-21', '2019-03-31', 30.00);

CREATE TABLE UnitsSold (
  product_id INT NOT NULL,
  purchase_date DATE NOT NULL,
  units INT NOT NULL,
  PRIMARY KEY (product_id, purchase_date)
);

INSERT INTO UnitsSold (product_id, purchase_date, units) VALUES
(1, '2019-02-25', 100),
(1, '2019-03-01', 15),
(2, '2019-02-10', 200),
(2, '2019-03-22', 30);

-- Write an SQL query to find the average selling price for each product.
-- average_price should be rounded to 2 decimal places.

select *  from Prices;
select * from UnitsSold;

-- Mine
with one as(
select Prices.product_id, start_date, end_date, purchase_date, units, price
from Prices join UnitsSold on 
Prices.product_id = UnitsSold.product_id),
two as
(select product_id, purchase_date, units,price from one 
where purchase_date between start_date and end_date),
three as
(select product_id, sum(price*units) as total, sum(units) as tot_u from two 
group by product_id)
select product_id, round(total/tot_u,2) as avg_val from three
group by product_id;

-- Sir
select product_id, round((sum(price*units)/sum(units)),2) as avg_selling_price
from Prices p natural join UnitsSold s
where s.purchase_date between p.start_date and p.end_date
group by product_id;

-- Here in case of natral join, we can join two tables by their common 
-- column by default. (here, we don't need to specify the ON clause for 
-- joining the tables)

-- ----------------------------------------------------------------------------

CREATE TABLE Numbers (
  num INT NOT NULL
);

INSERT INTO Numbers(num) VALUES
(8),
(8),
(3),
(3),
(1),
(4),
(5),
(6);

-- Table my_numbers contains many numbers in column num including duplicated ones.
-- Can you write a SQL query to find the biggest number, which only appears once.

SELECT max(num) as max_single_occ FROM 
(SELECT num, count(*) as count_nums from Numbers
group by num HAVING count_nums = 1) AS temp;


-- ------------------------------------------------------------------------------
-- Write a SQL query for a report that provides the following 
-- information for each person in the Person table,
-- regardless if there is an address for each of those people:

CREATE TABLE Person (
  PersonId INT NOT NULL AUTO_INCREMENT,
  FirstName VARCHAR(50) NOT NULL,
  LastName VARCHAR(50) NOT NULL,
  PRIMARY KEY (PersonId)
);

CREATE TABLE Address (
  AddressId INT NOT NULL AUTO_INCREMENT,
  PersonId INT NOT NULL,
  City VARCHAR(50) NOT NULL,
  State VARCHAR(50) NOT NULL,
  PRIMARY KEY (AddressId)
);

INSERT INTO Person(FirstName, LastName) VALUES('Amam','Jain');
INSERT INTO Person(FirstName, LastName) VALUES('Ram','Prasad');
INSERT INTO Person(FirstName, LastName) VALUES('Riya','Tiwari');
INSERT INTO Person(FirstName, LastName) VALUES('Aditi','Sharma');
INSERT INTO Person(FirstName, LastName) VALUES('Saksham','Kohli');

INSERT INTO Address(PersonId, City, State) VALUES(2,'Raipur','Chattisgarh');
INSERT INTO Address(PersonId, City, State) VALUES(5,'Mumbai','Maharashtra');
INSERT INTO Address(PersonId, City, State) VALUES(3,'Bhopal','Madhya Pradesh');

SELECT * FROM Person;
SELECT * FROM Address;

SELECT Person.PersonId, FirstName, LastName, City, State 
FROM Person LEFT JOIN Address ON 
Person.PersonID = Address.PersonID; 


-- ----------------------------------------------------------------

CREATE TABLE seat (
  seat_id INT NOT NULL,
  free BOOLEAN NOT NULL,
  PRIMARY KEY (seat_id)
);

INSERT INTO seat (seat_id, free) VALUES
(1, 1),
(2, 0),
(3, 1),
(4, 1),
(5, 1);

SELECT distinct a.seat_id
FROM seat a JOIN seat b
ON abs(a.seat_id - b.seat_id) = 1
AND a.free = 1 AND b.free = 1; 

-- Several friends at a cinema ticket office 
-- would like to reserve consecutive available seats.
-- Can you help to query all the consecutive available 
-- seats order by the seat_id using the following cinema table?

-- Sir:
select seat_id from (select seat_id, free,lead(free,1) over() as next, 
lag(free,1) over() as prev from seat) a
where a.free=True and (next = True or prev=True)
order by seat_id;

-- Note:
-- The seat_id is an auto increment int, and free is bool 
-- ('1' means free, and '0' means occupied.).
-- Consecutive available seats are more than 2(inclusive) 
-- seats consecutively available.

-- -----------------------------------------------------------------

-- Suppose that a website contains two tables, 
-- the Customers table and the Orders table. Write a SQL query to find all customers who never order anything.

-- Table: Customers.

CREATE TABLE Customers (
  id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  PRIMARY KEY (id)
);

INSERT INTO Customers (id, name) VALUES
(1, 'Joe'),
(2, 'Henry'),
(3, 'Sam'),
(4, 'Max');

CREATE TABLE Orders (
  id INT NOT NULL,
  customer_id INT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (customer_id) REFERENCES Customers(id)
);

DROP TABLE Orders;

INSERT INTO Orders (id, customer_id) VALUES
(1, 3),
(2, 1);

SELECT Customers.id, name FROM Customers LEFT JOIN Orders
ON Customers.id = Orders.customer_id WHERE Orders.id IS null;

-- -----------------------------------------------------------------

-- Select all employee's name and bonus whose bonus is < 1000.
-- Table:Employee

CREATE TABLE Employees (
  empId INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  supervisor INT,
  salary INT,
  PRIMARY KEY (empId)
);

INSERT INTO Employees (empId, name, supervisor, salary) VALUES
(1, 'John', 3, 1000),
(2, 'Dan', 3, 2000),
(3, 'Brad', NULL, 4000),
(4, 'Thomas', 3, 4000);

CREATE TABLE Bonus (
  empId INT NOT NULL,
  bonus INT,
  PRIMARY KEY (empId),
  FOREIGN KEY (empId) REFERENCES Employees(empId)
);

INSERT INTO Bonus (empId, bonus) VALUES
(2, 500),
(4, 2000);

SELECT Employees.empId, name, salary, bonus 
FROM Employees JOIN Bonus ON 
Employees.empId = Bonus.empID 
WHERE bonus < 1000;

-- ----------------------------------------------------------------
-- Write an SQL query that reports the first login date for each player.

CREATE TABLE Activity (
  player_id INT NOT NULL,
  device_id INT NOT NULL,
  event_date DATE NOT NULL,
  games_played INT,
  PRIMARY KEY (player_id, event_date)
);

INSERT INTO Activity (player_id, device_id, event_date, games_played) 
VALUES
(1, 2, '2016-03-01', 5),
(1, 2, '2016-05-02', 6),
(2, 3, '2017-06-25', 1),
(3, 1, '2016-03-02', 0),
(3, 4, '2018-07-03', 5);

select *  from Activity;

SELECT player_id, min(event_date) AS first_log FROM
Activity GROUP BY player_id ORDER BY player_id;

-- Sir:
Select player_id, min(event_date) as first_login
from Activity
Group by player_id;

-- --------------------------------------------------

--  LEAD and LAG Functions:

-- LEAD 
select * from Customers;
 -- All the names will be shifted by a particular number (by default 1)
SELECT id, name, LEAD(name) OVER(ORDER BY id)
AS name_shift FROM Customers;

-- Same is for LAG (but it will simply shift it the other way)

-- ---------------------------------------------------------------------

-- PARTITIONING 
-- To split the data into parts based on a certail criteria.
-- It can be either HORIZONTAL or VERTICAL

create table custos(
id int not null auto_increment,
name varchar(255) not null,
country varchar(255) not null,
primary key(id));

insert into custos(name,country) values('Person','US');
insert into custos(name,country) values('Place','China');
insert into custos(name,country) values('Animal','UK');
insert into custos(name,country) values('Thing','India');

select * from custos;

alter table custos add partition by hash(test_country)
partition 10; -- <--Not working like this

-- Trying Another Table
create table t1(id int,year_col int) 
partition by range(year_col)
(partition p0 values less than (1991),
partition p1 values less than (2001),
partition p2 values less than (2011),
partition p3 values less than (2021));

select * from t1;
show table status; -- We can notice here that the 
-- Create_options has "partitioned" as value

-- -----------------------------------------------------------------------
-- -----------------------------------------------------------------------