create database Cohort361;
use Cohort361;

create table employee(
employee_id int primary key,
employee_name varchar(100));

select * from employee;

insert into employee values(1,'Aman');
insert into employee values(2,'Aditya');
insert into employee values(3,'Barkha');
insert into employee values(4,'Chaman');
insert into employee values(5,'Gagan');
insert into employee values(6,'Riya');
insert into employee values(7,'Shobha');
insert into employee values(8,'Kriti');

select * from employee;

create table employee1(
id int primary key auto_increment,
first_name text
);

insert into employee1(first_name) values('Lalit');

select * from employee1;

insert into employee1(first_name) values('Mehek');
insert into employee1(first_name) values('Ansh');
insert into employee1 values(10, 'Dhavi');

insert into employee1(first_name) values('Vickey');

insert into employee1 values(9, 'Ganesh');
insert into employee1(first_name) values('Raman');

select * from employee1;

-- to alter the auto increment :
-- (alter table employee1 alter column id set default 100)
-- the above line tells us the auto increment shall now by 
-- default start from 100 (as we've changed first value to 100)

-- NOTE that the column must be a primary key in order to
-- support Auto Increment Feature. So defining the column as
-- primary key is the first step.

alter table employee1 modify column id int not null;

select * from employee1;

-- alter table employee1 modify id int primary key auto_increment;

-- modify : definition of entity, changes in the existing 
-- structure 
-- alter : to change existing features of table, like enabling 
-- or disabling auto increment and stuff

-- A LITTLE MORE ABOUT ALTER
-- used to add, delete or modify columns
-- used add or drop various constraints on an existing table

-- alter table table_name add column_name datatype;
-- alter table table_name drop column column_name;
-- alter table t_n rename column old_name to new_name;
-- alter table t_n alter column col_name datatype;
-- alter table t_n add col_name datatype;
-- alter table t_n modify col_name datatype constraint;
-- alter table t_n drop constraint; 
 

-- drop table employee;

select * from employee1 where id = 10;
select * from employee1 where first_name like 'a%';

-- keep in mind the types that can be used with LIKE
-- LIKE can work with integers too in My SQL

update employee1 set first_name = 'Guneet' where id = 10; 
select * from employee1;

-- where can support multiple conditions using 
-- and,or,not etc

describe employee1;
-- describe is used to get the structure of the table

-- UPDATE vs SAFE UPDATE
update employee1 set first_name = 'Temp';
-- The above statement will not execute as it is
-- trying to update all (or more than 1) rows in the table
-- So, we'll have to do this first:
set SQL_SAFE_UPDATES=0; -- enables multiple updates (safe update off) 
set SQL_SAFE_UPDATES=1; -- disables multiple updates (safe update on)


-- To change the COLUMN NAME 
alter table employee 
rename column employee_name to e_name,
rename column employee_id to e_id;

-- To delete a record:
delete from employee where e_id = 2;

select * from employee;

-- use of LIMIT
-- LIMIT (no. of rows to skip, no. of rows to continue after)

create table student(
id int primary key,
username varchar(30),
gender char(1) CHARACTER set ascii -- character set ascii 
-- is not necessary, just to select the range of available 
-- characters 
);

insert into student values (1,'Ajay','M');
insert into student values (2,'Bjay','F');
insert into student values (3,'Cjay','M');
insert into student values (4,'Djay','F');
insert into student values (5,'Ejay','M');

select * from student;

-- OTHER WAY to describe One-Char or even Strings Columns:
-- .......gender ENUM('M','F','T','O') OR .........department ENUM('Electronics','Computer Science','Electrical')
-- so declaring this way will help to conserve memory
-- as only 4 specified characters/words will be allowed in
-- the column.

-- DELETE all the Rows in a Table
truncate students;  -- TRUNCATE table_name
-- This will only remove all the rows
-- The constarints and every thing else will remain as it is

-- DATATYPES (A bit Uncommon Ones)

-- TINYINT (1 Byte)
-- SMALLINT (2 Bytes)
-- MEDIUMINT (3 Bytes)
-- INT (4 Bytes)
-- BIGINT (5 Bytes)
-- FLOAT (23 nos . 7 digits) 4 Bytes
-- TIME 3 Bytes
-- DATE 3 Bytes
-- DATETIME 5 Bytes
-- TIMESTAMP 4 Bytes
-- DECIMAL(n,m) Variable Size
-- DOUBLE (52, sign 16) 8 Bytes


-- To view the available users
select user from mysql.user;

-- To create a user and grant 
create user guneet@localhost identified by 'guneet';
grant all privileges on *.* to guneet@localhost;

-- To view the grants for a specified user
show grants for guneet@localhost;

-- To check various stats for the available users
select user, host, account_locked, password_Expired from mysql.user;

-- To check the access and working of databases, what each user
-- is currently doing
select user, host , db, command from information_schema.processlist;

-- To view all the details of each and every user
select * from mysql.user;

-- Details about Time Stamp
-- 
create table example_data(
id int primary key auto_increment,
event_name varchar(100), event_timestamp timestamp
);

insert into example_data (event_name,event_timestamp) values ('Event1',current_timestamp());
insert into example_data (event_name,event_timestamp) values ('Event2',current_timestamp());
insert into example_data (event_name,event_timestamp) values ('Event3',current_timestamp());

-- To view the table with time stamps. 
select * from example_data;














