update _hävituspataljonlased hp
   left join kirjed k
      on    left(k.sünd, 4) = hp.sünniaasta
--        on k.sünd = hp.sünd
     and k.perenimi != ''
     and k.eesnimi != '' 
     and k.isanimi != ''
     and (
              k.perenimi regexp concat('(^|;)', hp.perenimi, '(;|$)')
           or k.perenimi regexp concat('(^|;)', hp.pnvariandid, '(;|$)')
         )
     and (
              k.eesnimi regexp concat('(^|;)', hp.eesnimi, '(;|$)')
           or k.eesnimi regexp concat('(^|;)', hp.envariandid, '(;|$)')
         )
     and (
              k.isanimi regexp concat('(^|;)', hp.isanimi, '(;|$)')
         )
     and hp.perenimi != ''
     and hp.eesnimi != ''
     and hp.isanimi != ''
SET hp.kahtlusseos = k.isikukood
where hp.sünd <> ''
  and hp.seos is null
  and k.emi_id is not null
;

update _hävituspataljonlased
set seos = kahtlusseos, kahtlusseos = null
where seos is null and kahtlusseos is not null;

update _hävituspataljonlased set kirje = 
concat_ws('. ',
  concat_ws(', ',
    if(ifnull(perenimi, pnvariandid) IS NULL, NULL, concat_ws(';', perenimi, pnvariandid)),
    if(ifnull(eesnimi, envariandid) IS NULL, NULL, concat_ws(';', eesnimi, envariandid)),
    if(ifnull(isanimi, invariandid) IS NULL, NULL, concat_ws(';', isanimi, invariandid))
  ),
  if(sünd is null, null,
    concat_ws(', ',
      concat('Sünd ', sünd),
      `S-maa`,
      `S-maakond`,
      `S-koht`
    )
  ),
  if(ifnull(`S-maa`,ifnull(`S-maakond`,`S-koht`)) IS NULL, NULL,
    concat('Elukoht ',
      concat_ws(', ',
        `S-maa`,
        `S-maakond`,
        `S-koht`
      )
    )
  ),
  if(Üksus IS NULL, 'Hävituspataljon', concat('Hävituspataljoni üksus ', Üksus)),
  Viide
) 
;

INSERT INTO `kirjed` (`Isikukood`, `emi_id`
  , `Kirje`
  , `Perenimi`, `Eesnimi`, `Isanimi`
  , `Sünd`
  , `Välisviide`
  , `Märksõna`
  , `Allikas`
)
SELECT isikukood, NULL
  , Kirje
  , concat_ws(';', perenimi, pnvariandid), concat_ws(';', eesnimi, envariandid), concat_ws(';', isanimi, invariandid)
  , Sünd
  , Viide
  , if(Üksus IS NULL, 'Hävituspataljon', concat('Hävituspataljoni üksus ', Üksus))
  , 'HPAT'
FROM _hävituspataljonlased


UPDATE kirjed k
SELECT * FROM kirjed k
LEFT JOIN _hävituspataljonlased hp ON hp.seos = k.isikukood
 SET k.seos = hp.isikukood
WHERE hp.isikukood IS NOT NULL;


insert into kirjed (isikukood, kirje,
perenimi, eesnimi, isanimi, sünd, kivi, mittekivi, rel, mr, sugu, allikas)
select 
isikukood,
concat_ws('. ',
  concat_ws(', ', perenimi, eesnimi, isanimi),
  if(sünd is null, null, concat('Sünd ', sünd)),
  if(ifnull(`F`,ifnull(`I`,`O`)) IS NULL, NULL,
    concat_ws(', ', F, I, O)
  ),
  if(Rahvus = '', NULL, concat('Rahvus: ', Rahvus)),
  if(ifnull(`Toimik avatud`, `Toimik suletud`) IS NULL, NULL,
    concat('Toimik: ', `Toimik avatud`, ' - ', `Toimik suletud`)
  ),
  if(Paragrahv = '', NULL,
    concat('Paragrahv: ', `Paragrahv`)
  ),
  Märkused,
  concat('[', ERAF, ']')
),
ifnull(perenimi,''), ifnull(eesnimi,''), ifnull(isanimi,''), ifnull(sünd,''),
kivi, mittekivi, REL, MR, Sugu, 'ERAF.12SM'
from _F12sm;


-- Ununes kaasa võtta rahvuse veerg
UPDATE kirjed k
-- SELECT * FROM kirjed k
LEFT JOIN _F12sm sf ON sf.isikukood = k.isikukood
 SET k.rahvus = sf.rahvus
WHERE sf.rahvus != ''


insert into kirjed (isikukood, kirje,
perenimi, eesnimi, isanimi, sünd, 
kivi, mr, attn, sugu, allikas)

select 
isikukood,
concat_ws('. ',
  concat_ws(', ', perenimi, eesnimi, isanimi),
  if(ifnull(sünd,ifnull(sünnikoht,elu)) is null, null, concat('Sünd ', concat_ws(', ', sünd, sünnikoht, elu))),
  concat_ws(' ', märkus, surm, surmakoht, surmtxt),
  concat('[', viide, ']')
) as Kirje,
ifnull(perenimi,'') as perenimi, ifnull(eesnimi,'') as eesnimi, ifnull(isanimi,'') as isanimi, ifnull(sünd,'') as sünd,
kivi, MR, Attn, Sugu, 'ERAF.131SM'
from _F131sm
;

UPDATE kirjed k
SELECT * FROM kirjed k
LEFT JOIN _F131sm sf ON sf.seos = k.isikukood
 SET k.seos = sf.isikukood
WHERE sf.isikukood IS NOT NULL
AND sf.mr = '!' AND k.rel = '!'
;

UPDATE kirjed k
SELECT * FROM kirjed k
LEFT JOIN _F131sm sf ON sf.seos = k.isikukood
 SET k.seos = sf.isikukood
WHERE sf.isikukood IS NOT NULL;





INSERT INTO kirjed (isikukood, kirje, perenimi, eesnimi, isanimi, sünd, surm, kivi, rel, allikas, nimekiri, rahvus, välisviide) 
    SELECT isikukood, 
         Concat_ws('. ', Concat_ws(', ', perenimi, eesnimi, isanimi), 
         Concat('Sünd ', sünd), Concat('Surm ', surm), auaste, rahvus, IF( 
         välisviide = '', NULL, Concat('[', välisviide, ']'))) AS Kirje, 
         perenimi, 
         eesnimi, 
         isanimi, 
         sünd, 
         surm, 
         '!', 
         '!', 
         allikas, 
         nimekiri, 
         rahvus, 
         välisviide 
  FROM   _vangilaager2
  WHERE isikukood like 'SJV-004%'; 