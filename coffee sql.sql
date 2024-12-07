#create database Coffee_shape_sales_DB

Select * from coffee_sale;
Describe coffee_sale;
# converting column text to date
UPDATE coffee_sale
Set transaction_date = str_to_date(Transaction_date, '%d-%m-%Y');

Alter table coffee_sale
Modify column Transaction_date date;

# converting column text to time
UPDATE coffee_sale
Set transaction_time = str_to_date(Transaction_time, '%H-%i-%s');

Alter table coffee_sale
Modify column Transaction_time time;

Alter table coffee_sale
change column ï»¿transaction_id transaction_id INT;


select sum(unit_price * transaction_qty) As Total_sales 
from coffee_sale
where
month(Transaction_date) = 5; -- May month

select concat((round(sum(unit_price * transaction_qty)))/1000, "k") As Total_sales 
from coffee_sale
where
month(Transaction_date) = 5; -- May month

# each month total sale
select count(transaction_id)
from coffee_sale
where
month(Transaction_date) = 5; -- May month

# to get in on edecimal form select round(sum(unit_price * transaction_qty),1) As total sales
# to get the result in k  select concat(round(sum(unit_price * transaction_qty)))/1000,"K") As Total sales

-- selected month / current month - may=5
-- previous month - april = 4
####TOTAL SALES KPI - MOM DIFFERENCE AND MOM GROWTH

SELECT 
    MONTH(transaction_date) AS month, -- Number of month
    ROUND(SUM(unit_price * transaction_qty)) AS total_sales, -- total sale column
    (SUM(unit_price * transaction_qty) - LAG(SUM(unit_price * transaction_qty), 1) -- lag used month sales differenece (previous month sales)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(unit_price * transaction_qty), 1) -- Percentage
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- month on month is difference of sales in each month
FROM 
    coffee_sale
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


SELECT 
    MONTH(transaction_date) AS month, -- Number of month
    ROUND(count(transaction_id)) AS total_orders, -- total sale column
    (count(transaction_id) - LAG(count(transaction_id), 1) -- lag used month sales differenece (previous month sales)
    OVER (ORDER BY MONTH(transaction_date))) / LAG(count(transaction_id), 1) -- Percentage
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage -- month on month is difference of sales in each month
FROM 
    coffee_sale
WHERE 
    MONTH(transaction_date) IN (4, 5) -- for months of April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);


select sum(transaction_qty) as Total_quantity
from coffee_sale
where
month(transaction_date) = 6;

SELECT 
    MONTH(transaction_date) AS month,
    ROUND(SUM(transaction_qty)) AS total_quantity_sold,
    (SUM(transaction_qty) - LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date))) / LAG(SUM(transaction_qty), 1) 
    OVER (ORDER BY MONTH(transaction_date)) * 100 AS mom_increase_percentage
FROM 
    coffee_sale
WHERE 
    MONTH(transaction_date) IN (4, 5)   -- for April and May
GROUP BY 
    MONTH(transaction_date)
ORDER BY 
    MONTH(transaction_date);



###Chart requirement


select 
	sum(unit_price * transaction_qty) as total_sales,
    sum(transaction_qty) as Total_qty_sold,
    Count(transaction_id) as total_orders
    from coffee_sale
    where
		transaction_date ='2023-05-18';
        
 select 
	concat(round(sum(unit_price * transaction_qty)/1000,1), 'K')as total_sales,
    concat(round(sum(transaction_qty)/1000,1), 'K') as Total_qty_sold,
     concat(round(Count(transaction_id)/1000,1), 'K') as total_orders
    from coffee_sale
    where
		transaction_date ='2023-03-27';       
        
-- week ends sat and sun
-- weekdays mon to fri
# sun = 1 to sat = 7

select 
	case when dayofweek(transaction_date) IN (1,7) then 'weekends'
    ELSE 'weekdays'
    end as day_type,
    SUM(Unit_price * transaction_qty) as Total_slaes
