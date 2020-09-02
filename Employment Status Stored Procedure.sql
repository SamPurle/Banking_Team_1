use bankingT1

go
create or alter proc employment_status
(
	@accountid int
)
as
begin;
	
	with cte1 as 
	(
	select accountid, cleandate, balanceaftertrans,
	
		lag(balanceaftertrans, 1) over (partition by accountid order by cleandate asc) as lag_balance,
	
		balanceaftertrans - lag(balanceaftertrans, 1) over (partition by accountid order by cleandate asc) as b_diff
	
	from clean.trans
	where accountid = @accountid
	), 
	cte2 as (
	select
		avg(b_diff) as avg_change
	from cte1
	)
	select top 1 cte1.accountid, max(cleandate) as last_date, 
		case 
			when cte2.avg_change > cte1.b_diff and cleandate = max(cleandate) then 'Questionable'
			when cte2.avg_change <= cte1.b_diff and cleandate = max(cleandate) then 'Solid'
		end as Employment_Status
	from cte1, cte2
	group by cte2.avg_change, cte1.b_diff, cte1.cleandate, cte1.accountid
	order by max(CleanDate) desc 
	
end;
go

exec employment_status @accountid = 1
exec employment_status @accountid = 3