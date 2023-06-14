24-05-2023

CREATE DEFINER=`root`@`localhost` PROCEDURE `update_salary`(id int, amount int)
BEGIN
    update employee set salary = amount where emp_id=id;
END
CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_dummy_emp`(start_id int, end_id int)
BEGIN
    declare i int;
    set i = start_id;
    while i<=end_id do
        if i%2=0 then
            insert into employee(emp_id,name,age,salary,joining_date,department) values (i,concat("Emp",i),i*2,i*100,curdate(),"Development");
        else
            insert into employee(emp_id,name,age,salary,joining_date,department) values (i,concat("Emp",i),i*2,i*1000,curdate(),"Production Management");
        end if;
        set i = i+1;
    end while;
END
CREATE DEFINER=`root`@`localhost` FUNCTION `gt_salary`(amt int) RETURNS int
BEGIN
    RETURN (select count(emp_id) from employee where salary>=amt);
END
CREATE DEFINER=`root`@`localhost` FUNCTION `percentageExpenditureFromTotal`(gt_amt int) RETURNS int
BEGIN
RETURN (select ((select eq_salary(gt_amt)*gt_amt)/sum(salary)) * 100 as percentage from employee);
END
CREATE DEFINER=`root`@`localhost` FUNCTION `eq_salary`(amt int) RETURNS int
BEGIN
    RETURN (select count(emp_id) from employee where salary=amt);
END
use salaryds;
select * from employee;
alter table employee add column ctc int;
update employee set ctc = (salary*12)+10000;
create trigger ctc_update
before update on employee
for each row
set new.ctc = (new.salary*12)+10000;
create trigger ctc_insert
before insert on employee
for each row
set new.ctc = (new.salary*12)+10000;
select * from employee;
call insert_dummy_emp(11,20);
call update_salary(2,4000);
select gt_salary(4000);
select eq_salary(4000);
select percentageExpenditureFromTotal(4000);
-- Finding the maximum salary as per department and comparing with other employees from the same department.
select e.*, max(salary) over(partition by department) as max_salary from employee e;
-- Selecting the employees with highest salary from every department
select * from 
(select e.*, dense_rank() over(partition by department order by salary desc) as salary_rank 
from employee e)x 
where x.salary_rank=1;
select e.*, dense_rank() over(partition by department order by salary desc) as salary_rank from employee e;
-- Comparing salary of the previous employee and the next employee with the current employee
select e.*, 
lag(salary) over(partition by department order by emp_id) as prev_salary, 
lead(salary) over(partition by department order by emp_id) as next_salary 
from employee e;
select * from employee;