from coffee_sale
where month (transaction_date) = 5
group by
	case when dayofweek(transaction_date) IN (1,7) then 'weekends'
    ELSE 'weekdays'
    end;
    
select 
	case when dayofweek(transaction_date) IN (1,7) then 'weekends'
    ELSE 'weekdays'
    end as day_type,
    concat(round(SUM(Unit_price * transaction_qty)/1000,1), 'K') as Total_slaes
from coffee_sale
where month (transaction_date) = 2
group by
	case when dayofweek(transaction_date) IN (1,7) then 'weekends'
    ELSE 'weekdays'
    end;
    
    
Select
	store_location,
     concat(round(SUM(unit_price * transaction_qty)/1000,2), 'K') as Total_sales
from coffee_sale
where month (transaction_date) = 5
group by Store_location
order by SUM(unit_price * transaction_qty) desc;


#daily sales analysis average line

select avg(unit_price * transaction_qty) as AVG_sales
from coffee_sale
where month(transaction_date) = 5;

select
	concat(round(avg(total_sales)/1000, 1), 'K') as AVG_sales
from 
	(
    select sum(transaction_qty * Unit_price) as total_sales
    from coffee_sale
    where month(transaction_date) = 5
    group by transaction_date
    ) as internal_query;

select 
	day(transaction_date) as day_of_month,
    SUM(unit_price * transaction_qty) as total_sales
from coffee_sale
where month (transaction_date) = 5
group by day (transaction_date)
order by day (transaction_date);


##COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
SELECT 
    day_of_month,
    CASE 
        WHEN total_sales > avg_sales THEN 'Above Average'
        WHEN total_sales < avg_sales THEN 'Below Average'
        ELSE 'Average'
    END AS sales_status,
    total_sales
FROM (
    SELECT 
        DAY(transaction_date) AS day_of_month,
        SUM(unit_price * transaction_qty) AS total_sales,
        AVG(SUM(unit_price * transaction_qty)) OVER () AS avg_sales
    FROM 
        coffee_sale
    WHERE 
        MONTH(transaction_date) = 5  -- Filter for May
    GROUP BY 
        DAY(transaction_date)
) AS sales_data
ORDER BY 
    day_of_month;
    

select * from coffee_sale;

select 
	product_type,
	sum(unit_price * transaction_qty) as total_sales
from coffee_sale
where month(transaction_date) = 5 and product_category = 'coffee'
group by product_type
order by SUM(unit_price * transaction_qty) desc
limit 10;


#sales analysis by days and hours
select 
	sum(unit_price * transaction_qty) as total_sales,
    sum(transaction_qty) as total_qty_sold,
    count(*)
from coffee_sale
where month(transaction_date) = 5 -- may
And dayofweek(transaction_date) = 1 -- monday
And Hour(transaction_time) = 14; -- hour number 8


#peak hour sales

select 
	hour(transaction_time),
    sum(unit_price * transaction_qty) as Total_sales
from coffee_sale
where month(transaction_date) = 5
group by hour(transaction_time)
order by hour(transaction_time)
limit 10;


###TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
SELECT 
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END AS Day_of_Week,
    ROUND(SUM(unit_price * transaction_qty)) AS Total_Sales
FROM 
    coffee_sale
WHERE 
    MONTH(transaction_date) = 5 -- Filter for May (month number 5)
GROUP BY  
    CASE 
        WHEN DAYOFWEEK(transaction_date) = 2 THEN 'Monday'
        WHEN DAYOFWEEK(transaction_date) = 3 THEN 'Tuesday'
        WHEN DAYOFWEEK(transaction_date) = 4 THEN 'Wednesday'
        WHEN DAYOFWEEK(transaction_date) = 5 THEN 'Thursday'
        WHEN DAYOFWEEK(transaction_date) = 6 THEN 'Friday'
        WHEN DAYOFWEEK(transaction_date) = 7 THEN 'Saturday'
        ELSE 'Sunday'
    END;
