UPDATE ohvrite_nimekiri_2018_02_21 o
left join kirjed k on k.emi_id = o.emi_id and k.allikas = 'Nimekujud'
set o.persoon = k.isikukood
WHERE o.persoon IS NULL;



CREATE OR REPLACE VIEW aruanne_muutused_peale_publitseerimist_02_21 AS
SELECT
   o.emi_id AS emi_id,
   o.Perenimi AS perenimi,
   o.Eesnimi AS eesnimi,
   o.Sünd AS sünd,
   o.Surm AS surm,
   p.emi_id AS Pemi_id,
   p.Perenimi AS Pperenimi,
   p.Eesnimi AS Peesnimi,
   p.Sünd AS Psünd,
   p.Surm AS Psurm
FROM ohvrite_nimekiri_2018_02_21 o
left join v_publish p on o.emi_id = p.emi_id
where o.Perenimi <> p.Perenimi
    or o.Eesnimi <> p.Eesnimi
    or o.Sünd <> p.Sünd
    or o.Surm <> p.Surm

union
select
  o2.emi_id AS emi_id,
  o2.Perenimi AS perenimi,
  o2.Eesnimi AS eesnimi,
  o2.Sünd AS sünd,
  o2.Surm AS surm,
NULL,
NULL,
NULL,
NULL,
NULL
from ohvrite_nimekiri_2018_02_21 o2
where o2.emi_id not in (select p2.emi_id from v_publish as p2)

union
select
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  p3.emi_id AS emi_id,
  p3.Perenimi AS perenimi,
  p3.Eesnimi AS eesnimi,
  p3.Sünd AS sünd,
  p3.Surm AS surm
from v_publish as p3
where p3.emi_id not in (select o3.emi_id from ohvrite_nimekiri_2018_02_21 AS o3);


