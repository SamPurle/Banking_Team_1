use bankingT1
go

/*
Salary Metric
*/

select  
	a.AccountId,
	CleanDate,
	SumDep,
	MaxDate,
	convert(money,SumDep / (datediff(year, CleanDate, MaxDate))) as Salary
from Clean.Account as a
inner join
(
select distinct top 500
	AccountId,
	sum(amount) over (partition by AccountId) as SumDep,
	max(CleanDate) over (partition by AccountId) as MaxDate
from Clean.Trans
	where amount > 0
) as t
on a.AccountId = t.AccountId

/*
Expenses Metric
*/

select  
	a.AccountId,
	CleanDate,
	SumWith,
	MaxDate,
	convert(money, SumWith / (datediff(year, CleanDate, MaxDate))) as Expenses
from Clean.Account as a
inner join
(
select distinct top 500
	AccountId,
	sum(amount) over (partition by AccountId) as SumWith,
	max(CleanDate) over (partition by AccountId) as MaxDate
from Clean.Trans
	where amount < 0
) as t
on a.AccountId = t.AccountId

/*
Cashflow Metric
*/

select  
	a.AccountId,
	CleanDate,
	SumTrans,
	MaxDate,
	convert(money, SumTrans / (datediff(year, CleanDate, MaxDate))) as CashFlow
from Clean.Account as a
inner join
(
select distinct top 500
	AccountId,
	sum(amount) over (partition by AccountId) as SumTrans,
	max(CleanDate) over (partition by AccountId) as MaxDate
from Clean.Trans	
) as t
on a.AccountId = t.AccountId