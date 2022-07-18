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
    ticker
    , price
    from trading.prices
    where ticker = 'ETH'
    and market_date = '2021-08-29'
    )
select
  m.region
  , sum(
      case
        when t.txn_type = 'BUY' then t.quantity
        when t.txn_type = 'SELL' then -t.quantity
        end
        ) * p.price as etherium_value
  , avg(
      case
          when t.txn_type = 'BUY' then t.quantity
          when t.txn_type = 'SELL' then -t.quantity
          end
          ) * p.price as avg_etherium_value
          
  from trading.transactions t
  
  join trading.members m
    on t.member_id = m.member_id
    
  join cte_latest_price p
    on t.ticker = p.ticker
    
  where t.ticker = 'ETH'
  group by m.region
          , cte_latest_price.price
  order by avg_etherium_value desc;