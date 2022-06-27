-- Q1
select * from trading.transactions;
where member_id = 'c4ca42'
order by txn_time desc
limit 10;

-- Q2
select count(*) from trading.transactions;
select distinct count(*) from trading.transactions;

-- Q3
select distinct txn_type
  , count(*) as transaction_count
  from trading.transactions
  where ticker = 'BTC'
  group by txn_type;
  
-- Q4
select distinct date_part('year', txn_date) as txn_year
  , txn_type
  , count(*) as transaction_count
  , round(sum(quantity)::numeric, 2) as total_quantity
  , round(avg(quantity)::numeric, 2) as average_quantity
  from trading.transactions
  where ticker = 'BTC'
  group by date_part('year', txn_date)
    , txn_type
  order by date_part('year', txn_date)
    , txn_type;
    
-- Q5
select date_trunc('month', txn_date)::date as calendar_month
  , sum(case when txn_type = 'BUY'
          then quantity
          else 0 
          end) as buy_quantity
  , sum(case when txn_type = 'SELL'
          then quantity
          else 0 
          end) as sell_quantity
  from trading.transactions
  where ticker = 'ETH'
  and date_part('year', txn_date) = '2020'
  group by calendar_month;
  
-- Q6
select member_id
/* BTC */
  , sum(case when txn_type = 'BUY' and ticker = 'BTC'
          then quantity
          else 0 
          end) as btc_buy_qty
  , sum(case when txn_type = 'SELL' and ticker = 'BTC'
          then quantity
          else 0 
          end) as btc_sell_qty
/* ETH */
  , sum(case when txn_type = 'BUY' and ticker = 'ETH'
          then quantity
          else 0 
          end) as eth_buy_qty
  , sum(case when txn_type = 'SELL' and ticker = 'ETH'
          then quantity
          else 0 
          end) as eth_sell_qty
  from trading.transactions
  group by member_id;

-- Q7
select member_id
, sum(case when txn_type = 'BUY'
        then quantity
        else 0
        end) - 
  sum(case when txn_type = 'SELL'
        then quantity
        else 0
        end) as final_btc_holding
        
from trading.transactions
-- where txn_type = 'BUY'
where ticker = 'BTC'
group by member_id
order by final_btc_holding desc;

-- Q8 
with sold_qty as (
select member_id
  , sum(case when txn_type = 'SELL' and ticker = 'BTC'
          then quantity
          else 0
          end) as btc_sold_quantity
  from trading.transactions
  group by member_id
  )

select member_id
  , btc_sold_quantity
  from sold_qty
  where btc_sold_quantity < 500
  order by btc_sold_quantity desc

-- Q9
select member_id
, sum(case when txn_type = 'BUY'
        then quantity
        else 0
        end) - 
  sum(case when txn_type = 'SELL'
        then quantity
        else 0
        end) as final_btc_holding
        
from trading.transactions
-- where txn_type = 'BUY'
where ticker = 'BTC'
group by member_id
order by final_btc_holding desc;

--Q10 
with buy_to_sell as (
select member_id
  , sum(case when txn_type = 'BUY'
            then quantity
            else null
            end) / 
    sum(case when txn_type = 'SELL'
            then quantity
            else null
            end) as buy_to_sell_ratio
  from trading.transactions
  group by member_id
  )
  
  select member_id
  , buy_to_sell_ratio
  from buy_to_sell
  order by buy_to_sell_ratio desc;

-- Q11
with eth_sold as (
  select member_id
    , date_trunc('month', txn_date)::date as calendar_month
    , sum(quantity) as sold_eth_quantity
    , rank() over (partition by member_id order by sum(quantity) desc) as month_rank
    from trading.transactions
    where ticker = 'ETH' and txn_type = 'SELL'
    group by member_id, date_trunc('month', txn_date)
  )

select member_id
  , calendar_month
  , sold_eth_quantity
  from eth_sold
  where month_rank = 1
  order by sold_eth_quantity desc;

  