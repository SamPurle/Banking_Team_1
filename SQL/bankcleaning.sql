WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by accountid ORDER BY districtid) AS row_num FROM clean.account)
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by clientid ORDER BY birthdate) AS row_num FROM clean.client)
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by dispid ORDER BY clientid) AS row_num FROM clean.disposition)
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by loanid ORDER BY accountid) AS row_num FROM clean.loan)
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by orderid ORDER BY accountid) AS row_num FROM clean.[order])
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by cardid ORDER BY dispid) AS row_num FROM clean.card)
DELETE FROM cte 
WHERE row_num = 2;

WITH cte AS
(SELECT ROW_NUMBER() OVER (partition by transactionid ORDER BY accountid) AS row_num FROM clean.trans)
DELETE FROM cte 
WHERE row_num = 2;


ALTER TABLE clean.Account ADD PRIMARY KEY (accountid);
ALTER TABLE clean.card ADD PRIMARY KEY (cardid);
ALTER TABLE clean.client ADD PRIMARY KEY (clientid);
ALTER TABLE clean.disposition ADD PRIMARY KEY (dispid);
ALTER TABLE clean.district ADD PRIMARY KEY (districtid);
ALTER TABLE clean.loan ADD PRIMARY KEY (loanid);
ALTER TABLE clean.[order] ADD PRIMARY KEY (orderid);
ALTER TABLE clean.trans ADD PRIMARY KEY (transactionid);

ALTER TABLE clean.account ALTER COLUMN districtid INT NOT NULL;
ALTER TABLE clean.account ADD FOREIGN KEY (districtid) REFERENCES clean.district (districtid);

ALTER TABLE clean.card ALTER COLUMN dispid SMALLINT NOT NULL;
ALTER TABLE clean.card ADD FOREIGN KEY (dispid) REFERENCES clean.disposition (dispid);

ALTER TABLE clean.client ALTER COLUMN districtid INT NOT NULL;
ALTER TABLE clean.client ADD FOREIGN KEY (districtid) REFERENCES clean.district (districtid);

ALTER TABLE clean.disposition ALTER COLUMN clientid INT NOT NULL;
ALTER TABLE clean.disposition ALTER COLUMN accountid INT NOT NULL;
ALTER TABLE clean.disposition ADD FOREIGN KEY (clientid) REFERENCES clean.client (clientid);
ALTER TABLE clean.disposition ADD FOREIGN KEY (accountid) REFERENCES clean.account (accountid);

ALTER TABLE clean.loan ALTER COLUMN accountid INT NOT NULL;
ALTER TABLE clean.loan ADD FOREIGN KEY (accountid) REFERENCES clean.account (accountid);

ALTER TABLE clean.[order] ALTER COLUMN accountid INT NOT NULL;
ALTER TABLE clean.[order] ADD FOREIGN KEY (accountid) REFERENCES clean.account (accountid);

ALTER TABLE clean.trans ALTER COLUMN accountid INT NOT NULL;
ALTER TABLE clean.trans ADD FOREIGN KEY (accountid) REFERENCES clean.account (accountid); 