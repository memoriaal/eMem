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
   left(nk.Sünd, 4) AS sünd,
   left(nk.Surm, 4) AS surm,
   k.kommentaar AS kommentaar
   , kts.kirjekood AS Tagasiside
FROM repis.v_kirjesildid s
  left join repis.kirjed k on s.kirjekood = k.persoon
  left join repis.kirjed nk on nk.persoon = k.persoon and nk.kirjekood = nk.persoon
  left join repis.kirjed kts on k1.persoon = kts.persoon and kts.Allikas = 'ts'
  where s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00'
    and k.Allikas = 'KIVI'
    and (replace(nk.Perenimi,'-',' ') <> k.Perenimi
      or replace(nk.Eesnimi,'-',' ') <> k.Eesnimi
      or nk.Isanimi <> k.Isanimi and k.Isanimi <> ''
      or left(nk.Sünd,4) <> k.Sünd
      or left(nk.Surm,4) <> k.Surm
    );


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
   , kts.kirjekood AS Tagasiside
FROM repis.v_kirjesildid s
  left join repis.kirjed k on s.kirjekood = k.persoon and s.silt = 'x - kivi' AND s.deleted_at = '0000-00-00 00:00:00' and k.Allikas = 'KIVI'
  left join repis.kirjed k1 on k1.kirjekood = s.kirjekood
  left join repis.kirjed kts on k1.persoon = kts.persoon and kts.Allikas = 'ts'
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
     k2.RaamatuPere AS RaamatuPere,
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
     , kts.kirjekood AS Tagasiside
  FROM repis.kirjed k2
  right join repis.kirjed k1 on k2.persoon = k1.persoon
                            and k2.kirjekood <> k1.kirjekood
  right join repis.kirjed k0 on k1.persoon = k0.persoon
  left join repis.kirjed kts on k2.persoon = kts.persoon and kts.Allikas = 'ts'
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
     k.RaamatuPere AS RaamatuPere,
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
     , kts.kirjekood AS Tagasiside
  FROM repis.kirjed k1
  LEFT JOIN repis.kirjed k2 ON k2.persoon = k1.persoon AND k2.allikas = 'kivi' AND k2.kirjekood != k1.kirjekood
  LEFT JOIN repis.kirjed k ON k.persoon = k2.persoon
  left join repis.kirjed kts on k.persoon = kts.persoon and kts.Allikas = 'ts'
  WHERE k1.allikas = 'kivi'
  AND k2.persoon IS NOT NULL
  ;


--
-- Kiviraamat
--
CREATE OR replace ALGORITHM=UNDEFINED DEFINER=`michelek`@`localhost` SQL SECURITY DEFINER VIEW `kiviraamat`
AS SELECT
   k0.persoon AS persoon,
   repis.func_proper(k0.Eesnimi) AS eesnimi,
   k0.Perenimi AS perenimi,
   repis.func_proper(k0.Isanimi) AS isanimi,
   repis.func_proper(k0.Emanimi) AS emanimi,
   left(k0.Sünd,4) AS sünd,left(k0.Surm,4) AS surm,
   if (kt.persoon IS NULL,
       'lisatahvel',
       concat_ws('-', replace(kt.tahvel,' ','-'), kt.tulp, kt.rida)
      ) AS aadress
      , kts.kirjekood AS Tagasiside
FROM repis.v_kirjesildid ks
LEFT JOIN repis.kirjed k0 ON ks.kirjekood = k0.kirjekood
LEFT JOIN import.memoriaal_kivitahvlid kt ON kt.persoon = k0.persoon
left join repis.kirjed kts on k0.persoon = kts.persoon and kts.Allikas = 'ts'
WHERE ks.silt = 'x - kivi'
  AND ks.deleted_at = '0000-00-00 00:00:00'
  AND k0.Perenimi <> ''
GROUP BY k0.persoon
ORDER BY k0.Perenimi, k0.Eesnimi, k0.Sünd, k0.Surm, k0.Isanimi, k0.Emanimi;


-- 16.augusti päringud

SELECT func_proper(kt.kirje), kt.tiib, kt.tahvlinr, kt.tulp, kt.rida, kt.kirjekood, kt.persoon,
IF(ks.silt IS NULL, 0, 1) AS kivi
FROM import.memoriaal_kivitahvlid kt
LEFT JOIN repis.v_kirjesildid ks ON ks.kirjekood = kt.persoon AND ks.silt = 'x - kivi'
ORDER BY tiib, IF(tiib = 'A', tahvlinr, 500 - tahvlinr), tulp, rida
;

SELECT kk.persoon, concat_ws(' ', repis.func_proper(kk.eesnimi), repis.func_proper(kk.perenimi)) AS nimi,
LEFT(kk.sünd,4) AS sünd, LEFT(kk.surm,4) AS surm
FROM aruanded.uued_kivikirjed kk
ORDER BY kk.perenimi, kk.eesnimi
;



