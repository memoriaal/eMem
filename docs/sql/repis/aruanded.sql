CREATE OR REPLACE VIEW aruanded.endised_kivikirjed
AS SELECT
   k.kirjekood AS K_kirjekood,
   k.Perenimi AS K_perenimi,
   k.Eesnimi AS K_eesnimi,
   k.Sünd AS K_sünd,
   k.Surm AS K_surm,
   k.persoon AS persoon,
   k.kommentaar AS kommentaar
FROM (repis.kirjed k
  left join repis.v_kirjesildid s on(s.kirjekood = k.persoon and s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00'))
  where k.Allikas = 'KIVI' and s.silt is null;

CREATE OR REPLACE VIEW aruanded.muutunud_kivikirjed
AS SELECT
   k.kirjekood AS K_kirjekood,
   k.Perenimi AS K_perenimi,
   k.Eesnimi AS K_eesnimi,
   k.Sünd AS K_sünd,
   k.Surm AS K_surm,
   k.persoon AS persoon,
   nk.Perenimi AS perenimi,
   nk.Eesnimi AS eesnimi,
   nk.Sünd AS sünd,
   nk.Surm AS surm,
   k.kommentaar AS kommentaar
FROM ((repis.v_kirjesildid s
  left join repis.kirjed k on(s.kirjekood = k.persoon))
  left join repis.kirjed nk on(nk.persoon = k.persoon and nk.kirjekood = nk.persoon))
  where s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00' and k.Allikas = 'KIVI' and (replace(nk.Perenimi,'-',' ') <> k.Perenimi or replace(nk.Eesnimi,'-',' ') <> k.Eesnimi or nk.Isanimi <> k.Isanimi and k.Isanimi <> '' or left(nk.Sünd,4) <> k.Sünd or left(nk.Surm,4) <> k.Surm);

CREATE OR REPLACE VIEW aruanded.uued_kivikirjed
AS SELECT
   k1.persoon AS persoon,
   k1.Perenimi AS perenimi,
   k1.Eesnimi AS eesnimi,
   k1.Isanimi AS isanimi,
   k1.Emanimi AS emanimi,
   k1.Sünd AS sünd,
   k1.Surm AS surm,
   k1.kommentaar AS kommentaar
FROM ((repis.v_kirjesildid s
  left join repis.kirjed k on(s.kirjekood = k.persoon and s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00' and k.Allikas = 'KIVI'))
  left join repis.kirjed k1 on(k1.kirjekood = s.kirjekood))
  where s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00' and k.kirjekood is null and k1.Perenimi <> '' and k1.Eesnimi <> '';


  CREATE OR REPLACE VIEW aruanded.topelt_kivikirjed
  AS SELECT
     k2.persoon AS persoon,
     k2.kirjekood AS kirjekood,
     k2.Kirje AS Kirje,
     k2.Kommentaar AS Kommentaar,
     k2.Perenimi AS Perenimi,
     k2.Eesnimi AS Eesnimi,
     k2.Isanimi AS Isanimi,
     k2.Emanimi AS Emanimi,
     k2.Sünd AS Sünd,
     k2.Surm AS Surm,
     k2.Perekood AS Perekood,
     k2.Sugu AS Sugu,
     k2.Rahvus AS Rahvus,
     k2.Välisviide AS Välisviide,
     k2.Allikas AS Allikas,
     k2.Nimekiri AS Nimekiri,
     k2.Puudulik AS Puudulik,
     k2.EkslikKanne AS EkslikKanne,
     k2.Peatatud AS Peatatud,
     k2.kustuta AS kustuta,
     k2.created_at AS created_at,
     k2.created_by AS created_by,
     k2.updated_at AS updated_at,
     k2.updated_by AS updated_by
  FROM repis.kirjed k2
  right join repis.kirjed k1 on k2.persoon = k1.persoon
                            and k2.kirjekood <> k1.kirjekood
  right join repis.kirjed k0 on k1.persoon = k0.persoon
  where k0.Allikas = 'KIVI'
    and k1.Allikas = 'KIVI'
    and k2.Allikas = 'KIVI'
    and k1.persoon is not NULL
  -- GROUP BY k1.kirjekood;
  ;

  CREATE OR REPLACE VIEW aruanded.topelt_kivikirjed_b
  AS SELECT
     k.persoon AS persoon,
     k.kirjekood AS kirjekood,
     k.Kirje AS Kirje,
     k.Kommentaar AS Kommentaar,
     k.Perenimi AS Perenimi,
     k.Eesnimi AS Eesnimi,
     k.Isanimi AS Isanimi,
     k.Emanimi AS Emanimi,
     k.Sünd AS Sünd,
     k.Surm AS Surm,
     k.Perekood AS Perekood,
     k.Sugu AS Sugu,
     k.Rahvus AS Rahvus,
     k.Välisviide AS Välisviide,
     k.Allikas AS Allikas,
     k.Nimekiri AS Nimekiri,
     k.Puudulik AS Puudulik,
     k.EkslikKanne AS EkslikKanne,
     k.Peatatud AS Peatatud,
     k.kustuta AS kustuta,
     k.created_at AS created_at,
     k.created_by AS created_by,
     k.updated_at AS updated_at,
     k.updated_by AS updated_by
  FROM repis.kirjed k1
  LEFT JOIN repis.kirjed k2 ON k2.persoon = k1.persoon AND k2.allikas = 'kivi' AND k2.kirjekood != k1.kirjekood
  LEFT JOIN repis.kirjed k ON k.persoon = k2.persoon
  WHERE k1.allikas = 'kivi'
  AND k2.persoon IS NOT NULL
  ;




--            __  __                                     _                       _
--      o O O|  \/  |   ___    _ __     ___      _ _    (_)    __ _    __ _     | |
--     o     | |\/| |  / -_)  | '  \   / _ \    | '_|   | |   / _` |  / _` |    | |
--    TS__[O]|_|__|_|  \___|  |_|_|_|  \___/   _|_|_   _|_|_  \__,_|  \__,_|   _|_|_
--   {======|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
--  ./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

CREATE OR REPLACE TABLE aruanded.memoriaal_ee (
  id CHAR(10) COLLATE utf8_estonian_ci DEFAULT '',
  perenimi LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  eesnimi LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  isanimi LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  emanimi LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  sünd LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  surm LONGTEXT COLLATE utf8_estonian_ci DEFAULT NULL,
  kivi VARCHAR(1) COLLATE utf8_estonian_ci NOT NULL,
  kirjed LONGTEXT COLLATE utf8_estonian_ci NOT NULL,
  pereseos VARCHAR(8000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  PRIMARY KEY (id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci AS

SELECT   nk.kirjekood AS id,
         nk.perenimi,
         nk.eesnimi,
         nk.isanimi,
         nk.emanimi,
         LEFT(nk.sünd,4) AS sünd,
         LEFT(nk.surm,4) AS surm,
         IF(ks.silt IS NULL, '', '!') AS kivi,
         IFNULL(REPLACE (
           group_concat(DISTINCT
             IF(
               a.prioriteetkirje = 0, NULL, concat_ws('#|',
                 k.persoon,
                 k.kirjekood,
                 k.kirje,
                 a.allikas,
                 a.nimetus,
                 concat('{ "labels": ["',concat_ws('", "',
                   IF(k.EiArvesta = '!', 'skip', NULL),
                   IF(k.EkslikKanne = '!', 'wrong', NULL)
                 ) , '"] }')
               )
             )
             ORDER BY a.prioriteetkirje DESC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS kirjed,
         IFNULL(REPLACE(
           group_concat( DISTINCT
             IF(
               kp.kirjekood IS NULL, NULL, concat_ws('#|',
                 kp.persoon,
                 kp.kirjekood,
                 kp.kirje,
                 a.allikas,
                 a.nimetus,
                 concat('{ "labels": ["',concat_ws('", "',
                   IF(kp.EiArvesta = '!', 'skip', NULL),
                   IF(kp.EkslikKanne = '!', 'wrong', NULL)
                 ) , '"] }')
               )
             )
             ORDER BY kp.kirjekood ASC SEPARATOR ';_\n'
           ),
           '"',
           '\''
         ), '')           AS pereseos
FROM repis.kirjed AS k
LEFT JOIN repis.allikad AS a ON a.kood = k.allikas
LEFT JOIN repis.kirjed AS kp ON kp.perekood <> '' AND kp.perekood = k.perekood
LEFT JOIN repis.kirjed AS nk ON nk.persoon = k.persoon AND nk.allikas = 'Persoon'
LEFT JOIN repis.v_kirjesildid AS ks ON ks.kirjekood = nk.persoon AND ks.silt = 'x - kivi' AND ks.deleted_at = '0000-00-00 00:00:00'
WHERE k.ekslikkanne = ''
AND k.puudulik = ''
AND k.peatatud = ''
AND nk.persoon IS NOT NULL
GROUP BY k.persoon
HAVING perenimi != ''
-- ;
INTO OUTFILE '/home/michelek/scripts/memoriaal_ee.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
