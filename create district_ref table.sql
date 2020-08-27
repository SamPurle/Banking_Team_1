-- BANKING PROJECT TEAM 1
-- ADAM, ANKUSH, BEN, JORDAN, SAM

-- Creating a ref table for ambiguous A1-A16 column headings in disp table
-- JIRA REF: BAN1-8

-- creating the table

USE bankingT1
GO
DROP TABLE IF EXISTS district_ref
CREATE TABLE district_ref
(
item varchar(50) NOT NULL,
meaning varchar(50) NULL
)

-- populating the table
INSERT INTO dbo.district_ref
(item, meaning)
VALUES

('A1', 'district code' ),
('A2', 'district name' ),
('A3', 'region' ),
('A4', 'no. inhabitants'),
('A5', 'no. municipalities with inhabitants <499' ),
('A6', 'no. municipalities with inhabitants 500-1999' ),
('A7', 'no. municipalities with inhabitants 2000-9999' ), -- there was a typo in the demographic table data in the word doc. I think this description is correct.
('A8', 'no. municipalities with inhabitants >10000' ),
('A9', 'no. of cities' ),
('A10', 'ratio of urban inhabitants' ),
('A11', 'average salary' ),
('A12', 'unemployment rate 1995' ),
('A13', 'unemployment rate 1996' ),
('A14', 'no. entrepreneurs per 1000 inhabitants' ),
('A15', 'no. of commited crimes 1995' ),
('A16', 'no. of commited crimes 1996 ' )
