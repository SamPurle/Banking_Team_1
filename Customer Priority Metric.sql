use bankingT1
select * from clean.trans where TransactionId = '171015'

/* 
This code aims to identify whether a high priority or low priority in order to 
support the bank in distributing resources in the right places.

I envisage a points system whereby a customer has high points for things worthy of business attention
(e.g. not paying loans) and has low points for things that don't require attention. 

Want to be able to create a function whereby you call a parameter, account id (say) and it
tells you their attention score. 

JIRA REF: BAN1-31
*/

-- ########################################################################
-- this section of code joins people who have loans to the transaction table.

SELECT loan.accountid, loanstatus, COUNT(loan.accountid) as num_transactions,
CASE

	WHEN loanstatus = 'contract finished, no problems' 
	THEN 1
	WHEN loanstatus = 'contract finished, loan not payed' 
	THEN 4
	WHEN loanstatus = 'running contract, client in debt' 
	THEN 3
	WHEN loanstatus = 'running contract, OK so far' 
	THEN 2

END AS priority_ranking
FROM clean.loan
	INNER JOIN clean.trans
	ON loan.AccountId = trans.AccountId
GROUP BY loan.accountid, loan.loanstatus
HAVING COUNT(loan.accountid) > 0
AND LoanStatus = 'contract finished, no problems'

-- ##########################################################

--select * from clean.client
--select * from clean.Disposition


SELECT clientid, disposition.accountid, [type], loanstatus, num_transactions
FROM clean.Disposition
LEFT JOIN
(
	SELECT loan.accountid, loanstatus, COUNT(loan.accountid) as num_transactions
	FROM clean.loan
		INNER JOIN clean.trans
		ON loan.AccountId = trans.AccountId
	GROUP BY loan.accountid, loan.loanstatus
	HAVING COUNT(loan.accountid) > 0
	AND LoanStatus = 'contract finished, no problems'
) AS t
ON clean.disposition.AccountId = t.AccountId
WHERE t.accountid is not null
AND disposition.[type] = 'OWNER'

use bankingT1
-- ##########################################################
SELECT *, DATEDIFF(year, BirthDate, CleanDate) as age_on_loan,
case
        when DATEDIFF(year, BirthDate, CleanDate) < 20 then 'Child'
        when 20 <= DATEDIFF(year, BirthDate, CleanDate) and DATEDIFF(year, BirthDate, CleanDate) < 40 then 'Young'
        when 40 <= DATEDIFF(year, BirthDate, CleanDate) and DATEDIFF(year, BirthDate, CleanDate) < 60 then 'Middle Aged'
        else 'Old'
    end as AgeBracket
FROM clean.client
LEFT JOIN
(
	SELECT clientid, CleanDate, disposition.accountid, [type], loanstatus, num_transactions
	FROM clean.Disposition
	LEFT JOIN
	(
		SELECT loan.accountid, loanstatus, loan.CleanDate, COUNT(loan.accountid) as num_transactions
		FROM clean.loan
			INNER JOIN clean.trans
			ON loan.AccountId = trans.AccountId
		GROUP BY loan.accountid, loan.loanstatus, loan.cleandate
	) AS t
	ON clean.disposition.AccountId = t.AccountId
	WHERE t.accountid IS NOT NULL
	AND disposition.[type] = 'OWNER'
) AS p
ON clean.client.ClientId = p.ClientId
WHERE p.ClientId IS NOT NULL
ORDER BY age_on_loan

-- ###############################################################
select * from clean.loan where accountid = '10320'
-- ###############################################################

-- Now I will aim to group by num_transactions, gender, age
-- GROUPING BY GENDER

use bankingT1
go

SELECT distinct
    Gender,
    loanstatus,
    count(*) over (partition by loanstatus) as LoanCount,
    cast(count(*) over (partition by loanstatus) as float) / cast(count(*) over (partition by Gender) as float)*100 as GenderSplit
