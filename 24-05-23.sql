USE Cohort361;


-- We just saw how data is inserted and managed inside 
-- the database (see written notes)
-- Now lets try to replicate on a huge dataset

-- For that, first lets insert a table
CREATE TABLE employeeindex(
id int,
name varchar(300),
position varchar(100),
location varchar(50),
age int,
salary int
);

-- So lets create a stored procedure to do this insertion
-- See procedure: insert_employee
-- Here we also see use case of while loop
-- ---------------------------------------------------
-- CREATE DEFINER=`root`@`localhost` 
-- PROCEDURE `insert_employee`(start_id int, end_id int)
-- BEGIN
-- 	DECLARE i int;
--     SET i = start_id;
--     while i <= end_id DO
-- 		INSERT INTO employeeindexprimary(id, name, position, location, age, salary)
--         VALUES (i, concat('Employee',i), 'SRE Production Manager', 'New York', 35, 20000);
--         SET i = i+1;
-- 	END while;
-- END
-- -----------------------------------------------------------
CALL insert_employee(10001,25000);
-- While inserting into this table, the count of about
-- 15000 rows, it took 16.188 seconds
-- Not that here there is no primary key used
-- Just the by default basic stuff

-- NOW lets try to retrieve the rows
SELECT * FROM employeeindex;

-- Also, let's look into how many rows were scanned to get this:
EXPLAIN SELECT * FROM employeeindex WHERE id = 18579;
-- So, 15023 Rows were gone through to give this result


-- NOW LETS TRY THE SAME THING USING A TABLE WITH PRIMARY KEY
-- INSERTED BY DEFAULT

CREATE TABLE employeeindexprimary(
id int primary key,
name varchar(300),
position varchar(100),
location varchar(50),
age int,
salary int
);

-- Now using the stored procedure to stuff data into this table:

CALL insert_employee(10001,25000);
-- This time also the insertion took 16.343 secs
-- if I'll add more data:
CALL insert_employee(50000,62000);
-- This too executed with an addition of 13.015 secs
-- So, see, the point is using clustered indexing not
-- necessarily increase the speed of DDL commands

-- But, it definitely helps in DML commands
-- Now lets see data retreval:
EXPLAIN SELECT * FROM employeeindexprimary WHERE id = 18579;
-- This time, it only took "1 row" scan to get the output
-- So that's the advantage of using PRIMARY KEY or
-- CLUSTERED INDEXING 

-- SO THE MAIN BENEFIT of indexing is during data retreval
-- While storing data in this case, the rows are 
-- sorted while insertrions. This helps store in a 
-- systematic way.
-- On top of that, for searches, Hashing Alogorithms are used 
-- recieve data in O(1) time complexity.

-- Now, let's see into another kind of looping in MySQL
-- This uses the concept of REPEATING a task
-- ** Note that there is not actually any FOR Loop in MySQL

-- To see that working, look into "insert_employee_final"
-- Stored Procedure
-- Now, here you'll also find the usecase of IF/ELSE
-- So, the constraints that can be used are ELSE, IF and
-- ELSE IF
-- ----------------------------------------------------------
-- CREATE DEFINER=`root`@`localhost` 
-- PROCEDURE `insert_employee_final`(start_index INT, end_index INT)
-- BEGIN
-- 	DECLARE i INT DEFAULT start_index;
-- 	START TRANSACTION;
--     REPEAT
-- 		IF i%2 = 0 THEN
-- 			INSERT INTO employeeindex(id, name, position, location, age, salary)
-- 			VALUES (i, concat('Employee',i), 'SRE Production Manager', 'New York', 35, 20000);
--         ELSE
-- 			INSERT INTO employeeindex(id, name, position, location, age, salary)
-- 			VALUES (i, concat('Employee',i), 'Software Developer', 'Austria', 31, 21000);
-- 		END IF;
--         SET i = i+1;
--         UNTIL i > end_index 
-- 	END REPEAT;
-- COMMIT;
-- -- START/COMMIT is used to get atomicity
-- -- IF all done, then only do this
-- END
-- ------------------------------------------------------
-- Lets use that procedure:

CALL insert_employee_final(95000,104000);
-- Now the rows according to our given conditions
-- are inserted using the REPEAT clause
-- So that's one thing : USING THE REPEAT LOOP

