use bankingT1
go

/*
Target competitor banks
*/

;with CTE_STEAL_UR_CUSTOMERS
as
(
select top 500
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
pivot(sum(amount) for TransType in (TransIn, TransOut)) as PIVET;