FROM clean.client
LEFT JOIN
(
    SELECT clientid, CleanDate, disposition.accountid, [type], loanstatus, num_transactions
    FROM clean.Disposition
    LEFT JOIN
    (
        SELECT loan.accountid, loanstatus, loan.CleanDate, COUNT(loan.accountid) as num_transactions
        FROM clean.loan
            INNER JOIN clean.trans
            ON loan.AccountId = trans.AccountId
        GROUP BY loan.accountid, loan.loanstatus, loan.cleandate
    ) AS t
    ON clean.disposition.AccountId = t.AccountId
    WHERE t.accountid IS NOT NULL
    AND disposition.[type] = 'OWNER'
) AS p
ON clean.client.ClientId = p.ClientId
WHERE p.ClientId IS NOT NULL
AND gender = 'Male'
ORDER BY LoanStatus

-- ###############################################################
-- GROUPING BY AGE 

use bankingT1
go

 

;with CTE_AgeBracket
as
(
SELECT distinct
    AccountId,
    loanstatus,
    case
        when DATEDIFF(year, BirthDate, CleanDate) < 20 then 'Child'
        when 20 <= DATEDIFF(year, BirthDate, CleanDate) and DATEDIFF(year, BirthDate, CleanDate) < 40 then 'Young'
        when 40 <= DATEDIFF(year, BirthDate, CleanDate) and DATEDIFF(year, BirthDate, CleanDate) < 60 then 'Middle Aged'
        else 'Old'
    end as AgeBracket


FROM clean.client
LEFT JOIN
(
    SELECT clientid, CleanDate, disposition.accountid, [type], loanstatus, num_transactions
    FROM clean.Disposition
    LEFT JOIN
    (
        SELECT loan.accountid, loanstatus, loan.CleanDate, COUNT(loan.accountid) as num_transactions
        FROM clean.loan
            INNER JOIN clean.trans
            ON loan.AccountId = trans.AccountId
        GROUP BY loan.accountid, loan.loanstatus, loan.cleandate
    ) AS t
    ON clean.disposition.AccountId = t.AccountId
    WHERE t.accountid IS NOT NULL
    AND disposition.[type] = 'OWNER'
) AS p
ON clean.client.ClientId = p.ClientId
WHERE p.ClientId IS NOT NULL
--AND gender = 'Female'
)

select 
    LoanStatus,
    AgeBracket,
    count(*) as LoanCount
from CTE_AgeBracket
group by LoanStatus, AgeBracket
ORDER BY agebracket, LoanStatus

-- ###################################################################################

-- more probing
select * from clean.loan where accountid = '10320'

select * from clean.Client 
	INNER JOIN clean.Disposition
	ON clean.client.ClientId = clean.Disposition.ClientId
	where accountid = '10320'

select * from clean.trans where accountid = '10320'
ORDER BY cleandate

select * from clean.Disposition where AccountId = '10320' -- i.e., not a shared account

-- and according to google you have to be 18 to open a bank account in the czech republic...

-- these queries prove it was the case in the original data too

select * from dbo.Client 
	INNER JOIN dbo.Disp
	ON dbo.client.Client_Id = dbo.Disp.Client_Id
	where account_id = '10320'

select * from dbo.trans where account_id = '10320'
ORDER BY [date]



-- ########################################################################
/*
now need to relate the account ID in the loan table to the account id in the disposition table to
get a corresponding client ID.

maybe interested in those whose loans are a high fraction of their balance? 
- no: Jordan already claimed this.

now going to look at the ratio of amount loaned vs their current balance. 
Going to calculate standard deviation based on this and probably assign a high
points metric to individuals that have a high # of standard deviations away from the mean

maybe give a scoring ranking on how many transactions they carry out per month? more = high attention
*/

-- finding a current balance by account ID

select *
from clean.trans
where accountid = 5011
order by cleandate

-- ######################################################################
-- counts the number of transactions per accountid 

select Distinct 
	accountid, 
	count(accountid) as num_transactions, 
	AVG(amount) as avg_amount,
	STDEV(amount) as stdev_amount
from clean.trans
group by accountid
order by count(accountid) DESC

-- #########################################################

--stdev of account balance rather than amount. is the balance high relative to their average transaction amount/stdev of this
-- i.e. should you offer credit card
-- i.e. does someone have lots of £400 transactions and an avg balance of £500 (bad customer).
-- who is the 'model customer'?? 
-- who is loaning money and who is paying it back. 
-- answer to the questions: who is loaning money and who is paying it back?
-- new customer: should we loan them money and how much. 

/*
Jordan is doing income to debt ratio.


/*

high stdev but low avg is good for the bank as lots of deposits


--*/