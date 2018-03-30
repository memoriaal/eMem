

CREATE or replace TABLE `_nk_kirjed` (
  `kirjekood` varchar(10) NOT NULL,
  `seos` varchar(10) NOT NULL,
  `perenimi` mediumtext CHARACTER SET utf8 COLLATE utf8_estonian_ci DEFAULT NULL,
  `eesnimi` mediumtext CHARACTER SET utf8 COLLATE utf8_estonian_ci DEFAULT NULL,
  `isanimi` mediumtext CHARACTER SET utf8 COLLATE utf8_estonian_ci DEFAULT NULL,
  `sünd` mediumtext CHARACTER SET utf8 COLLATE utf8_estonian_ci DEFAULT NULL,
  `surm` mediumtext CHARACTER SET utf8 COLLATE utf8_estonian_ci DEFAULT NULL,
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
select right(max(isikukood), 7)+1 into @ai from kirjed where allikas = 'Nimekujud';
SET @sql = CONCAT('ALTER TABLE `_nk_kirjed` AUTO_INCREMENT = ', @ai);
PREPARE st FROM @sql;
EXECUTE st;

-- SELECT @ai
;

INSERT INTO _nk_kirjed
      select "NK-0000000" as kirjekood, k.isikukood as seos
      , SUBSTRING_INDEX(group_concat(
          if(k.perenimi = ''   OR a.prioriteetPerenimi = 0, '', UPPER(k.perenimi)) 
          ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1)
          AS perenimi
      , SUBSTRING_INDEX(group_concat(
          if(k.eesnimi = ''    OR a.prioriteetEesnimi  = 0,  '', REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER')) 
          ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1)
          AS eesnimi
      , SUBSTRING_INDEX(group_concat(
          if(k.isanimi = ''    OR a.prioriteetIsanimi  = 0,  '', UPPER(k.isanimi))
          ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1)
          AS isanimi
      , SUBSTRING_INDEX(group_concat(
          if(k.sünd = ''       OR a.prioriteetSünd     = 0,  '', LEFT(k.sünd,4)) 
          ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1)
          AS sünd
      , SUBSTRING_INDEX(group_concat(
          if(k.surm = ''       OR a.prioriteetSurm     = 0,  '', LEFT(k.surm,4)) 
          ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1)
          AS surm
      , NULL as id
      from kirjed k
      left join v_prioriteedid a on a.kood = k.allikas
      where k.kivi != '!'
      and k.EkslikKanne = ''
      and k.Puudulik = ''
      and k.Peatatud = ''
      group by k.emi_id
;

UPDATE _nk_kirjed SET kirjekood = lpad(id, 10, 'NK-0000000')
;

INSERT INTO kirjed (isikukood, perenimi, eesnimi, isanimi, sünd, surm, silt, allikas)
SELECT kirjekood, perenimi, eesnimi, isanimi, sünd, surm, NULL, 'Nimekujud' FROM _nk_kirjed
;

TRUNCATE TABLE z_queue;
TRUNCATE TABLE z_queue_bu;
INSERT INTO z_queue_bu (isikukood1, isikukood2, task) SELECT kirjekood, seos, 'Create connections' FROM _nk_kirjed ;

-- delete from kirjed where isikukood like 'NK-%' and allikas = '';

SET GLOBAL event_scheduler=OFF;
ALTER EVENT process_queue DISABLE;

select count(1) from z_queue;
select count(1) from z_queue_bu where rdy = 0;

select max(id) into @m from (select * from z_queue_bu where rdy = 0 limit 50000) mz;
insert into z_queue select * from z_queue_bu where rdy = 0 and id <= @m;
update z_queue_bu set rdy = 1 where rdy = 0 and id <= @m;

call process_queue();

