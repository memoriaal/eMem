-- 1.
CREATE OR REPLACE TABLE `x_nimekujud` (
  `id` int(11) unsigned NOT NULL,
  `tunnus` enum('','id','perenimi','eesnimi','isanimi','emanimi','sünd','surm') NOT NULL DEFAULT '',
  `v` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `moonutatud` enum('','Ei','Jah') NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`tunnus`,`v`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 2.
insert ignore into x_nimekujud (id, tunnus, v)
select distinct emi_id, 'id', emi_id
from kirjed k
where k.MR != '!';

-- 3.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'perenimi',  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          perenimi
        ),'-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and perenimi != ''
  and k.MR != '!';

-- 4.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'eesnimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          eesnimi
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and eesnimi != ''
  and k.MR != '!';

-- 5.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'isanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          isanimi
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and isanimi != ''
  and k.MR != '!';

-- 6.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          emanimi
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and emanimi != ''
  and k.MR != '!';

-- 7.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'sünd', SUBSTRING_INDEX(SUBSTRING_INDEX(sünd, ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and sünd != ''
  and k.MR != '!';

-- 8.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'surm', SUBSTRING_INDEX(SUBSTRING_INDEX(surm, ';', n.n), ';', -1)
, 'Ei'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and surm != ''
  and k.MR != '!';


-- Moonutatud nimekujud

-- 9.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'perenimi',  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          perenimi
        )),'-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and perenimi != ''
  and k.MR != '!';

-- 10.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'eesnimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          eesnimi
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and eesnimi != ''
  and k.MR != '!';

-- 11.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'isanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          isanimi
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and isanimi != ''
  and k.MR != '!';

-- 12.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          emanimi
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and emanimi != ''
  and k.MR != '!';

-- 13.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'sünd', LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(sünd, ';', n.n), ';', -1), 4)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and sünd != ''
  and k.MR != '!';

-- 14.
insert ignore into x_nimekujud (id, tunnus, v, moonutatud)
select distinct emi_id, 'surm', LEFT(SUBSTRING_INDEX(SUBSTRING_INDEX(surm, ';', n.n), ';', -1), 4)
, 'Jah'
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where allikas != 'Nimekujud' and surm != ''
  and k.MR != '!';


-- 15.
DELETE FROM x_nimekujud WHERE v = '';

-- 16.
CREATE OR REPLACE TABLE `y_nimekujud` (
  `id` int(11) unsigned NOT NULL,
  `perenimi` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `eesnimi` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `isanimi` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `emanimi` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `sünd` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `surm` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL,
  `moonutatud` enum('','Ei','Jah') NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`perenimi`,`eesnimi`,`isanimi`,`emanimi`,`sünd`,`surm`),
  KEY `perenimi` (`perenimi`,`eesnimi`,`isanimi`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 as

select x0.id, ifnull(x1.v,'') as perenimi, ifnull(x2.v,'') as eesnimi
            , ifnull(x3.v,'') as isanimi, ifnull(x4.v,'') as emanimi
            , ifnull(x5.v,'') as sünd, ifnull(x6.v,'') as surm
            , 'Ei' as moonutatud
from x_nimekujud x0
left join x_nimekujud x1 on x1.id = x0.id and x1.tunnus = 'perenimi' and x1.moonutatud = 'Ei'
left join x_nimekujud x2 on x2.id = x0.id and x2.tunnus = 'eesnimi'  and x2.moonutatud = 'Ei'
left join x_nimekujud x3 on x3.id = x0.id and x3.tunnus = 'isanimi'  and x3.moonutatud = 'Ei'
left join x_nimekujud x4 on x4.id = x0.id and x4.tunnus = 'emanimi'  and x4.moonutatud = 'Ei'
left join x_nimekujud x5 on x5.id = x0.id and x5.tunnus = 'sünd'
left join x_nimekujud x6 on x6.id = x0.id and x6.tunnus = 'surm'
where x0.tunnus = 'id'
;

-- 17.
INSERT IGNORE INTO `y_nimekujud`
(id, perenimi, eesnimi, isanimi, emanimi, sünd, surm, moonutatud)
select x0.id, ifnull(x1.v,'') as perenimi, ifnull(x2.v,'') as eesnimi
            , ifnull(x3.v,'') as isanimi, ifnull(x4.v,'') as emanimi
            , ifnull(x5.v,'') as sünd, ifnull(x6.v,'') as surm
            , 'Jah' as moonutatud
from      x_nimekujud x0
left join x_nimekujud x1 on x1.id = x0.id and x1.tunnus = 'perenimi' and x1.moonutatud = 'Jah'
left join x_nimekujud x2 on x2.id = x0.id and x2.tunnus = 'eesnimi'  and x2.moonutatud = 'Jah'
left join x_nimekujud x3 on x3.id = x0.id and x3.tunnus = 'isanimi'  and x3.moonutatud = 'Jah'
left join x_nimekujud x4 on x4.id = x0.id and x4.tunnus = 'emanimi'  and x4.moonutatud = 'Jah'
left join x_nimekujud x5 on x5.id = x0.id and x5.tunnus = 'sünd'
left join x_nimekujud x6 on x6.id = x0.id and x6.tunnus = 'surm'
where x0.tunnus = 'id'
;



-- INSERT IGNORE INTO y_nimekujud SELECT * FROM y_nimekujud3;
--
-- Range vastete otsing
--

-- create or replace table aruanne_kontrolli_seoseid3
-- INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task) SELECT k1.isikukood, k2.isikukood, 'Remove connections'
-- INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task) SELECT k1.isikukood, k2.isikukood, 'Create connections'
select concat('emi_id in (',id1,',',id2,')') as koodid
     , e1.kirjed as kirjed1
     , if(s.seos = 'erinevad isikud', 'E', 
     		if(s.seos = 'kahtlusseos', 'U', NULL)) as kasSama
     , e2.kirjed as kirjed2
