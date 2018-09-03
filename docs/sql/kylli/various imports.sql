insert into kirjed (isikukood, perenimi, eesnimi, isanimi, sünd, surm, kirje, kivi, allikas)
select isikukood, perenimi, eesnimi, isanimi, sünd, surm, 
  concat(perenimi, 
         if(eesnimi!='', concat(', ', eesnimi), ''), 
         if(isanimi!='', concat(', ', isanimi), ''), '. ',
         if(sünd, concat('Sünd ', sünd, '. '), ''),
         if(surm, concat('Surm ', surm, '. '), ''),
         kirje, ' ', allikas
         ) as kirje,
  '!' as kivi, 
  'MM' as allikas
from _metsavennad;