--            __  __                                     _                       _
--      o O O|  \/  |   ___    _ __     ___      _ _    (_)    __ _    __ _     | |
--     o     | |\/| |  / -_)  | '  \   / _ \    | '_|   | |   / _` |  / _` |    | |
--    TS__[O]|_|__|_|  \___|  |_|_|_|  \___/   _|_|_   _|_|_  \__,_|  \__,_|   _|_|_
--   {======|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|_|"""""|
--  ./o--000'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'"`-0-0-'

CREATE OR REPLACE TABLE aruanded.memoriaal_ee (
  id CHAR(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimi VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimed VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimed VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimed VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimed VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm VARCHAR(300) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kivi VARCHAR(1) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',

  tahvlikirje varchar(43) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  tahvel VARCHAR(5) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  tulp VARCHAR(1) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  rida VARCHAR(2) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',

  kirjed LONGTEXT COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  pereseos LONGTEXT COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  pereseosID TEXT COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  relevantne tinyint(1) unsigned NOT NULL DEFAULT 0,
  PRIMARY KEY (id)
) ENGINE=INNODB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci AS
-- ;
SELECT   nk.kirjekood AS id,
         nk.perenimi,
         nk.eesnimi,
         nk.isanimi,
         nk.emanimi,
         replace(replace(group_concat(DISTINCT k.perenimi SEPARATOR ' '), ';', ' '), '-', ' ') AS perenimed,
         replace(replace(group_concat(DISTINCT k.eesnimi SEPARATOR ' '), ';', ' '), '-', ' ') AS eesnimed,
         replace(replace(group_concat(DISTINCT k.emanimi SEPARATOR ' '), ';', ' '), '-', ' ') AS emanimed,
         replace(replace(group_concat(DISTINCT k.isanimi SEPARATOR ' '), ';', ' '), '-', ' ') AS isanimed,
         LEFT(nk.sünd,4) AS sünd,
         LEFT(nk.surm,4) AS surm,
         IF(ks_k.silt IS NULL, '0', '1') AS kivi,
         IF(ks_k.silt = 'x - kivi', IFNULL(kt.kirje, 'N/A'), '') AS tahvlikirje,
         IF(ks_k.silt = 'x - kivi', IFNULL(kt.tahvel, 'X'), '') AS tahvel,
         IF(ks_k.silt = 'x - kivi', IFNULL(kt.tulp, '-'), '') AS tulp,
         IF(ks_k.silt = 'x - kivi', IFNULL(kt.rida, '-'), '') AS rida,
         IF(evo.persoon IS NULL, '0', '1') AS ohvitser,
         IFNULL(evo.Auaste, '') AS auaste,
         IFNULL(evo.VR, '') AS VR,
         IFNULL(evo.Nimi, '') AS evonimi,
         IFNULL(evo.Kirje, '') AS evokirje,
         concat(evo.sünd, '-', evo.surm) AS evoaastad,
         IFNULL(REPLACE (
           group_concat(DISTINCT
             IF(
               a.prioriteetkirje = 0, NULL, concat_ws('#|',
                 k.persoon,
                 k.kirjekood,
                 IF (k.allikas = 'RR', REGEXP_REPLACE(k.kirje, '\\|+', '|'), k.kirje),
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
                 -- kp.raamatupere,
                 kp.persoon,
                 kp.kirjekood,
                 kp.kirje,
                 kpa.allikas,
                 kpa.nimetus,
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
        ), '')           AS pereseos,
        IFNULL(
          group_concat( DISTINCT
             IF( kp.kirjekood IS NULL, NULL, kp.persoon )
             SEPARATOR ' '
        ), '')           AS pereseosID,
        IF( ks_mr.kirjekood IS NULL, 1, 0) as relevantne
FROM repis.kirjed AS k
LEFT JOIN repis.allikad AS a ON a.kood = k.allikas
LEFT JOIN repis.kirjed AS kp ON kp.RaamatuPere <> '' AND kp.RaamatuPere = k.RaamatuPere AND kp.allikas != 'Persoon'
LEFT JOIN repis.allikad AS kpa ON kpa.kood = kp.allikas
LEFT JOIN repis.kirjed AS nk ON nk.persoon = k.persoon AND nk.allikas = 'Persoon' AND nk.persoon = nk.kirjekood
LEFT JOIN repis.v_kirjesildid AS ks_k ON ks_k.kirjekood = nk.persoon AND ks_k.silt = 'x - kivi' AND ks_k.deleted_at = '0000-00-00 00:00:00'
LEFT JOIN repis.v_kirjesildid AS ks_mr ON ks_mr.kirjekood = nk.persoon AND ks_mr.silt = 'x - mitterelevantne' AND ks_mr.deleted_at = '0000-00-00 00:00:00'
LEFT JOIN import.memoriaal_kivitahvlid kt ON kt.persoon = k.persoon
LEFT JOIN import.memoriaal_evo evo ON evo.persoon = k.persoon
WHERE k.ekslikkanne = ''
AND k.puudulik = ''
AND k.allikas NOT IN ('KIVI')
-- AND k.persoon = '0000083261'
AND k.peatatud = ''
-- AND kp.allikas != 'Persoon'
AND nk.persoon IS NOT NULL
-- AND ks_mr.kirjekood IS NULL
AND IFNULL(a.nonPerson, '') != '!'
GROUP BY k.persoon
HAVING perenimi != ''
   AND kirjed != ''
-- ;
INTO OUTFILE '/home/michelek/scripts/memoriaal_ee.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';
