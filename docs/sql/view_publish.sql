-- V 1.
CREATE OR REPLACE VIEW v_publish AS
SELECT id AS emi_id
     , UPPER(ifnull(em.EmiPerenimi,  left(em.Perenimi, locate(';', concat(em.Perenimi, ';'))-1))) AS Perenimi
     , UPPER(ifnull(em.EmiEesnimi,   left(em.Eesnimi, locate(';', concat(em.Eesnimi, ';'))-1))) AS Eesnimi
     , UPPER(ifnull(em.EmiIsanimi,   left(em.Isanimi, locate(';', concat(em.Isanimi, ';'))-1))) AS Isanimi
     , left(ifnull(em.EmiSünd, left(em.Sünd, locate(';', concat(em.Sünd, ';'))-1)), 4) AS Sünd
     , left(ifnull(em.EmiSurm, left(em.Surm, locate(';', concat(em.Surm, ';'))-1)), 4) AS Surm
     , replace(em.Kirjed, '"', "'") AS Kirjed
FROM EMIR em
WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!')
HAVING eesnimi > '' 
   AND perenimi > ''
   AND (sünd > '' OR surm > '')
;


-- V 2.
CREATE OR REPLACE VIEW v_publish AS
SELECT emi_id, Perenimi, Eesnimi, Isanimi, Sünd, Surm, Kirjed
FROM
(
    SELECT id AS emi_id
        , UPPER(ifnull(em.EmiPerenimi, SUBSTRING_INDEX(em.Perenimi, ';' , 1))) AS Perenimi
        , UPPER(ifnull(em.EmiEesnimi,  SUBSTRING_INDEX(em.Eesnimi,  ';' , 1))) AS Eesnimi
        , UPPER(ifnull(em.EmiIsanimi,  SUBSTRING_INDEX(em.Isanimi,  ';' , 1))) AS Isanimi
        ,  left(ifnull(em.EmiSünd,     SUBSTRING_INDEX(em.Sünd,     ';' , 1)), 4) AS Sünd
        ,  left(ifnull(em.EmiSurm,     SUBSTRING_INDEX(em.Surm,     ';' , 1)), 4) AS Surm
        , replace(em.Kirjed, '"', "'") AS Kirjed
    FROM EMIR em
    WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!')
    HAVING eesnimi > '' 
    AND perenimi > ''
    AND (sünd > '' OR surm > '')
) vp
GROUP BY Perenimi, Eesnimi, Sünd, Surm
HAVING count(1) > 1

UNION

SELECT emi_id, Perenimi, Eesnimi, Isanimi, Sünd, Surm, Kirjed
FROM
(
    SELECT id AS emi_id
        , UPPER(ifnull(em.EmiPerenimi, SUBSTRING_INDEX(em.Perenimi, ';' , 1))) AS Perenimi
        , UPPER(ifnull(em.EmiEesnimi,  SUBSTRING_INDEX(em.Eesnimi,  ';' , 1))) AS Eesnimi
        , UPPER(ifnull(em.EmiIsanimi,  SUBSTRING_INDEX(em.Isanimi,  ';' , 1))) AS Isanimi
        ,  left(ifnull(em.EmiSünd,     SUBSTRING_INDEX(em.Sünd,     ';' , 1)), 4) AS Sünd
        ,  left(ifnull(em.EmiSurm,     SUBSTRING_INDEX(em.Surm,     ';' , 1)), 4) AS Surm
        , replace(em.Kirjed, '"', "'") AS Kirjed
    FROM EMIR em
    WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!')
    HAVING eesnimi > '' 
    AND perenimi > ''
    AND (sünd > '' OR surm > '')
) vp
GROUP BY Perenimi, Eesnimi, Sünd, Surm
HAVING count(1) = 1
;


