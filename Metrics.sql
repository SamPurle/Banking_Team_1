use bankingT1
go

/*
Salary Metric
*/

select  
	a.AccountId,
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

/*
Income compared to District
*/

select  
	a.AccountId,	
	convert(money,SumDep / (datediff(year, CleanDate, MaxDate))) / MeanSalary as SalaryMultiple	
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
inner join Clean.District as d
	on a.DistrictId = d.DistrictId

/*
Rank districts by Crime Rate
*/

;with CTE_CrimeRate 
as
(
select
	DistrictId,
	convert(float, Crimes96) / convert(float, Inhabitants) * 100 as CrimeRate
from Clean.District
)
select
	*,
	rank() over (order by CrimeRate desc) as CrimeRank
from CTE_CrimeRate

/*
Fraud/ML Detection
*/

go
create or alter view ViewSchema.NaughtyList
as
(
select distinct 
	t.AccountId,
	-- sum(Amount) over (partition by t.AccountId) as SumDep,
	-- max(t.CleanDate) over (partition by t.AccountId) as MaxDate,
	-- min(t.CleanDate) over (partition by t.AccountId) as MinDate,
	-- datediff(day, min(t.CleanDate) over (partition by t.AccountId), max(t.CleanDate) over (partition by t.AccountId)) / 365 as TimeSpanYears,
	-- (sum(Amount) over (partition by t.AccountId)) / (datediff(day, min(t.CleanDate) over (partition by t.AccountId), max(t.CleanDate) over (partition by t.AccountId))) * 365 as SalaryProxy,
	((sum(Amount) over (partition by t.AccountId)) / (datediff(day, min(t.CleanDate) over (partition by t.AccountId), max(t.CleanDate) over (partition by t.AccountId))) * 365) / (d.MeanSalary * 12) as SalaryMultiple,
	CrimeRank
from Clean.Trans as t
inner join Clean.Account as a
	on t.AccountId = a.AccountId
inner join 
(
	select
		*,
		rank() over (order by CrimeRate desc) as CrimeRank
	from (
	select
		DistrictId,
		convert(float, Crimes96) / convert(float, Inhabitants) * 100 as CrimeRate,
		MeanSalary
	from Clean.District
	) as CrimeRate
) as d
	on a.DistrictId = d.DistrictId
where t.Amount > 0
)
go

create or alter procedure Procs.ShowMeTheNaughties
(@IncomeMult int, @CrimeRank int)
as
begin

	select
		*
	from ViewSchema.NaughtyList
		where SalaryMultiple > @IncomeMult
		and CrimeRank <= @CrimeRank

end

exec Procs.ShowMeTheNaughties @IncomeMult = 2, @CrimeRank = 10