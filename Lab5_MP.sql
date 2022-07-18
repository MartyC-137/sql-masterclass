-- Question 1
select 
  min(txn_date) as earliest_date
  , max(txn_date) as latest_date
  from trading.transactions;

-- Question 2
select
  min(market_date) as earliest_date
  , max(market_date) as latest_date
from trading.prices limit 10;

-- Question 3
select 
  m.first_name
  , sum(
    case
      when t.txn_type = 'BUY' then t.quantity
      when t.txn_type = 'SELL' then -t.quantity
      end
      ) as total_quantity
  from trading.members m
  join trading.transactions t
    on m.member_id = t.member_id
  where t.ticker = 'BTC'
  group by m.first_name
  order by total_quantity desc
  limit 3;

-- Question 4 
with cte_latest_price as (
  select
    ticker,
    price
  from trading.prices
  where ticker = 'ETH'
  and market_date = '2021-08-29'
)
select
  members.region,
  sum(
    case
      when transactions.txn_type = 'BUY'  then transactions.quantity
      when transactions.txn_type = 'SELL' then -transactions.quantity
    end 
  ) * cte_latest_price.price as ethereum_value,
  avg(
    case
      when transactions.txn_type = 'BUY'  then transactions.quantity
      when transactions.txn_type = 'SELL' then -transactions.quantity
    end 
  ) * cte_latest_price.price AS avg_ethereum_value
from trading.transactions
join  cte_latest_price
  on transactions.ticker = cte_latest_price.ticker
join  trading.members
  ON transactions.member_id = members.member_id
where transactions.ticker = 'ETH'
group by members.region, cte_latest_price.price
order by avg_ethereum_value desc;