--SQL Advance Case Study


select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from DIM_CUSTOMER
select * from DIM_LOCATION
select * from DIM_DATE
select * from FACT_TRANSACTIONS

select Manufacturer_Name,sum(quantity) 
from FACT_TRANSACTIONS as F full join DIM_MODEL as M on F.IDModel=m.IDModel 
full join DIM_MANUFACTURER as MM on MM.IDManufacturer=m.IDManufacturer
where year([Date])=2009 or year([Date])= 2010
group by Manufacturer_Name


--Q1--BEGIN 
select * from DIM_LOCATION
select * from FACT_TRANSACTIONS;
select * into  copy_transactions from FACT_TRANSACTIONS ;
select * from copy_transactions

select convert(varchar,date,112) from copy_transactions;

select state from DIM_location as l full join copy_transactions as T on l.idlocation=t.idlocation
where  convert(varchar,date,112) >20050000
group by state



--Q1--END

--Q2--BEGIN
	
	Select state,Count(state) as Number from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
	full join FACT_TRANSACTIONS as T on T.IDModel= MM.IDModel 
	full join DIM_LOCATION as L on L.IDLocation=T.IDLocation
	where Manufacturer_Name= 'Samsung'
	group by state
	order by Count(State) DESC






--Q2--END

--Q3--BEGIN      
	
	Select Model_name,State,Zipcode,Count(IDCustomer) as Number from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
	full join FACT_TRANSACTIONS as T on T.IDModel= MM.IDModel 
	full join DIM_LOCATION as L on L.IDLocation=T.IDLocation
	group by Model_Name,ZipCode,State
	

	






--Q3--END

--Q4--BEGIN

	
	
	Select Top 1 Manufacturer_Name,Model_Name,Unit_price from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
	full join FACT_TRANSACTIONS as T on T.IDModel= MM.IDModel 
	full join DIM_LOCATION as L on L.IDLocation=T.IDLocation
	order by Unit_price 
	




--Q4--END

--Q5--BEGIN

	WITH CTE as	
	(
	select TOP 5 manufacturer_name,SUM(Quantity) as Qty_sold,AVG(Unit_price) as avg_price from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
	full join FACT_TRANSACTIONS as T on T.IDModel= MM.IDModel 
	full join DIM_LOCATION as L on L.IDLocation=T.IDLocation 
	group by Manufacturer_Name
	order by Qty_sold DESC
	),
	CTE2 as (Select manufacturer_name from CTE)	

	Select Manufacturer_Name, IdModel,AVG(Unit_price)as AVG_price from DIM_MODEL as MM full join DIM_MANUFACTURER as M on MM.IDManufacturer=M.IDManufacturer
	where Manufacturer_Name  in (Select * from CTE2)
	group by IDModel,Manufacturer_Name







--Q5--END

--Q6--BEGIN


select Customer_Name,avg(Totalprice) as Avg_spent from DIM_CUSTOMER as C full join copy_transactions as T on c.IDCustomer=T.IDCustomer
where year(date) =2009
group by Customer_Name
Having avg(Totalprice)>500




--Q6--END
	
--Q7--BEGIN  


WITH CTE AS	
(
	SELECT IdModel,
	ROW_NUMBER() OVER (PARTITION BY YEAR([Date]) ORDER BY sum(Quantity) DESC  ) as rnk, YEAR([date]) as Yr
	FROM FACT_TRANSACTIONS
	WHERE YEAR([Date]) IN (2008, 2009, 2010) 
	group by year([date]),IDModel
	), 
 CTE2 as
 (
	select IDModel,rnk from CTE where rnk<=5 
 )

select IdModel,Count(rnk) as Times_in_TOP_5_model_consecutive_yr from CTE2
group by IDModel
having Count(IDModel)=3







--Q7--END	
--Q8--BEGIN

	
---
WITH CTE AS
(	
	select Manufacturer_Name,Year(date) as yr, SUM(TotalPrice) as Q, 
	rank () over ( partition by year(date) order by SUM(TotalPrice) DESC) as R from 
		FACT_TRANSACTIONS as T full join DIM_Model as M on t.IDModel=m.IDModel 
		full join DIM_MANUFACTURER as MM on MM.IDManufacturer=m.IDManufacturer 
	where  year(date)= 2009 or  year(date)=2010
	group by Manufacturer_Name,Year(date)
)

Select Manufacturer_name,yr from CTE where R=2




--Q8--END
--Q9--BEGIN
	
select * from DIM_MANUFACTURER
select * from DIM_MODEL
select * from FACT_TRANSACTIONS


select Manufacturer_Name as Total_Sales from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
full join FACT_TRANSACTIONS as T on T.IDModel=MM.IDModel
where year(date)=2010 AND 
 Manufacturer_Name not in 
(
select Manufacturer_Name as Total_Sales from DIM_MANUFACTURER as M full join DIM_MODEL as MM on M.IDManufacturer=MM.IDManufacturer 
full join FACT_TRANSACTIONS as T on T.IDModel=MM.IDModel
where year(date)=2009
group by Manufacturer_Name
)
group by Manufacturer_Name















--Q9--END

--Q10--BEGIN



select * from DIM_CUSTOMER
select * from FACT_TRANSACTIONS

Select T1.Customer_Name,T1.Yr,T1.Avg_Expense,T1.Avg_QTY,

	CASE
        WHEN T2.Yr IS NOT NULL
        THEN FORMAT((T1.Avg_Expense-T2.Avg_Expense)/(T2.Avg_Expense),'p') ELSE NULL 
        END AS 'YEARLY_%_CHANGE'
		from
(
select C.Customer_Name,YEAR(T.date) as Yr,AVG(T.TotalPrice)as Avg_Expense,AVG(T.Quantity) as Avg_QTY from FACT_TRANSACTIONS as T left join dim_customer as C on t.idcustomer=c.IDCustomer
where T.IdCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) DESC)
group by C.Customer_Name, year(T.date)

) as T1
left join 
(
select C.Customer_Name,YEAR(T.date) as Yr,AVG(T.TotalPrice)as Avg_Expense,AVG(T.Quantity) as Avg_QTY from FACT_TRANSACTIONS as T left join dim_customer as C on t.idcustomer=c.IDCustomer
where T.IdCustomer in (select top 100 IDCustomer from FACT_TRANSACTIONS group by IDCustomer order by SUM(TotalPrice) DESC)
group by C.Customer_Name, year(T.date)
) as T2 
on T1.Customer_Name=T2.Customer_Name and T2.Yr=T1.Yr-1




--Q10--END
