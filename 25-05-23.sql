USE Cohort361;

-- So now we'll see the concept of triggers
-- Triggers are used to fire a reaction for a particular reaction

-- So we have a employee table, and anytime we update the values of that
-- table, we need the information to be stored that what was the 
-- value that we updated and what was the time at which updation happened!?

-- SO creating the employee and the employeeaudit tables:
 
CREATE TABLE employeetrigger(
id INT auto_increment primary key,
last_name VARCHAR(255) not null
);

CREATE TABLE employeeaudit(
id int auto_increment primary key,
last_name varchar(255) not null,
changedate datetime default null,
action varchar(255) default null
);


-- Now, lets create a trigger to validate what we want:

CREATE TRIGGER before_employee_update -- naming the trigger
BEFORE UPDATE ON employeetrigger -- setting the action type and table
FOR EACH ROW -- taking into account multiple rows' modifications
INSERT INTO employeeaudit -- what to do when trigerred
SET action = 'update', -- mentioning action type
last_name = OLD.last_name, -- storing previous value into new table
changedate = NOW(); -- getting the current timestamp

-- Inserting values into the employee table:
INSERT INTO employeetrigger (last_name) VALUES ('Rajwansh');
-- The values have been inserted and there is nothing in the 
-- audit table
SELECT * FROM employeeaudit;
SELECT * FROM employeetrigger;
-- Now lets update something:
UPDATE employeetrigger SET last_name = 'Sharma' WHERE id = 1;
-- Now the main table holds the updated value BUT 
-- the audit table has the previous change details and time of that
-- change in the table; 
SELECT * FROM employeeaudit;
SELECT * FROM employeetrigger;
-- Repeating the process a few more times:
INSERT INTO employeetrigger (last_name) VALUES ('Vishwakarma');
INSERT INTO employeetrigger (last_name) VALUES ('Banarjee');

UPDATE employeetrigger SET last_name = 'Dodeja' WHERE id = 3;

SELECT * FROM employeeaudit;

-- Now, just like we have created for updation, we can do the 
-- same thing for other actions as well (like insertion, etc)

-- Lets try insertion in the same table:
CREATE TRIGGER before_employee_insert
BEFORE INSERT ON employeetrigger
FOR EACH ROW
INSERT INTO employeeaudit
SET action = 'insert',
last_name = NEW.last_name,
changedate = NOW();

INSERT INTO employeetrigger (last_name) VALUES ('Soni');

SELECT * FROM employeeaudit;

-- Trying for deletition:
CREATE TRIGGER before_employee_delete
BEFORE DELETE ON employeetrigger
FOR EACH ROW
INSERT INTO employeeaudit
SET action = 'delete',
last_name = OLD.last_name,
changedate = NOW();

DELETE FROM employeetrigger WHERE id = 2;
SELECT * FROM employeeaudit;

-- So like this we can create the record of 
-- MODIFICATION of TABLE A into TABLE B;

-- NOW lets look into an example of AFTER trigger:
-- An important use case of data validation

CREATE TABLE members(
id int auto_increment,
name varchar(100) not null,
email varchar(255),
birthdate date,
primary key(id)
); 

create table reminders(
id int auto_increment, 
memberid int,
message varchar(400),
primary key(id, memberid) 
);
-- So, we have created a table with details of a person and if
-- that person doesn't enter his/her DOB, then in that case we wanna
-- remind that person to enter his details using the other table.
 
 
 -- So, creating the AFTER trigger for the same:
DELIMITER $$
CREATE TRIGGER after_member_insert
AFTER INSERT ON members
FOR EACH ROW
FOLLOWS before_member_insert
BEGIN
	IF NEW.birthdate is NULL THEN
		INSERT INTO reminders(memberID, message)
        VALUES (NEW.id,
        CONCAT("Hi ",NEW.name,' please insert your DOB.'));
	END IF;
END$$

-- Testing with values
INSERT INTO members (name, email, birthdate) VALUES
('Arya','arya@gmail.com',NULL),
('Abhi','abhi@gmail.com','2000-01-05');

-- Now when we see members table, we have records with 
-- DOB as null as well as not null

-- But when we see reminders, it has all the logs and reminder
-- message for recods with DOB as null 

SELECT * FROM members;
SELECT * FROM reminders;

-- So, after is basically for validating stuff one a particular 
-- action has been taken 

-- An interestig observation of AFTER command:

create trigger after_member_insert1
after insert
on members for each row
begin
	IF NEW.birthdate is NULL then
		update members set birthdate='1900-01-01' where id=NEW.id;
	END IF;
END$$

-- Now, see this, here we are trying to upadte the same table with an 
-- after trigger. Now this is likely to cause a deadlock. As same table 
-- will be updated by the trigger and the trigger will be triggered
-- adain to uodate the same table... And this will keep on continuing.

-- Hence, MySQL will not permit the below command to RUN as after
INSERT INTO members(name, email,birthDate)
values('temp1','hsadkjhsd@gmail.com',NULL);
('temp','tegdjksag@gmail.com','2000-01-01');

-- ------------------------------------------------------------------
-- Now, TRIGGERS are basically used to update a different table 
-- in order to maintain logs. Be it before or after. So, it is a 
-- good practice to not use triggers in the same table
-- ------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER before_member_insert
AFTER INSERT ON members
FOR EACH ROW
BEGIN
	IF NEW.birthdate is NULL THEN
		INSERT INTO reminders(memberID, message)
        VALUES (NEW.id,
        CONCAT("Your data has been prechecked."));
	END IF;
END$$

DROP TRIGGER after_member_insert;


