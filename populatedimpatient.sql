

CREATE OR ALTER PROC populatedimpatient
AS
BEGIN;

WITH ins AS (
SELECT DISTINCT o.newnhsno, n.newnhsno_check, n.sex, n.lopatid, n.leglcat, n.homeadd, n.hesid, n.ethnos, n.dob, n.category, n.admincat
FROM nhs.HES_APC as o LEFT JOIN nhs.HES_APC as n ON o.newnhsno = n.newnhsno
EXCEPT
SELECT NewNHSno, NewNHSno_check, sex, lopatid, leglcat, homeadd, hesid, ethnos, dob, category, admincat
FROM nhs.dimpatient
)
INSERT INTO nhs.dimpatient (NewNHSno, NewNHSno_check, sex, lopatid, leglcat, homeadd, hesid, ethnos, dob, category, admincat)
SELECT * FROM ins;

END;