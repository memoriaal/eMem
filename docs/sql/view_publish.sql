CREATE OR REPLACE VIEW v_publish AS
SELECT id AS emi_id
     , ifnull(em.EmiPerenimi, left(em.Perenimi, locate(';', concat(em.Perenimi, ';'))-1)) AS Perenimi
     , ifnull(em.EmiEesnimi, left(em.Eesnimi, locate(';', concat(em.Eesnimi, ';'))-1)) AS Eesnimi
     , ifnull(em.EmiIsanimi, left(em.Isanimi, locate(';', concat(em.Isanimi, ';'))-1)) AS Isanimi
     , left(ifnull(em.EmiSünd, left(em.Sünd, locate(';', concat(em.Sünd, ';'))-1)), 4) AS Sünd
     , left(ifnull(em.EmiSurm, left(em.Surm, locate(';', concat(em.Surm, ';'))-1)), 4) AS Surm
     , replace(em.Kirjed, '"', "'") AS Kirjed
FROM EMIR em
WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!');