-- Now let's see what's happening internally
EXPLAIN SELECT * FROM employeeindex WHERE id = 95003;
-- So about 23000 rows were scanned and filtered
-- Again;
explain select * from employeeindex 
where position='Software Developer' and 
name ='Employee95123';
-- So see, these kind of queries which are related to
-- named attributes (not integers of kind)
-- can be used using the NON CLUSTERED INDEXING

-- How to do that??

create index ix_employee_name on employeeindex(name);
create index ix_employee_position on employeeindex(position);

-- So, here we have created two index options
-- Both of these are on VARCHAR columns
-- Out of these, NAME is unique (due the way we have done it)
-- But POSITION is not
-- But again, a combination of NAME and POSITION is Unique

-- So, by using such kind of indexing, String columns can 
-- be indexed by non clustered indexing.

-- So, let's check now:

explain select * from employeeindex 
where position='Software Developer' and 
name ='Employee95123';

-- NOW, here, notice the possible_keys and key column
-- Everything as expected above happened
-- The combination of NAME and POSITION is the possible key
-- but NAME is alone sufficient to suffice that so its the
-- main KEY
-- Also, dur to this the number of rows to be scanned 
-- has reduced to 1.
-- So, again, faster retreval takes place.

-- So, thats the benefit of using non-clusterd key 

-- Now, if these conditions are needed to be dropped then:
alter table employeeindex drop index ix_employee_name;
alter table employeeindex drop index ix_employee_position;

-- During indexing SQL creates partition and stores 
-- according to itself

-- But if you only wanna give the partitions based on your 
-- Criteria only, then, we can do that as well

-- So, lets create a table by pre-partitioning it
-- BEFORE THAT, note that partitioning only works when 
-- Default engine is InnoDB
show variables like 'default_storage_engine';

-- Creating a table by Partitioning:
create table t1(id int,year_col int) 
partition by range(year_col)
(partition p0 values less than (1991),
partition p1 values less than (2001),
partition p2 values less than (2011),
partition p3 values less than (2021),
partition p4 values less than MAXVALUE
);

-- Lets check if the partitions are created or not:
EXPLAIN SELECT * FROM t1;
-- Here we can hence see the created partitions from P0 to P4
-- Now as we'll keep inserting data, based on the select 
-- criteria that data will be pushed only into the given partition 

-- Lets create a procedure to insert random data:



call insert_T1_final(1985,2040);

-- Lets try searching specific data:
SELECT * FROM T1 WHERE YEAR_COL=1994;    

-- Now lets see what is the partion 
EXPLAIN SELECT * FROM T1 WHERE YEAR_COL=1991;
-- As we can see, the partition is P1 (as when we mentioned
-- the condition anything below 2001 but more than 1991 will
-- be sent to P1)

-- Also NOTE among all the rows, only the rows in that
-- Particular partition were fetched 
-- This helps in mkaing the queries wayy faster


-- Another Example;
create table ORDERS2(order_id int,
customer_id int, order_date date, order_amount decimal(10,2))
 partition by range(TO_DAYS(order_date))
 (partition p0 values less than (TO_DAYS('1991-01-01')),
 partition p1 values less than (TO_DAYS('2001-01-01')),
 partition p2 values less than (TO_DAYS('2011-01-01')),
 partition p3 values less than (TO_DAYS('2021-01-01')));
 
 
 -- Now, the thing is if there is a primary key in the 
 -- table then it is necessary that the partitions must 
 -- be based on  that key only.
 -- The example for that: 
 
 create table ORDERS3(order_id int PRIMARY KEY,
customer_id int, order_date date, order_amount decimal(10,2))
 partition by range(ORDER_id)
 (partition p0 values less than(20),
 partition p1 values less than (40),
 partition p2 values less than (60),
 partition p3 values less than (90));         
 
 -- The above query went well as the primary key itself 
 -- was the criteria for being partitioned.
 -- If we would have used any other key than this, in that case
 -- it would have thown an error
 
 
-- INFORMATION ---------------------------------------------
-- All columns used in the partitioning expression for 
-- a partitioned table must be part of every unique key that 
-- the table may have.

-- In other words, every unique key on the table must use every 
-- column in the table's partitioning expression.
-- ----------------------------------------------------------
