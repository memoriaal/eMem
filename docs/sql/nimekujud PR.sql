CREATE OR REPLACE TABLE `x_prNimekujud` (
  `id` int(11) unsigned NOT NULL,
  `tunnus` enum('','id','perenimi','eesnimi','isanimi','emanimi','sünd','surm') NOT NULL DEFAULT '',
  `v` varchar(25) CHARACTER SET utf8 COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `moonutatud` enum('','Ei','Jah') NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`tunnus`,`v`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


insert ignore into x_prNimekujud (id, tunnus, v)
select distinct id, 'id', id
from pereregister pr;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'perenimi',  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          concat_ws(';', isik_perenimi, isik_perenimi_endine1, isik_perenimi_endine2, isik_perenimi_endine3, isik_perenimi_endine4)
        ),'-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isik_perenimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'eesnimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          concat_ws(';', isik_eesnimi, isik_eesnimi_endine1, isik_eesnimi_endine2)
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isik_eesnimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'isanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          concat_ws(';', isa_eesnimi)
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isa_eesnimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(UPPER(
          concat_ws(';', ema_eesnimi)
        ), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Ei'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where ema_eesnimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'sünd', concat_ws('-', isik_synniaasta, isik_synnikuu, isik_synnipaev)
, 'Ei'
from pereregister pr
where isik_synniaasta != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'surm', concat_ws('-', isik_surmaaasta, isik_surmakuu, isik_surmapaev)
, 'Ei'
from pereregister pr
where isik_surmaaasta != '' ;


delete from x_prNimekujud where v = '';


CREATE OR REPLACE TABLE `y_prNimekujud` (
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
from x_prNimekujud x0
left join x_prNimekujud x1 on x1.id = x0.id and x1.tunnus = 'perenimi' and x1.moonutatud = 'Ei'
left join x_prNimekujud x2 on x2.id = x0.id and x2.tunnus = 'eesnimi'  and x2.moonutatud = 'Ei'
left join x_prNimekujud x3 on x3.id = x0.id and x3.tunnus = 'isanimi'  and x3.moonutatud = 'Ei'
left join x_prNimekujud x4 on x4.id = x0.id and x4.tunnus = 'emanimi'  and x4.moonutatud = 'Ei'
left join x_prNimekujud x5 on x5.id = x0.id and x5.tunnus = 'sünd'
left join x_prNimekujud x6 on x6.id = x0.id and x6.tunnus = 'surm'
where x0.tunnus = 'id'
;

-- Moonutatud nimekujud

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'perenimi',  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          concat_ws(';', isik_perenimi, isik_perenimi_endine1, isik_perenimi_endine2, isik_perenimi_endine3, isik_perenimi_endine4)
        )),'-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isik_perenimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'eesnimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          concat_ws(';', isik_eesnimi, isik_eesnimi_endine1, isik_eesnimi_endine2)
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isik_eesnimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'isanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          concat_ws(';', isa_eesnimi)
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where isa_eesnimi != '' ;

insert ignore into x_prNimekujud (id, tunnus, v, moonutatud)
select distinct id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(unrepeat(UPPER(
          concat_ws(';', ema_eesnimi)
        )), '-',';'),' ',';'), ';', n.n), ';', -1)
, 'Jah'
from pereregister pr
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 9 union all select 10 union all select 11 union all select 12 union all 
   select 13 union all select 14 union all select 15 union all select 16 union all select 17) n
where ema_eesnimi != '' ;


delete from x_prNimekujud where v = '';


INSERT INTO `y_prNimekujud` 
(id, perenimi, eesnimi, isanimi, emanimi, sünd, surm, moonutatud)
select x0.id, ifnull(x1.v,'') as perenimi, ifnull(x2.v,'') as eesnimi
            , ifnull(x3.v,'') as isanimi, ifnull(x4.v,'') as emanimi
            , ifnull(x5.v,'') as sünd, ifnull(x6.v,'') as surm
            , 'Jah' as moonutatud
from      x_prNimekujud x0 
left join x_prNimekujud x1 on x1.id = x0.id and x1.tunnus = 'perenimi' and x1.moonutatud = 'Jah'
left join x_prNimekujud x2 on x2.id = x0.id and x2.tunnus = 'eesnimi'  and x2.moonutatud = 'Jah'
left join x_prNimekujud x3 on x3.id = x0.id and x3.tunnus = 'isanimi'  and x3.moonutatud = 'Jah'
left join x_prNimekujud x4 on x4.id = x0.id and x4.tunnus = 'emanimi'  and x4.moonutatud = 'Jah'
left join x_prNimekujud x5 on x5.id = x0.id and x5.tunnus = 'sünd'
left join x_prNimekujud x6 on x6.id = x0.id and x6.tunnus = 'surm'
where x0.tunnus = 'id'
;



--
-- Hägus vastete otsing
--

select e.id, e.kirjed, pr.*
from y_prNimekujud yp
left join pereregister pr on pr.id = yp.id and pr.import = 0
left join y_nimekujud yk
       on yk.perenimi = yp.perenimi
      and yk.eesnimi = yp.eesnimi
      and yk.isanimi = yp.isanimi
--       and yk.sünd = yp.sünd
      and (left(yk.sünd,4) = left(yp.sünd,4)) -- or y1.sünd = '' or y2.sünd = '')
      and (yk.surm = yp.surm or yk.surm = '' or yp.surm = '')
      and yp.perenimi != ''
      and yp.eesnimi != ''
      and yp.isanimi != ''
      and yp.sünd != ''
--       and yp.surm != ''
left join EMIR e on e.id = yk.id
where pr.id is not null and yk.id is not null
group by pr.id, yk.id
order by pr.isik_perenimi;