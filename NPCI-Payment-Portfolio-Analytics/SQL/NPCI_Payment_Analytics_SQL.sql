-- 1. Payment Product Performance 
select payment_product,count(*),round(sum(amount),2) from transactions where transaction_status="Success" group by 1 order by 3 desc;

-- 2. Payment Product Success Rate 
select payment_product,concat((sum(case when transaction_status="Success" then 1 else 0 end)/count(*))*100,"%") as "success%"
from transactions 
group by 1 order by 2 desc;

-- 3. Payment Channel Performance 
select payment_channel,count(*)as "ttl successful tnx",round(sum(amount),2) as"ttl successful value" 
from transactions 
where transaction_status="Success" 
group by 1 order by 3 desc;

-- 4. City Transaction Performance
select city ,count(*) as "ttl successful tnx",round(sum(amount),2) "ttl successful value"
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by 1 order by 3 desc;

-- 5. Merchant Category Performance

select category ,count(*) as "ttl successful tnx",round(sum(amount),2) "ttl successful value"
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by 1 order by 3 desc;

-- 6. Top 10 Customers by Transaction Value
 
select * from 
(select c.customer_id,round(sum(amount),2)as "successful tnx value",count(*) ,dense_rank()over(order by sum(amount) desc) as rnk
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success"
group by 1) as y where rnk <11;

-- 7. Customer Transaction Frequency
select * from 
(select c.customer_id,count(*) as "successful tnx count",dense_rank()over(order by count(*) desc) as rnk
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success"
group by 1) as y where rnk <11;

-- 8 Customer Average Transaction Value

select * from 
(select c.customer_id,round(avg(amount),2) as "avg amount",dense_rank()over(order by avg(amount) desc) as rnk
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success"
group by 1) as y where rnk <11;


-- 9. High-Value Customers
with cte as (
select customer_id,sum(amount) as "ttl_amt" 
from transactions 
where transaction_status="Success" group by 1
)
select customer_id,round(ttl_amt,2) as "total amount" from cte where ttl_amt >
(select avg(ttl_amt) from cte);

-- 10. Customer Payment Product Usage

select c.customer_id,group_concat(distinct(payment_product)) as "Payment_products" ,count(distinct(payment_product)) as "count"
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success" group by 1 order by 3 desc;

-- 11. Top Merchants by Transaction Value 

select * from
(
select merchant_id,round(sum(amount),2)"ttl amount",count(*) as "ttl tnx" ,dense_rank()over(order by sum(amount) desc) as rnk 
from transactions 
where transaction_status="Success"
group by 1 
) as t where rnk <11;


-- 12. Merchant Category Performance

select category,round(sum(amount),2)"ttl amount",round(avg(amount),2)"avg amount",count(*) as "ttl tnx" 
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by 1 order by 2 desc;

-- 13. Merchant Performance by City

select city,round(sum(amount),2)"ttl amount",round(avg(amount),2)"avg amount",count(*) as "ttl tnx" 
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by 1 order by 2 desc;

-- 14. Monthly Transaction Growth

select date_format(transaction_date,'%M-%Y') as d,round(sum(amount),2)"ttl amount",round(avg(amount),2)"avg amount",count(*) as "ttl tnx"  
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by 1 order by min(transaction_date);

-- 15. Month-over-Month Growth

with cte as 
(
select date_format(transaction_date,'%m-%Y') as d ,round(sum(amount),2) as "ttl_amount",YEAR(transaction_date) AS yr,MONTH(transaction_date) AS mn 
from merchants m inner join transactions t on m.merchant_id=t.merchant_id
where transaction_status="Success"
group by date_format(transaction_date,'%m-%Y'),YEAR(transaction_date),MONTH(transaction_date)
)
select d,ttl_amount,lag(ttl_amount)over(order by yr,mn) as "previous month" ,
concat(round(((((ttl_amount-lag(ttl_amount)over(order by yr,mn)))/lag(ttl_amount)over(order by yr,mn))*100),2),"%") as "Monthly growth"
from cte order by yr,mn;


--16. Rank Customers Within Each City

select city,c.customer_id,round(sum(amount)) as "total_transactions",dense_rank()over(partition by city order by sum(amount) desc) as rnk
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success" group by 1,2 ;

--17. Top 3 Customers per City

select * from
(
select city,c.customer_id,round(sum(amount)) as "total_transactions",dense_rank()over(partition by city order by sum(amount) desc) as rnk
from customers c inner join transactions t on c.customer_id=t.customer_id
where transaction_status="Success" group by 1,2 
) as t where rnk <4 ;

--18. Product Ranking

select payment_product,round(sum(amount)) as "total_transactions",dense_rank()over(order by sum(amount) desc) as rnk
from transactions 
where transaction_status="Success" group by 1;


--19. Offer Performance & ROI

select 
    offer_name,
    count(distinct ou.customer_id) AS customers,
    count(distinct ou.transaction_id) AS transactions,
    round(sum(reward_amount)) as "total_reward_cost",
    round(sum(amount)) as "total_amount",
	(sum(amount)-sum(reward_amount))/nullif(sum(reward_amount),0)*100 as "ROI"
from 
	offer_usage ou inner join transactions t 
	on ou.transaction_id=t.transaction_id
	inner join offers o on ou.offer_id=o.offer_id
group by 1 order by 1;


