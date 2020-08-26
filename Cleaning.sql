use Banking
go

--Account


drop table if exists Clean.Account 
go

select
	account_id as AccountId,
	district_id as DistrictId,
	convert(date, concat('19', date), 112) as CleanDate,
	case 
		when frequency = 'POPLATEK MESICNE' then 'Monthly Issuance'
		when frequency = 'POPLATEK TYDNE' then 'Weekly Issuance'
		when frequency = 'POPLATEK PO OBRATU' then 'Issuance After Transaction'
		else NULL
	end as CleanFrequency
into Clean.Account
from dbo.Account


--Client

drop table if exists Clean.Client
go

select
	client_id as ClientId,
	convert(date, concat('19', BirthNumber), 112) as BirthDate,
	district_id as DistrictId,
	case
		when right(birth_number, 4) > 5000 then 'Female'
		else 'Male'
	end as Gender
into Clean.Client
from 
	(
	select
		*,
		case
			when right(birth_number, 4) > 5000 then birth_number - 5000
			else birth_number
		end as BirthNumber
	from dbo.Client 
	) as BirthConvert

--Disposition

drop table if exists Clean.Disposition
go

select
	disp_id as DispId,
	client_id as ClientId,
	account_id as AccountId,
	type as Type
into clean.Disposition
from dbo.Disposition

--Order

drop table if exists Clean.[Order]
go

select
	order_id as OrderId,
	account_id as AccountId,
	bank_to as DestinationBank,
	amount as Amount,
	case
		when k_symbol = 'POJISTNE' then 'Insurance payment'
		when k_symbol = 'SIPO' then 'Household'
		when k_symbol = 'LEASING' then  'Leasing'
		when k_symbol = 'UVER' then 'Loan Payment'
		else NULL
	end as CleanSymbol
into Clean.[Order]
from dbo.[Order]

--Transaction

drop table if exists Clean.Deal
go

select
	trans_id as TransactionId,
	account_id as AccountId,
	convert(date, concat('19', date), 112) as CleanDate,
	case
		when type = 'PRIJEM' then 'Credit'
		when type = 'VYDAJ' then 'Withdrawal'
		else NULL
	end as TransactionType,
	case 
		when operation = 'VYBER KARTOU' then 'Credit Card Withdrawal'
		when operation = 'VKLAD' then 'Credit in Cash'
		when operation = 'PREVOD Z UCTU' then 'Collection from another Bank'
		when operation = 'VYBER' then 'Withdrawal in Cash'
		when operation = 'PREVOD NA UCET' then 'Remittance to another Bank'
		else NULL
	end as CleanOperation,
	amount as Amount,
	balance as Balance,
	case
		when k_symbol = 'POJISTNE' then 'Insurance payment'
		when k_symbol = 'SLUZBY' then 'payment for statement'
		when k_symbol = 'UROK' then 'interest credited'
		when k_symbol = 'SANKC. UROK' then 'sanction interest if negative balance'
		when k_symbol = 'SIPO' then 'household'
		when k_symbol = 'DUCHOD' then 'old-age pension'
		when k_symbol = 'UVER' then 'loan payment'
		else NULL
	end as CleanSymbol,
	bank as DestinationBank,
	account as DestinationAccount
into Clean.Deal
from dbo.Deal


--Loan

drop table if exists Clean.Loan
go

select
	loan_id as LoanId,
	account_id as AccountId,
	convert(date, concat('19', date), 112) as CleanDate,
	amount as Amount,
	duration as Duration,
	payments as Payments,	
	case 
		when [status] = 'A' then 'contract finished, no problems'
		when [status] = 'B' then 'contract finished, loan not payed'
		when [status] = 'C' then 'running contract, OK so far'
		when [status] = 'D' then 'running contract, client in debt'
		else NULL
	end as LoanStatus
into Clean.Loan
from dbo.Loan

--Card

drop table if exists Clean.Card
go

select
	card_id as CardId,
	disp_id as DispId,
	type as Type,
	convert(date, left(concat('19', issued), 8), 112) as IssueDate
into Clean.Card
from dbo.Card

--District

drop table if exists Clean.District
go

CREATE TABLE Clean.[District](
	DistrictId int identity  NOT NULL,
	DistrictName [nvarchar](50) NOT NULL,
	Region [nvarchar](50) NOT NULL,
	Inhabitants [int] NOT NULL,
	Mun499 [nvarchar](50) NOT NULL,
	Mun1999 [nvarchar](50) NOT NULL,
	Mun9999 [nvarchar](50) NOT NULL,
	Mun10k [nvarchar](50) NOT NULL,
	CityCount [nvarchar](50) NOT NULL,
	UrbanRatio [float] NOT NULL,
	MeanSalary [int] NOT NULL,
	UnEmp95 [nvarchar](50) NULL,
	UnEmp96[float] NOT NULL,
	EntPer1k [int] NOT NULL,
	Crimes95[nvarchar](50) NULL,
	Crimes96 [int] NOT NULL
) ON [PRIMARY]
GO

MERGE Clean.District as t USING dbo.District  as s
ON t.DistrictId = s.A1
WHEN not MATCHED by target
    THEN insert 
	(
		DistrictName,	
		Region,
		Inhabitants,
		Mun499,
		Mun1999,
		Mun9999,
		Mun10k,
		CityCount,
		UrbanRatio,
		MeanSalary,
		UnEmp95,
		UnEmp96,
		EntPer1k,
		Crimes95,
		Crimes96
	)
	values
	(
		A2,
		A3,
		A4,
		A5,
		A6,
		A7,
		A8,
		A9,
		A10,
		A11,
		A12,
		A13,
		A14,
		A15,
		A16
	);