CREATE OR REPLACE VIEW endised_kivikirjed
AS SELECT
   k.kirjekood AS K_kirjekood,
   k.Perenimi AS K_perenimi,
   k.Eesnimi AS K_eesnimi,
   k.Sünd AS K_sünd,
   k.Surm AS K_surm,
   k.persoon AS persoon,
   k.kommentaar AS kommentaar
FROM (repis.kirjed k
  left join repis.v_kirjesildid s on(s.kirjekood = k.persoon and s.silt = 'x - kivi'))
  where k.Allikas = 'KIVI' and s.silt is null;

CREATE OR REPLACE VIEW muutunud_kivikirjed
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
  where s.silt = 'x - kivi' and k.Allikas = 'KIVI' and (replace(nk.Perenimi,'-',' ') <> k.Perenimi or replace(nk.Eesnimi,'-',' ') <> k.Eesnimi or nk.Isanimi <> k.Isanimi and k.Isanimi <> '' or left(nk.Sünd,4) <> k.Sünd or left(nk.Surm,4) <> k.Surm);

CREATE OR REPLACE VIEW uued_kivikirjed
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
  left join repis.kirjed k on(s.kirjekood = k.persoon and s.silt = 'x - kivi' and k.Allikas = 'KIVI'))
  left join repis.kirjed k1 on(k1.kirjekood = s.kirjekood))
  where s.silt = 'x - kivi' and k.kirjekood is null and k1.Perenimi <> '' and k1.Eesnimi <> '';


CREATE OR REPLACE VIEW topelt_kivikirjed
AS SELECT DISTINCT
   k2.persoon AS persoon,
   k2.kirjekood AS kirjekood,
   k2.Perenimi AS perenimi,
   k2.Eesnimi AS eesnimi,
   k2.Isanimi AS isanimi,
   k2.Emanimi AS emanimi,
   k2.Sünd AS sünd,
   k2.Surm AS surm,
   k2.kommentaar AS kommentaar
FROM repis.kirjed k0
LEFT JOIN repis.kirjed k1 ON k0.persoon = k1.persoon AND k0.kirjekood != k1.kirjekood AND k1.allikas = 'KIVI'
LEFT JOIN repis.kirjed k2 ON k2.persoon = k1.persoon AND k2.allikas = 'KIVI'
WHERE k0.allikas = 'KIVI'
AND k1.persoon IS NOT NULL
;

CREATE OR REPLACE VIEW topelt_kivikirjed
AS SELECT
   distinct `k2`.`persoon` AS `persoon`,
   `k2`.`kirjekood` AS `kirjekood`,
   `k2`.`Kirje` AS `Kirje`,
   `k2`.`Perenimi` AS `Perenimi`,
   `k2`.`Eesnimi` AS `Eesnimi`,
   `k2`.`Isanimi` AS `Isanimi`,
   `k2`.`Emanimi` AS `Emanimi`,
   `k2`.`Sünd` AS `Sünd`,
   `k2`.`Surm` AS `Surm`,
   `k2`.`Perekood` AS `Perekood`,
   `k2`.`Sugu` AS `Sugu`,
   `k2`.`Rahvus` AS `Rahvus`,
   `k2`.`Välisviide` AS `Välisviide`,
   `k2`.`Kommentaar` AS `Kommentaar`,
   `k2`.`Allikas` AS `Allikas`,
   `k2`.`Nimekiri` AS `Nimekiri`,
   `k2`.`Puudulik` AS `Puudulik`,
   `k2`.`EkslikKanne` AS `EkslikKanne`,
   `k2`.`Peatatud` AS `Peatatud`,
   `k2`.`kustuta` AS `kustuta`,
   `k2`.`created_at` AS `created_at`,
   `k2`.`created_by` AS `created_by`,
   `k2`.`updated_at` AS `updated_at`,
   `k2`.`updated_by` AS `updated_by`
FROM ((`repis`.`kirjed` `k2` join `repis`.`kirjed` `k1`) join `repis`.`kirjed` `k0`) where `k0`.`persoon` = `k1`.`persoon` and `k0`.`kirjekood` <> `k1`.`kirjekood` and `k1`.`Allikas` = 'KIVI' and `k2`.`persoon` = `k1`.`persoon` and `k2`.`Allikas` = 'KIVI' and `k0`.`Allikas` = 'KIVI' and `k1`.`persoon` is not null;


CREATE OR REPLACE VIEW topelt_kivikirjed AS
SELECT DISTINCT
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
FROM ((`repis`.`kirjed` `k2` join `repis`.`kirjed` `k1`) join `repis`.`kirjed` `k0`) where `k0`.`persoon` = `k1`.`persoon` and `k0`.`kirjekood` <> `k1`.`kirjekood` and `k1`.`Allikas` = 'KIVI' and `k2`.`persoon` = `k1`.`persoon` and `k2`.`Allikas` = 'KIVI' and `k0`.`Allikas` = 'KIVI' and `k1`.`persoon` is not null;
