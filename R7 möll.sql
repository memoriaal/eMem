-- R7 MÖLL

select k.isikukood, r.*, k.*, nk.*
from _r7 r
left join y_nimekujud3 nk
  on r.perenimi = nk.perenimi
 and r.eesnimi = nk.eesnimi
 and (r.sünniaasta = left(nk.sünd, 4) or left(r.altSünd, 4) = left(nk.sünd, 4))
left join kirjed k
  on k.emi_id = nk.id
 and find_in_set(replace(k.allikas, '-', ''), r.rviidad)
where nk.id is not null
  and r.r6 = 1
  and k.isikukood is not null
-- group by r.memento, k.isikukood
-- limit 10000
;

select distinct rviidad from _r7;
select distinct allikas from kirjed;

ALTER TABLE `_r7` ADD `eR1` int(11) UNSIGNED NULL DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR2` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR3` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR41` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR42` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR5` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR62` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR61` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR63` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR64` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR65` int(11) UNSIGNED NULL  DEFAULT NULL;
ALTER TABLE `_r7` ADD `eR6` int(11) UNSIGNED NULL  DEFAULT NULL;

select * from _r7 where find_in_set('R63', rviidad);

UPDATE _r7 SET R1  = 'X' where find_in_set('R1', rviidad);
UPDATE _r7 SET R2  = 'X' where find_in_set('R2', rviidad);
UPDATE _r7 SET R3  = 'X' where find_in_set('R3', rviidad);
UPDATE _r7 SET R41 = 'X' where find_in_set('R41', rviidad);
UPDATE _r7 SET R42 = 'X' where find_in_set('R42', rviidad);
UPDATE _r7 SET R5  = 'X' where find_in_set('R5', rviidad);
UPDATE _r7 SET R62 = 'X' where find_in_set('R62', rviidad);
UPDATE _r7 SET R61 = 'X' where find_in_set('R61', rviidad);
UPDATE _r7 SET R63 = 'X' where find_in_set('R63', rviidad);
UPDATE _r7 SET R64 = 'X' where find_in_set('R64', rviidad);
UPDATE _r7 SET R65 = 'X' where find_in_set('R65', rviidad);


-- Nimekujudest vasted
update _r7 r
-- select k.isikukood, r.*, k.*, nk.* from _r7 r
left join y_nimekujud3 nk
  on r.perenimi = nk.perenimi
 and r.eesnimi = nk.eesnimi
 and (r.sünniaasta = left(nk.sünd, 4) or left(r.altSünd, 4) = left(nk.sünd, 4))
left join kirjed k
  on k.emi_id = nk.id
 and find_in_set(replace(k.allikas, '-', ''), r.rviidad)
                               set r.r63 = k.isikukood
where                              r.R63 is not null
  and replace(k.allikas, '-', '') = 'R63'
  and nk.id is not null
-- group by r.memento, k.isikukood
-- limit 10000
;

-- Kirjetest vasted
update _r7 r
-- select k.isikukood, r.*, k.* from _r7 r
left join kirjed k
  on r.perenimi = k.perenimi
 and r.eesnimi = k.eesnimi
 and (r.sünniaasta = left(k.sünd, 4) or left(r.altSünd, 4) = left(k.sünd, 4))
 and find_in_set(replace(k.allikas, '-', ''), r.rviidad)
 and replace(k.allikas, '-', '')
     = 'R65'
  set r.R65 = k.isikukood
where k.isikukood is not null
  and r.R65 = '1'
;
update _r7 r
set r63 = 'X' where r63 = '1';

update _r7 r
left join kirjed k
  on k.isikukood
     = r.R1
  set r.eR1 = k.emi_id
where r.eR1 is null
  and k.emi_id is not null
;

SELECT GROUP_CONCAT(';', '3','4','5' SEPARATOR ',');

select concat_ws(',', r.eR1, r.eR2, r.eR3, r.eR41, r.eR42, r.eR5, r.eR61, r.eR62, r.eR63, r.eR64, r.eR65) eids, r.*
from _r7 as r
group by r.memento
having eids like '%,%'
;

select * from
(select group_concat(distinct eid separator ',') eids, r.memento
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
having eids like '%,%'
) rr
left join kirjed k on find_in_set(k.emi_id, rr.eids) and k.allikas != 'Nimekujud'
order by rr.memento, rr.eids, k.emi_id
;



select group_concat(distinct eid separator ',') eids
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
having eids like '%,%'
;