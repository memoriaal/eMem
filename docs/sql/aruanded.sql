create or replace view aruanne_muutused_peale_publitseerimist_02_13 as
select o.emi_id, o.perenimi, o.eesnimi, o.isanimi, o.sünd, o.surm, o.kirjed, p.emi_id as Pemi_id, p.perenimi as Pperenimi, p.eesnimi as Peesnimi, p.isanimi as Pisanimi, p.sünd as Psünd, p.surm as Psurm, p.kirjed as Pkirjed
from ohvrite_nimekiri_2018_02_13 o
join v_publish p
on o.emi_id = p.emi_id
where o.perenimi != p.perenimi
   or o.eesnimi != p.eesnimi
   or o.isanimi != p.isanimi
   or o.sünd != p.sünd
   or o.surm != p.surm

union

select emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed, null, null, null, null, null, null, null
from ohvrite_nimekiri_2018_02_13
where emi_id not in
(
select emi_id from v_publish
)

union

select null, null, null, null, null, null, null, emi_id, perenimi, eesnimi, isanimi, sünd, surm, kirjed
from v_publish
where emi_id not in
(
select emi_id from ohvrite_nimekiri_2018_02_13
)
;