CREATE OR REPLACE VIEW v_publish AS
SELECT emi_id, Perenimi, Eesnimi, Isanimi, Sünd, Surm, Kirjed
FROM
(
    SELECT id AS emi_id
        ,         UPPER(ifnull(em.EmiPerenimi, SUBSTRING_INDEX(em.Perenimi, ';' , 1)))            AS Perenimi
        , replace(UPPER(ifnull(em.EmiEesnimi,  SUBSTRING_INDEX(em.Eesnimi,  ';' , 1))), '-', ' ') AS Eesnimi
        ,         UPPER(ifnull(em.EmiIsanimi,  SUBSTRING_INDEX(em.Isanimi,  ';' , 1)))            AS Isanimi
        ,          left(ifnull(em.EmiSünd,     SUBSTRING_INDEX(em.Sünd,     ';' , 1)), 4)         AS Sünd
        ,          left(ifnull(em.EmiSurm,     SUBSTRING_INDEX(em.Surm,     ';' , 1)), 4)         AS Surm
        , replace(em.Kirjed, '"', "'") AS Kirjed
    FROM EMIR em
    WHERE id IN (148934,153612,158558,183791) -- Isanimeta oleks need kirjed identsed
) vp
UNION
SELECT emi_id, Perenimi, Eesnimi, '', Sünd, Surm, Kirjed
FROM
(
    SELECT id AS emi_id
        ,         UPPER(ifnull(em.EmiPerenimi, SUBSTRING_INDEX(em.Perenimi, ';' , 1)))            AS Perenimi
        , replace(UPPER(ifnull(em.EmiEesnimi,  SUBSTRING_INDEX(em.Eesnimi,  ';' , 1))), '-', ' ') AS Eesnimi
        ,         UPPER(ifnull(em.EmiIsanimi,  SUBSTRING_INDEX(em.Isanimi,  ';' , 1)))            AS Isanimi
        ,          left(ifnull(em.EmiSünd,     SUBSTRING_INDEX(em.Sünd,     ';' , 1)), 4)         AS Sünd
        ,          left(ifnull(em.EmiSurm,     SUBSTRING_INDEX(em.Surm,     ';' , 1)), 4)         AS Surm
        , replace(em.Kirjed, '"', "'") AS Kirjed
    FROM EMIR em
    WHERE id IN (SELECT DISTINCT emi_id FROM kirjed WHERE kivi = '!')
    HAVING eesnimi > '' 
    AND perenimi > ''
    AND (sünd > '' OR surm > '')
) vp
GROUP BY Perenimi, Eesnimi, Sünd, Surm
HAVING count(1) = 1
;




-- 
--
CREATE OR REPLACE view `v_publish` AS 
    SELECT `em`.`id` AS `emi_id`,
           ucase(substring_index(`em`.`perenimi`,';'        ,1))          AS `Perenimi`,
           REPLACE(ucase(substring_index(`em`.`eesnimi`,';' ,1)),'-',' ') AS `Eesnimi`,
           ucase(substring_index(`em`.`isanimi`,';'         ,1))          AS `Isanimi`,
           LEFT(substring_index(`em`.`sünd`,';'             ,1),4)        AS `Sünd`,
           LEFT(substring_index(`em`.`surm`,';'             ,1),4)        AS `Surm`,
           REPLACE(`em`.`kirjed`,'"','\'')                                AS `Kirjed` 
    FROM   `kylli`.`EMIR` `em` 
    WHERE  `em`.`id` IN ( SELECT DISTINCT `kylli`.`kirjed`.`emi_id` 
                          FROM   `kylli`.`kirjed` 
                          WHERE  `kylli`.`kirjed`.`kivi` = '!' )
    GROUP BY `em`.`perenimi`,`em`.`eesnimi`,`em`.`isanimi`,`em`.`sünd`,`em`.`surm` 
    HAVING `eesnimi` > '' 
       AND `perenimi` > '' 
       AND (`sünd` > '' OR `surm` > '')
       -- AND count(1) = 1
       AND Kirjed IS NOT NULL
       ;
