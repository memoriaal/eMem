CREATE OR REPLACE VIEW v_nimekujud AS
SELECT *
FROM EMIR e
WHERE
   (e.perenimi REGEXP ';' AND e.EmiPerenimi IS NULL)
OR (e.eesnimi REGEXP ';' AND e.EmiEesnimi IS NULL)
OR (e.isanimi REGEXP ';' AND e.EmiIsanimi IS NULL)
OR (e.sünd REGEXP ';' AND e.EmiSünd IS NULL)
OR (e.surm REGEXP ';' AND e.EmiSurm IS NULL)
AND id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!');
