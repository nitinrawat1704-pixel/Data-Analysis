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
