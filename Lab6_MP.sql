-- Question 1  
drop table if exists temp_portfolio_base;

create temp table temp_portfolio_base as
with cte_data as (
  select
    members.first_name
    , members.region
    , transactions.txn_date
    , transactions.ticker
    , case
        when transactions.txn_type = 'SELL' then -transactions.quantity
        else transactions.quantity
      end as adjusted_quantity
      from trading.transactions
      join trading.members
        on transactions.member_id = members.member_id
      where transactions.txn_date <= '2022-12-31'
      )
  select
    first_name
    , region
    , (date_trunc('Year', txn_date) + interval '12 Months' - interval '1 Day')::date as year_end
    , ticker
    , sum(adjusted_quantity) as yearly_quantity
    from cte_data
    group by first_name, region, year_end, ticker;

-- Question 2 
select year_end
  , ticker
  , yearly_quantity
  from temp_portfolio_base
  where first_name = 'Abe'
  order by ticker, year_end;

-- Question 3
select year_end
  , ticker
  , yearly_quantity
  , sum(yearly_quantity) over (
    partition by first_name, ticker
    order by ticker, year_end) as cumulative_quantity
  from temp_portfolio_base
  where first_name = 'Abe'
  order by ticker, year_end;

-- Question 4
-- add a new column to temp table
alter table temp_portfolio_base 
  add column cumulative_quantity numeric;

-- add data to new column
update temp_portfolio_base 
set cumulative_quantity = (
  select sum(yearly_quantity) over (
    partition by first_name, ticker
    order by year_end
    )
  );

-- Question 4 part 2
drop table if exists temp_cumulative_portfolio_base;
create temp table temp_cumulative_portfolio_base as
  select
    first_name
    , region
    , year_end
    , ticker
    , yearly_quantity
    , sum(yearly_quantity) over (
        partition by first_name, ticker
        order by year_end
        ) as cumulative_quantity
    from temp_portfolio_base;
    
select * from temp_cumulative_portfolio_base limit 20;