from (
  select y1.id as id1, y2.id as id2 from y_nimekujud y1
  left join y_nimekujud y2 
         on y2.id < y1.id 
        and y2.perenimi = y1.perenimi 
        and y2.perenimi != ''
        and y2.eesnimi = y1.eesnimi 
        and y2.eesnimi != ''
        and y2.isanimi = y1.isanimi
        and y2.isanimi != ''
        and y2.sünd = y1.sünd 
        and y2.surm = y1.surm
        and (y1.sünd != '' or y2.surm != '')
  where y2.id is not null
  group by y1.id, y2.id
) yy
left join EMIR e1 on e1.id = yy.id1
left join EMIR e2 on e2.id = yy.id2
left join kirjed k1 on k1.emi_id = e1.id
left join kirjed k2 on k2.emi_id = e2.id
left join seosed s on s.isikukood1 = k1.isikukood and s.isikukood2 = k2.isikukood and s.seos IN ('erinevad isikud','kahtlusseos')
 where k1.emi_id is not null 
   and k2.emi_id is not null
group by id1,id2
;
--
-- Hägus vastete otsing
--

-- create or replace table aruanne_kontrolli_seoseid3
-- INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task) SELECT k1.isikukood, k2.isikukood, 'Remove connections'
-- INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task) SELECT k1.isikukood, k2.isikukood, 'Create connections'
select concat_ws(',',id1,id2)
     , e1.kirjed as kirjed1, k1.isikukood as isikukood1, k1.kivi as kivi1
     , k2.kivi as kivi2, k2.isikukood as isikukood2, e2.kirjed as kirjed2 
from (
  select y1.id as id1, y2.id as id2 from y_nimekujud y1
  left join y_nimekujud y2 
         on y2.id < y1.id 
        and y2.perenimi = y1.perenimi 
        and y2.eesnimi = y1.eesnimi 
        and (y2.isanimi = y1.isanimi OR y2.isanimi = '' OR y1.isanimi = '') 
--         and y2.emanimi = y1.emanimi 
        and left(y2.sünd, 4) = left(y1.sünd, 4) 
        and (left(y2.surm,4) = left(y1.surm, 4) OR y1.surm = '' OR y2.surm = '') 
  where y2.id is not null
  group by y1.id, y2.id
) yy
left join EMIR e1 on e1.id = yy.id1
left join EMIR e2 on e2.id = yy.id2
left join kirjed k1 on k1.emi_id = e1.id
left join kirjed k2 on k2.emi_id = e2.id
 where k1.eesnimi != ''
   and k1.perenimi != ''
   and (k1.sünd != '' or k2.sünd != '')
   and k1.emi_id is not null 
   and k2.emi_id is not null
group by id1,id2
;



-- 
-- nimevasted
-- 
select concat_ws(',',id1,id2)
     , e1.kirjed as kirjed1, k1.isikukood as isikukood1, k1.kivi as kivi1
     , k2.kivi as kivi2, k2.isikukood as isikukood2, e2.kirjed as kirjed2 
from (
  select y1.id as id1, y2.id as id2 
    from y_nimekujud3 y1
    left join y_nimekujud3 y2 
           on y2.id < y1.id 
          and y2.perenimi = y1.perenimi 
          and y2.eesnimi = y1.eesnimi 
          and y2.isanimi = y1.isanimi 
--         and y2.emanimi = y1.emanimi 
        -- and left(y2.sünd, 4) = left(y1.sünd, 4) 
        -- and (left(y2.surm,4) = left(y1.surm, 4) OR y1.surm = '' OR y2.surm = '') 
  where y2.id is not null
  group by y1.id, y2.id
) yy
left join EMIR e1 on e1.id = yy.id1
left join EMIR e2 on e2.id = yy.id2
left join kirjed k1 on k1.emi_id = e1.id
left join kirjed k2 on k2.emi_id = e2.id
 where k1.eesnimi  != ''
   and k1.perenimi != ''
   and k1.isanimi  != ''
   and k1.emi_id is not null 
   and k2.emi_id is not null
group by id1,id2
;
