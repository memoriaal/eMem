update _vangilaagrisurmad vs
   left join kirjed k
      on    left(k.sünd, 4) = vs.sünniaasta
--        on k.sünd = vs.sünd
     and k.perenimi != ''
     and k.eesnimi != '' 
     and k.isanimi != ''
     and (
              k.perenimi regexp concat('(^|;)', vs.perenimi, '(;|$)')
           or k.perenimi regexp concat('(^|;)', vs.pnvariandid, '(;|$)')
         )
     and (
              k.eesnimi regexp concat('(^|;)', vs.eesnimi, '(;|$)')
           or k.eesnimi regexp concat('(^|;)', vs.envariandid, '(;|$)')
         )
     and (
              k.isanimi regexp concat('(^|;)', vs.isanimi, '(;|$)')
         )
     and vs.perenimi != ''
     and vs.eesnimi != ''
     and vs.isanimi != ''
SET vs.kahtlusseos = k.isikukood
where vs.sünd <> ''
  and vs.seos is null
  and k.emi_id is not null
;

update _vangilaagrisurmad
set seos = kahtlusseos, kahtlusseos = null
where seos is null and kahtlusseos is not null;

update _vangilaagrisurmad set kirje = 
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
FROM _vangilaagrisurmad


UPDATE kirjed k
SELECT * FROM kirjed k
LEFT JOIN _vangilaagrisurmad vs ON vs.seos = k.isikukood
 SET k.seos = vs.isikukood
WHERE vs.isikukood IS NOT NULL;