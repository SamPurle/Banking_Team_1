use bankingT1


with cte1 as 
(
select accountid, cleandate, balanceaftertrans,

	lag(balanceaftertrans, 1) over (partition by accountid order by cleandate asc) as lag_balance,

	balanceaftertrans - lag(balanceaftertrans, 1) over (partition by accountid order by cleandate asc) as b_diff

from clean.trans
), 
cte2 as (
select
	avg(b_diff) as avg_change
from cte1
), 
cte3 as (
select top 1 with ties cte1.accountid, max(cleandate) as last_date, 
	case 
		when cte2.avg_change > cte1.b_diff and cleandate = max(cleandate) then 'Questionable'
		when cte2.avg_change <= cte1.b_diff and cleandate = max(cleandate) then 'Solid'
	end as Employment_Status
from cte1, cte2
where accountid between 1 and 11382
group by cte2.avg_change, cte1.b_diff, cte1.cleandate, cte1.accountid
order by max(CleanDate) desc
)
select 
count (
	case
		when Employment_Status = 'Solid' then' Solid'
	end
	) as Num_Solid,
count (
	case
		when Employment_Status = 'Questionable' then 'Questionable'
	end
	) as Num_Questionable
from cte3
