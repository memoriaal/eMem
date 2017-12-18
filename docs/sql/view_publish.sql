CREATE OR REPLACE VIEW v_publish AS
SELECT id AS emi_id
     , ifnull(em.EmiPerenimi, em.Perenimi) AS Perenimi
     , ifnull(em.EmiEesnimi, em.Eesnimi) AS Eesnimi
     , ifnull(em.EmiIsanimi, em.Isanimi) AS Isanimi
     , ifnull(em.EmiSünd, em.Sünd) AS Sünd
     , ifnull(em.EmiSurm, em.Surm) AS Surm
     , replace(em.Kirjed, '"', "'") AS Kirjed
FROM EMIR em
WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!');
