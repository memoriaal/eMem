-- CREATE OR REPLACE DEFINER=michelek@localhost SQL SECURITY DEFINER VIEW ainult12SM AS 

SELECT
   k0.persoon AS persoon,
   k0.kirjekood AS kirjekood,
   k0.Kirje AS Kirje,
   kk1.persoon AS kkPersoon,
   k0.Perenimi AS Perenimi,
   k0.Eesnimi AS Eesnimi,
   k0.Isanimi AS Isanimi,
   k0.Emanimi AS Emanimi,
   k0.Sünd AS Sünd,
   k0.Surm AS Surm,
   k0.Lipikud AS Lipikud,
   k0.Sildid AS Sildid,
   k0.RaamatuPere AS RaamatuPere,
   k0.LeidPere AS LeidPere,
   k0.Sugu AS Sugu,
   k0.Rahvus AS Rahvus,
   k0.Välisviide AS Välisviide,
   k0.Kommentaar AS Kommentaar,
   k0.Allikas AS Allikas,
   k0.Nimekiri AS Nimekiri,
   k0.Puudulik AS Puudulik,
   k0.EkslikKanne AS EkslikKanne,
   k0.Peatatud AS Peatatud,
   k0.EiArvesta AS EiArvesta,
   k0.kustuta AS kustuta,
   k0.legend AS legend,
   k0.created_at AS created_at,
   k0.created_by AS created_by,
   k0.updated_at AS updated_at,
   k0.updated_by AS updated_by,
   k0.KirjePersoon AS KirjePersoon,
   k0.KirjeJutt AS KirjeJutt,
   k0.EesnimiC AS EesnimiC,
   k0.PerenimiC AS PerenimiC,
   k0.IsanimiC AS IsanimiC
FROM repis.kirjed k0
LEFT JOIN repis.kirjed k1 ON k1.persoon = k0.persoon
LEFT JOIN repis.kirjed kk0 ON kk0.eesnimi = k1.eesnimi AND kk0.perenimi = k1.perenimi
LEFT JOIN repis.kirjed kk1 ON kk1.persoon = kk0.persoon AND kk1.allikas = 'persoon'
WHERE k0.Allikas IN ('ERAF.12SM','ERAF.12BSM')
GROUP BY k1.persoon
HAVING count(1) = 2;




CREATE OR REPLACE VIEW aruanded.pensionitoimikud AS 
SELECT
   pk.persoon AS persoon,
   r0.Perenimi AS perenimi,
   r0.Eesnimi AS eesnimi,
   r0.Isanimi AS isanimi,
   r0.Emanimi AS emanimi,
   r0.Sünd AS sünd,
   r0.Surm AS surm,group_concat(rk.kirjekood,' ',rk.Kirje separator '\n') AS kirjed
FROM repis.kirjed pk
left join repis.kirjed rk on rk.persoon = pk.persoon and rk.Allikas <> 'persoon'
left join repis.kirjed r0 on r0.kirjekood = pk.persoon
where pk.allikas = 'RPT'
group by pk.persoon;