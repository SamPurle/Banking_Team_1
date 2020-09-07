use bankingT1
go

/*
Target competitor banks
*/

;with CTE_STEAL_UR_CUSTOMERS
as
(
select top 15000
	OtherBank,
	abs(convert(money,amount)) as Amount,
	case
		when amount > 0 then 'TransIn'
		else 'TransOut'
	end as TransType
from clean.Trans
	where OtherBank > ' '
)
select
	*
from CTE_STEAL_UR_CUSTOMERS
pivot(avg(amount) for TransType in (TransIn, TransOut)) as PIVET_Average;


/*
Age segmentation
*/

;with CTE_Age 
as 
(
select distinct
	a.AccountId,
	datediff(year, BirthDate, '1998-12-31') as Age,
	case 
		when datediff(year, BirthDate, '1998-12-31') < 20 then 'Child'
		when 20 <= datediff(year, BirthDate, '1998-12-31') and datediff(year, BirthDate, '1998-12-31') < 40 then 'Young'
		when 40 <= datediff(year, BirthDate, '1998-12-31') and datediff(year, BirthDate, '1998-12-31') < 60 then 'Middle Aged'
		else 'Old'
	end as AgeBracket,
	avg(BalanceAfterTrans) over (partition by t.AccountId) as MeanBalance
from Clean.Account as a
inner join Clean.Disposition as d
	on a.AccountId = d.AccountId
inner join Clean.Client as c
	on d.ClientId = c.ClientId
inner join Clean.Trans as t
	on a.AccountId = t.AccountId
)

select distinct
	AgeBracket,
	count(*) as AccountCount,
	avg(MeanBalance) as MeanNetWorth,
	sum(MeanBalance) as SumNetWorth
from CTE_Age
group by AgeBracket