--
-- x_nimekujud4
--
CREATE TABLE `x_nimekujud4` (
  `id` int(11) unsigned NOT NULL,
  `tunnus` enum('','perenimi','eesnimi','isanimi','emanimi','sünd','surm') NOT NULL DEFAULT '',
  `v` varchar(25) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`,`tunnus`,`v`),
  CONSTRAINT `x_nimekujud_ibfk_4` FOREIGN KEY (`id`) REFERENCES `EMIR` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


select distinct emi_id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(emanimi, '-',';'),' ',';'), ';', n.n), ';', -1)
from kirjed k 
INNER JOIN
(select 1 n union all
 select 2   union all select 3 union all
 select 4   union all select 5 union all
 select 6   union all select 7 union all
 select 8   union all select 7 union all
 select 10  union all select 11) n
where k.emanimi != '' ;



insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'perenimi',  SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(perenimi,'-',';'),' ',';'), ';', n.n), ';', -1)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where perenimi != '' ;

insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'eesnimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(eesnimi, '-',';'),' ',';'), ';', n.n), ';', -1)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where eesnimi != '' ;

insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'isanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(isanimi, '-',';'),' ',';'), ';', n.n), ';', -1)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where isanimi != '' ;

insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'emanimi',   SUBSTRING_INDEX(SUBSTRING_INDEX(replace(replace(emanimi, '-',';'),' ',';'), ';', n.n), ';', -1)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where emanimi != '' ;

insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'sünd', left(SUBSTRING_INDEX(SUBSTRING_INDEX(                                      sünd, ';', n.n), ';', -1), 4)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where sünd != '' ;

insert ignore into x_nimekujud4 (id, tunnus, v)
select emi_id, 'surm', left(SUBSTRING_INDEX(SUBSTRING_INDEX(                                      surm, ';', n.n), ';', -1), 4)
from kirjed k 
INNER JOIN
(select 1 n union all select 2 union all select 3 union all select 4 union all 
   select 5 union all select 6 union all select 7 union all select 8 union all 
   select 7 union all select 10 union all select 11) n
where surm != '' ;

create or replace table y_nimekujud4 as
select x1.id, ifnull(x1.v,'') as perenimi, ifnull(x2.v,'') as eesnimi
            , ifnull(x3.v,'') as isanimi, ifnull(x4.v,'') as emanimi
            , ifnull(x5.v,'') as sünd, ifnull(x6.v,'') as surm
from      x_nimekujud4 x1 
left join x_nimekujud4 x2 on x2.id = x1.id and x2.tunnus = 'eesnimi'
left join x_nimekujud4 x3 on x3.id = x1.id and x3.tunnus = 'isanimi'
left join x_nimekujud4 x4 on x4.id = x1.id and x4.tunnus = 'emanimi'
left join x_nimekujud4 x5 on x5.id = x1.id and x5.tunnus = 'sünd'
left join x_nimekujud4 x6 on x6.id = x1.id and x6.tunnus = 'surm'
where x1.tunnus = 'perenimi'
;

ALTER TABLE `y_nimekujud4` ADD INDEX (`perenimi`, `eesnimi`, `isanimi`);

select concat_ws(',',id1,id2)
     , e1.kirjed, k1.isikukood, k1.kivi
     , k2.kivi, k2.isikukood, e2.kirjed 
from (
  select y1.id as id1, y2.id as id2 from y_nimekujud4 y1
  left join y_nimekujud4 y2 on y2.id < y1.id and
  y2.perenimi = y1.perenimi and
  y2.eesnimi = y1.eesnimi and
  y2.isanimi = y1.isanimi and
  y2.emanimi = y1.emanimi and
  y2.sünd = y1.sünd and
  y2.surm = y1.surm 
  where y2.id is not null
  group by y1.id, y2.id
) yy
left join EMIR e1 on e1.id = yy.id1
left join EMIR e2 on e2.id = yy.id2
left join kirjed k1 on k1.emi_id = e1.id
left join kirjed k2 on k2.emi_id = e2.id
 where k1.eesnimi != ''
   and k1.perenimi != ''
   and k1.sünd != '' or k1.surm != ''
group by id1,id2
having k1.kivi = '' and k2.kivi = ''
;
-- 2492 duplikaati mittekivide seas






create table nk1 as
select distinct
  nk.sünniaasta,
  nk.surmaaasta,
  SUBSTRING_INDEX(SUBSTRING_INDEX(nk.perenimed, ';', n.n), ';', -1) perenimed,
  nk.eesnimed,
  nk.isanimed
from
  (select 1 n union all
   select 2   union all select 3 union all
   select 4   union all select 5 union all
   select 6   union all select 7 union all
   select 8   union all select 7 union all
   select 10  union all select 11) n
INNER JOIN nimekujud0 as nk
;