DELIMITER ;;
CREATE OR REPLACE PROCEDURE tmp()
BEGIN
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE _emi_id INTEGER(11) UNSIGNED DEFAULT NULL;

    DECLARE cur1 CURSOR FOR
        SELECT emi_id FROM ohvrite_nimekiri_2018_02_21 WHERE persoon IS NULL;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    DROP TABLE IF EXISTS otmp;
    CREATE TABLE otmp(
      `emi_id` int(11) unsigned DEFAULT NULL,
      `isikukood` char(10) DEFAULT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    OPEN cur1;
    read_loop: LOOP
    	SET _emi_id = NULL;
    	SET @ik = NULL;

        FETCH cur1 INTO _emi_id;

        INSERT INTO otmp (emi_id, isikukood)
        VALUES (_emi_id, NULL);

        SET @ik = find_by_eid(_emi_id);

        IF @ik IS NOT NULL THEN
            UPDATE otmp SET isikukood = @ik;
            WHERE emi_id = _emi_id;
        END IF;

        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;
DELIMITER ;


CALL tmp();

UPDATE ohvrite_nimekiri_2018_02_21 o
RIGHT JOIN otmp t on o.emi_id = t.emi_id
set o.persoon = t.isikukood
WHERE o.persoon IS NULL;



CREATE OR REPLACE VIEW aruanne_muutused_peale_publitseerimist_02_13 AS
SELECT o.emi_id, o.perenimi, o.eesnimi, o.isanimi, o.sünd, o.surm, o.kirjed, p.emi_id AS Pemi_id, p.perenimi AS Pperenimi, p.eesnimi AS Peesnimi, p.isanimi AS Pisanimi, p.sünd AS Psünd, p.surm AS Psurm, p.kirjed AS Pkirjed
FROM ohvrite_nimekiri_2018_02_13 o
JOIN v_publish p
ON o.emi_id = p.emi_id
WHERE o.perenimi != p.perenimi
   or o.eesnimi != p.eesnimi
   or o.isanimi != p.isanimi
   or o.sünd != p.sünd
   or o.surm != p.surm

UNION

SELECT emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed, NULL, NULL, NULL, NULL, NULL, NULL, NULL
FROM ohvrite_nimekiri_2018_02_13
WHERE emi_id NOT IN
(
SELECT emi_id FROM v_publish
)

UNION

SELECT NULL, NULL, NULL, NULL, NULL, NULL, NULL, emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed
FROM v_publish
WHERE emi_id NOT IN
(
SELECT emi_id FROM ohvrite_nimekiri_2018_02_13
)
;


CREATE OR REPLACE VIEW aruanne_põhjendamata_nimekujud AS
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'perenimi' AND x1.v = e.EmiPerenimi
WHERE e.EmiPerenimi IS NOT NULL
  AND e.perenimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'eesnimi' AND x1.v = e.EmiEesnimi
WHERE e.EmiEesnimi IS NOT NULL
  AND e.eesnimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'isanimi' AND x1.v = e.EmiIsanimi
WHERE e.EmiIsanimi IS NOT NULL
  AND e.isanimi != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'sünd' AND x1.v = e.EmiSünd
WHERE e.EmiSünd IS NOT NULL
  AND e.sünd != ''
  AND e.ref IS NULL
  AND x1.id IS NULL

UNION ALL
SELECT e.*
FROM EMIR e
LEFT JOIN x_nimekujud4 x1 ON x1.id = e.id AND x1.tunnus = 'surm' AND x1.v = e.EmiSurm
WHERE e.EmiSurm IS NOT NULL
  AND e.surm != ''
  AND e.ref IS NULL
  AND x1.id IS NULL
;



CREATE OR REPLACE VIEW aruanne_allikata_nimekujud AS
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiPerenimi IS NOT NULL AND e.perenimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiEesnimi IS NOT NULL AND e.eesnimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiIsanimi IS NOT NULL AND e.isanimi = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiSünd IS NOT NULL AND e.sünd = ''
UNION ALL
SELECT e.*
FROM EMIR e
WHERE e.ref IS NULL AND kirjed IS NOT NULL
  AND e.EmiSurm IS NOT NULL AND e.surm = ''
;



CREATE DEFINER VIEW aruanne_R86_viited AS
SELECT
    ff.isikukood     AS isikukood
  , ff.kivi          AS kivi
  , ff.mittekivi     AS mittekivi
  , ff.rel           AS rel
  , ff.mr            AS mr
  , ff.nimekiri      AS nimekiri
  , ff.kirje         AS kirje
  , ff.emi_id        AS emi_id
  , ff.kirje_allikad AS kirje_allikad
FROM (
        select
            kr.Isikukood AS isikukood
          , kr.Kivi      AS kivi
          , kr.Mittekivi AS mittekivi
          , kr.REL       AS rel
          , kr.MR        AS mr
          , kr.Nimekiri  AS nimekiri
          , kr.Kirje     AS kirje
          , k.emi_id     AS emi_id
          , group_concat(distinct k.Allikas separator ';')
                             AS kirje_allikad
        from (
                kylli.kirjed kr
                left join kylli.kirjed k
                       on kr.emi_id = k.emi_id
                      and kr.Nimekiri regexp substring_index(k.Allikas,'-',1)
        )
        where kr.Allikas = 'R86'
        group by k.emi_id
) ff
WHERE ff.kirje_allikad not regexp ff.nimekiri;


CREATE or replace TABLE aruanne_määra_r7_seoseid (
  koodid varchar(23) DEFAULT NULL,
  kirjed1 text DEFAULT NULL,
  kasSama enum('Jah','Ei','Uurida','Arhiiv','Imporditud') DEFAULT NULL,
  kirjed2 text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8
AS
SELECT koodid.koodid,
       e1.kirjed kirjed1, NULL as kasSama, e2.kirjed kirjed2
FROM (
  select group_concat(distinct eid separator ',') koodid
  from
  (
    select _r7.memento, _r7.eR1 AS eid from _r7 where _r7.eR1 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR2 AS eid from _r7 where _r7.eR2 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR3 AS eid from _r7 where _r7.eR3 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR41 AS eid from _r7 where _r7.eR41 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR42 AS eid from _r7 where _r7.eR42 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR5 AS eid from _r7 where _r7.eR5 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR61 AS eid from _r7 where _r7.eR61 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR62 AS eid from _r7 where _r7.eR62 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR63 AS eid from _r7 where _r7.eR63 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR64 AS eid from _r7 where _r7.eR64 is not NULL
    UNION ALL
    select _r7.memento, _r7.eR65 AS eid from _r7 where _r7.eR65 is not NULL
  ) as r
  left join _r7 as r7 on r7.memento = r.memento
  group by r.memento
  having koodid like '%,%'
) koodid
left join EMIR e1 on e1.id = SUBSTRING_INDEX(koodid.koodid, ',', 1)
left join EMIR e2 on e2.id = SUBSTRING_INDEX(koodid.koodid, ',', -1)
;



CREATE OR REPLACE algorithm=undefined definer=michelek@localhost SQL security definer view aruanne_nimekujud_topelt
AS
  SELECT concat('WHERE emi_id IN (SELECT emi_id FROM kirjed WHERE isikukood IN (', k1.isikukood, ',', k2.isikukood, '))')
            k1.kirje AS kirje1,
            k2.kirje AS kirje2,
            e.kirjed
  FROM kirjed k1
  LEFT JOIN kirjed k2 ON k1.emi_id = k2.emi_id
                     AND k1.isikukood < k2.isikukood
  LEFT JOIN EMIR e on e.id = k1.emi_id
  WHERE     k1.allikas = 'Nimekujud'
  AND       k2.allikas = 'Nimekujud'
  AND       k1.ekslikkanne = ''
  AND       k2.ekslikkanne = '';
