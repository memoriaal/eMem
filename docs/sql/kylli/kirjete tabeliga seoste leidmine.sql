update _r86_2017_12_copy set surm = '' where surm = '?';

update _r86_2017_12_copy set kahtlusseos = null, samaisik = null;

update _r86_2017_12_copy set samaisik = kahtlusseos, kahtlusseos = null where kahtlusseos is not null and kahtlusseos != '';

 update _r86_2017_12_copy rk
    left join kirjed k
       on    left(k.surm, 4) in (rk.usurm, rk.surm)
         and left(k.sünd, 4) in (rk.usünd, rk.sünd)
         and k.sünd != ''    and k.surm != ''
         and k.eesnimi != '' and k.perenimi != ''
--          and replace(rk.eesnimi,'-',' ') = replace(k.eesnimi,'-',' ')
--          and replace(rk.perenimi,'-',' ') = replace(k.perenimi,'-',' ')
         and concat('(^|;)', replace(k.eesnimi,'-',' '), '(;|$)') regexp replace(rk.eesnimi,'-',' ')
         and concat('(^|;)', replace(k.perenimi,'-',' '), '(;|$)') regexp replace(rk.perenimi,'-',' ')  
--          and (replace(rk.eesnimi,'-',' ') regexp replace(k.eesnimi,'-',' ') or replace(k.eesnimi,'-',' ') regexp replace(rk.eesnimi,'-',' '))  
--          and (replace(rk.perenimi,'-',' ') regexp replace(k.perenimi,'-',' ') or replace(k.perenimi,'-',' ') regexp replace(rk.perenimi,'-',' '))  
         and rk.eesnimi != ''
         and rk.perenimi != ''
 SET rk.kahtlusseos = k.isikukood
 where (rk.sünd <> '' or rk.usünd <> '')  
   and (rk.surm <> '' or rk.usurm <> '')  
   and rk.samaisik is null
   and rk.kahtlusseos is null
   and k.emi_id is not null
;


select r.perenimi, r.eesnimi, r.sünd, r.usünd, r.surm, r.usurm, r.samaisik, r.kahtlusseos, r.raamat, k.perenimi, k.eesnimi, k.sünd, k.surm, k.kirje
from _r86_2017_12_copy r
left join kirjed k on k.isikukood = r.samaisik
where r.samaisik is not null
and k.sünd = ''
and k.surm = '';
   
