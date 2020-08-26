/*
Create "Disposable Income" metric as combination of income and expenses
*/

select top 500
	account.account_id,
	Salary,
	Expenditure,
	Salary - Expenditure as DisposableIncome
from dbo.account
inner join 
	(
	select 
		a.account_id,
		convert(money, (sum(convert( float, amount))) / ((max(convert(float, t.date)) - min(convert(float, t.date))) / 12000)) as Salary
	from dbo.account as a
	inner join dbo.trans as t
		on a.account_id = t.account_id
		where t.type = '"PRIJEM"'
	group by a.account_id
	) as Sal
on account.account_id = Sal.account_id
inner join
	(
	select 
		a.account_id,
		convert(money, (sum(convert( float, amount))) / ((max(convert(float, t.date)) - min(convert(float, t.date))) / 12000)) as Expenditure
	from dbo.account as a
	inner join dbo.trans as t
		on a.account_id = t.account_id
		where t.type = '"VYDAJ"'
	group by a.account_id
	) as Expen
on account.account_id = Expen.account_id
order by account.account_id asc