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