INSERT INTO members(name, email,birthDate)
values('temp1','hsadkjhsd@gmail.com',NULL),
('temp','tegdjksag@gmail.com','2000-01-01');

SELECT * FROM reminders;

-- Now see we can also do validation using before but
-- The issue is the gets validated and due to something, it
-- doesn't get inserted then it will show the validation
-- for the data which doesn't even exist! So that's not good!
-- --------------------------------------------------------------------

-- FOR more than one conditions of modifications  we can use OR
-- like 
-- ...........AFTER (INSERT OR UPDATE)............

-- Another Example:
-- This is a very good example of data check and pre validation

-- Suppose we have a table as Sales:
CREATE TABLE sales(id int auto_increment, 
product varchar(400) not null,
quantity int not null default 0, 
fiscialyear smallint not null,
fiscalmonth smallint not null, 
check(fiscalmonth >= 1 AND fiscalmonth <= 12),
check(quantity >= 0),
unique(product, fiscalmonth, fiscialyear),
primary key(id));
-- Now first check is itself implemented in the table
-- creation in the form od check constraint
-- So, no values except that would be accepted in the table

INSERT INTO sales(product, quantity, fiscialyear, fiscalmonth)
VALUES
('Harley Davidson Street 150',123,2009,1),
('Hero Splendor Plus',500,2022,6),
('Kawasaki Ninja 350',300,2019,5);

SELECT * FROM sales;

-- Now, this time the constraint that we are creating is based on 
-- displaying an error message

DELIMITER $$
CREATE TRIGGER before_sales_update -- trigger name
BEFORE UPDATE -- trigger type
ON sales FOR EACH ROW -- the table on which trigger has to be implemented
BEGIN -- start of body
	DECLARE errorMessage VARCHAR(255); -- declare variable to store msg
    SET errorMessage = CONCAT('The new quantity ',NEW.quantity,' cannot be 3 times greater than current quantity ',
    OLD.quantity); -- provide value to the varibale 
    IF NEW.quantity > OLD.quantity * 3 THEN -- if a condition satisfied
		SIGNAL SQLSTATE '45000' -- signal the error state to user
			SET MESSAGE_TEXT = errorMessage; 
	END IF;
END $$


UPDATE SALES SET quantity = 1500 WHERE ID =3;
-- So, running the above query will raise an Error Code before
-- the insertion of value itself

SHOW Errors;
SHOW Triggers;

-- Now another important thing is:
-- How can someone know the priority of triggering sequences?? 

select trigger_name,action_order from information_schema.triggers
where trigger_schema= 'Cohort361'
order by event_object_table,
action_timing,
event_manipulation;

-- -----------------------------------------------------------------
-- Creating more than one actions in the same trigger:
-- Trying this in sales only:

-- For this creating another table sales_log

CREATE TABLE sales_log(
log_id INT AUTO_INCREMENT,
changed_value VARCHAR(255),
modification_type VARCHAR(255),
modification_timestamp DATETIME,
PRIMARY KEY(log_id)
);

CREATE TRIGGER modify_sales_log
BEFORE (DELETE OR INSERT OR UPDATE) 
ON employeetrigger
FOR EACH ROW
BEGIN
	IF NEW.action = 'insert' THEN
	INSERT INTO employeeaudit
	SET modification_type = 'insertion',
	changed_value = NEW.product,
	modification_type = NOW();
    END IF;
END;
-- Like what we have done above, we can add multiple manipulation 
-- options but this wont work here.. It works only in the paid version.


-- ----------------------------------------------------------------
-- Method to declare more than one variables with same datatype and 
-- defaults
declare total,y dec(10,2) default 0.0;
-- And u can use any type of DELIMITER:
-- LIke DELIMITER //
-- or   DELIMITER ++
-- or   DELIMITER $$ (etc)
-- ----------------------------------------------------------------


-- now just like we posted error messages, we can enhance 
-- such kind of functions using exit handler:

-- For this to work, we've created a stored procedure 
-- "InsertSupplierProducts" (view that)

-- Creating the table:

CREATE TABLE SUPPLIERPRODUCTS
(supplierId int, productId Int, 
PRIMARY KEY(supplierId,productId));

CALL insertSupplierProducts(1,1); -- inserts normally
CALL insertSupplierProducts(1,2); -- inserts normally
CALL insertSupplierProducts(1,3); -- inserts normally
CALL insertSupplierProducts(1,3); -- raises an error 
								  -- message that its a duplicate key
                                  -- so, not inserted
-- ----------------------------------------------------------------
-- Try getting about various exit handlers 
-- Another way is CONTINUE HANDLER (but not to be used beacuse 
-- one you've got the error, why contine!??)
-- -------------------------------------------------------------------
-- EXIT HANDLER FOR Missing Table (table not created)

CREATE DEFINER=`root`@`localhost` 
PROCEDURE `insertSupplierProducts`(IN isupplierProductId INT,IN iproductId INT)
BEGIN
	-- DUPLICATE KEY ERRORS  1062
	DECLARE EXIT HANDLER FOR 1146
	SELECT 'Please create table first' Message;
    DECLARE EXIT HANDLER FOR 1062
	BEGIN
		SELECT CONCAT('Duplicate Key (',isupplierProductId,',',iproductId,') occured') as message;
	END;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION SELECT 'SQLEXCEPTION ENCOUNTERED' MEssage;
    DECLARE EXIT HANDLER FOR SQLSTATE '23000' SELECT 'CUSTOM CAPTURED' MEssage;
    
	
    INSERT INTO SUPPLIERPRODUCTS(supplierId,productId) values(isupplierProductId,iproductId);
    
    -- return the products
    select count(*) from SUPPLIERPRODUCTS where supplierId=productId;
END


