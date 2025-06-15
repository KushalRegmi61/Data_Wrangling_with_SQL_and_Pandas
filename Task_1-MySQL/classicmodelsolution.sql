use classicmodels;

-- QNO: 1
select * from  customers 
where creditLimit>20000;

-- QN0:  2
select * 
from employees
where reportsTo in  (select employeeNumber from employees where jobTitle='VP Sales');


--  Qno:  3
select * 
from  customers
where (state is not null)  and (country='USA') and (creditLimit between 100000 and 200000);


--  qn: 4
select * 
from employees
where reportsTo in (select employeeNumber from employees where jobTitle like '%Sales Manager%');

--  QNO: 5
select country, avg(creditLimit) as average_creditLimit
from customers
group by country
;

-- QNO: 6
SELECT orderDate, customerNumber, COUNT(*) AS totalOrders
FROM Orders
GROUP BY orderDate, customerNumber
HAVING totalOrders> 10;


--  QNO: 7
SELECT 
	employeeNumber,
    CONCAT(firstName, ' ', lastName) AS supervisorName,
    jobTitle,
    (SELECT COUNT(*) FROM employees e WHERE e.reportsTo = emp.employeeNumber) AS totalSupervisees
FROM employees emp
WHERE employeeNumber IN (SELECT DISTINCT reportsTo FROM employees);

-- QNO: 8
select 
	emp.employeeNumber,
	CONCAT(emp.firstName, ' ', emp.lastName) AS supervisorName,
    emp.jobTitle,
    sup.totalSupervisees    
from employees emp
join 
	(select reportsTo as employeeNumber, count(*) as totalSupervisees from employees
    group by reportsTo
    ) sup 
on emp.employeeNumber= sup.employeeNumber;


--  QNO: 9
with avg_salary as (
	select  avg(creditLimit) as avgLimit
    from customers
)
select *
from customers c , avg_salary av
where c.creditLimit>av.avgLimit;

-- QNO: 10
with orderbyCreditLimit as (
select 
	*,
    dense_rank() over(order by creditLimit desc) as creditRank
from customers
)
select * 
from orderbyCreditLimit 
where creditRank=3;


--  QNO: 11
select 
	officeCode,
    count(employeeNumber) as totalEmployeesCount
from employees
group by officeCode;


-- QNO: 12
select 
	em.officeCode,
    count(c.customerName) as totalCustomerVisits
from customers c
inner join employees em
on c.salesRepEmployeeNumber= em.employeeNumber
group by em.officeCode
order by em.officeCode;


--  QNO: 13
SELECT 
    em.officeCode, 
    ofc.state,
    ofc.country,
    SUM(py.amount) AS totalPayment
FROM customers cu
LEFT JOIN employees em ON em.employeeNumber = cu.salesRepEmployeeNumber
LEFT JOIN payments py ON cu.customerNumber = py.customerNumber
LEFT JOIN offices ofc ON em.officeCode = ofc.officeCode
WHERE em.officeCode IS NOT NULL  -- Excludes rows where officeCode is null
GROUP BY em.officeCode, ofc.state, ofc.country
ORDER BY em.officeCode;

-- QNO: 14
SELECT 
    ofc.officeCode,
    ofc.state,
    ofc.country,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
FROM customers cu
JOIN employees em ON cu.salesRepEmployeeNumber = em.employeeNumber
JOIN offices ofc ON em.officeCode = ofc.officeCode
JOIN orders ord ON ord.customerNumber = cu.customerNumber
JOIN orderdetails od ON od.orderNumber = ord.orderNumber
GROUP BY ofc.officeCode, ofc.state, ofc.country
ORDER BY ofc.officeCode;


--  QNO: 15
with officeTotalPayment as (
	SELECT 
    em.officeCode, 
    SUM(py.amount) AS totalPayment
	FROM customers cu
	JOIN employees em ON em.employeeNumber = cu.salesRepEmployeeNumber
	JOIN payments py ON cu.customerNumber = py.customerNumber
	JOIN offices ofc ON em.officeCode = ofc.officeCode
	GROUP BY em.officeCode, ofc.state, ofc.country),
officeTotalSales as (
	SELECT 
    ofc.officeCode,
    SUM(od.priceEach * od.quantityOrdered) AS totalSales
	FROM customers cu
	JOIN employees em ON cu.salesRepEmployeeNumber = em.employeeNumber
	JOIN offices ofc ON em.officeCode = ofc.officeCode
	JOIN orders ord ON ord.customerNumber = cu.customerNumber
	JOIN orderdetails od ON od.orderNumber = ord.orderNumber
	GROUP BY ofc.officeCode, ofc.state, ofc.country
)
select 
	op.officeCode,
    (os.totalSales-op.totalPayment) as totalPendingAmount
from officeTotalPayment op 
join officeTotalSales os 
on op.officeCode=os.officeCode
order by op.officeCode;

-- QNO: 16
SELECT 
    customerNumber,
    customerName,
    country, 
    creditLimit,
	SUM(creditLimit) OVER (PARTITION BY country)  as countryTotalCreditLimit,
    round((creditLimit / SUM(creditLimit) OVER (PARTITION BY country)) , 4) AS creditLimitProportion
FROM 
    customers
order by country;

-- QNO: 17
CREATE VIEW CustomerOrders AS
SELECT 
    cu.customerName,
    CONCAT_WS(', ', cu.addressLine1, cu.addressLine2, cu.city, cu.state, cu.postalCode, cu.country) AS completeAddress,
    COUNT(od.orderNumber) AS totalOrders
FROM customers cu
LEFT JOIN orders od ON od.customerNumber = cu.customerNumber
GROUP BY cu.customerNumber, cu.customerName, completeAddress;

select * from CustomerOrders order by totalOrders desc;


-- QNO: 18
update customers
set 
	customerName='don me',
    phone='98445577777'
where customerNumber=103;


select * from customers where customerNumber=103;


set sql_safe_updates=0;

--  QNO: 19
DELETE FROM payments
WHERE amount< 20000;




-- QNO: 20
INSERT INTO payments (customerNumber, checkNumber, paymentDate, amount)
VALUES (103, 'CHK12345', '2025-01-11', 15000.00);
 










