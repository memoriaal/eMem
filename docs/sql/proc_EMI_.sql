DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_update_id_for`(
  IN _ik CHAR(10),
  IN _emi_id INTEGER(11) UNSIGNED,
  IN _user VARCHAR(50))
BEGIN
    UPDATE kirjed k
    LEFT JOIN seosed s ON s.isikukood2 = k.isikukood
                       AND s.seos = 'sama isik'
    SET k.emi_id = _emi_id, user = _user
    WHERE s.isikukood1 = _ik
    ;
    UPDATE kirjed k
    SET k.emi_id = _emi_id, user = _user
    WHERE k.isikukood = _ik
    ;
END;;



CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_merge`(
  IN _emi_id1 INTEGER(11) UNSIGNED,
  IN _emi_id2 INTEGER(11) UNSIGNED,
  IN _user VARCHAR(50))
BEGIN
    SELECT isikukood INTO @ik1 FROM kirjed WHERE emi_id = _emi_id1 LIMIT 1;
    SELECT isikukood INTO @ik2 FROM kirjed WHERE emi_id = _emi_id2 LIMIT 1;
    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
    VALUES (@ik1, @ik2, 'Create connections', NEW.seoseliik, _user);
END;;



CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_create_id_for`(
  IN _ik CHAR(10),
  OUT _emi_id INTEGER(11) UNSIGNED,
  IN _user VARCHAR(50))
BEGIN
    INSERT INTO EMIR SET id = NULL, user = _user;
    SELECT last_insert_id() INTO _emi_id;
    CALL EMI_update_id_for(_ik, _emi_id, _user);
END;;



CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_create_ref_for`(
  IN _old_emi_id INTEGER(11) UNSIGNED,
  IN _new_emi_id INTEGER(11) UNSIGNED,
  IN _user VARCHAR(50))
BEGIN
    INSERT INTO EMIR SET id = _old_emi_id, ref = _new_emi_id, user = _user
    ON DUPLICATE KEY UPDATE ref = _new_emi_id;

    SELECT id_set INTO @oldids FROM EMIR WHERE id = _old_emi_id;
    UPDATE EMIR e SET e.id_set = concat_ws(',', @oldids, e.id), user = _user
    WHERE e.id = _new_emi_id;
END;;



CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_consolidate_records`(
  IN _emi_id INTEGER(11) UNSIGNED,
  IN _user VARCHAR(50)
)
BEGIN
    UPDATE EMIR AS e
    LEFT JOIN (
      select k.emi_id
      , group_concat(
          if(k.perenimi = ''   OR a.prioriteetPerenimi = 0, NULL, UPPER(k.perenimi))
          ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';')
          AS perenimi
      , group_concat(
          if(k.eesnimi = ''    OR a.prioriteetEesnimi  = 0,  NULL, REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER'))
          ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';')
          AS eesnimi
      , group_concat(
          if(k.isanimi = ''    OR a.prioriteetIsanimi  = 0,  NULL, UPPER(k.isanimi))
          ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';')
          AS isanimi
      , group_concat(
          if(k.sünd = ''       OR a.prioriteetSünd     = 0,  NULL, LEFT(k.sünd,4))
          ORDER BY a.prioriteetSünd     DESC SEPARATOR ';')
          AS sünd
      , group_concat(
          if(k.surm = ''       OR a.prioriteetSurm     = 0,  NULL, LEFT(k.surm,4))
          ORDER BY a.prioriteetSurm     DESC SEPARATOR ';')
          AS surm
      , group_concat(
          if(k.kommentaar = '' OR a.prioriteetKirje    = 0,  NULL, k.kommentaar)
          ORDER BY a.prioriteetKirje    DESC SEPARATOR ';\n')
          AS kommentaarid
      , group_concat(
          if(                     a.prioriteetKirje    = 0,  NULL, concat(k.isikukood, ': ', k.kirje))
          ORDER BY a.prioriteetKirje    DESC SEPARATOR ';\n')
          AS kirjed
      from kirjed k
      left join v_prioriteedid a on a.kood = k.allikas
      where k.emi_id = _emi_id
      and k.EkslikKanne = ''
      and k.Puudulik = ''
      and k.Peatatud = ''
      group by k.emi_id
    ) krj ON krj.emi_id = e.id
    SET e.perenimi = krj.perenimi
      , e.eesnimi = krj.eesnimi
      , e.isanimi = krj.isanimi
      , e.sünd = krj.sünd
      , e.surm = krj.surm
      , e.kommentaarid = krj.kommentaarid
      , e.kirjed = krj.kirjed
      , e.user = _user
    WHERE e.id = _emi_id;
END;;


CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_check_record`(
  IN _ik CHAR(10),
  IN _old_emi_id VARCHAR(200),
  IN _user VARCHAR(50))
BEGIN
    SELECT emi_id INTO @emi_id FROM kirjed WHERE isikukood = _ik;

    IF @emi_id IS NULL THEN
        CALL EMI_create_id_for(_ik, @emi_id, _user);
        IF IFNULL(_old_emi_id, '') != '' THEN
            CALL EMI_create_ref_for(CAST(_old_emi_id AS UNSIGNED), @emi_id, _user);
        END IF;
    ELSE
        CALL EMI_update_id_for(_ik, @emi_id, _user);
    END IF;
    INSERT IGNORE INTO z_queue (emi_id, task, `user`)
    VALUES (@emi_id, 'Consolidate EMI records', _user);
    -- CALL EMI_consolidate_records(@emi_id);
END;;


CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `EMI_scheduled_propagate_referenced`(IN _user VARCHAR(50))
BEGIN
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.EmiPerenimi = e1.EmiPerenimi
  --  WHERE e2.EmiPerenimi IS NULL
  --    AND e1.EmiPerenimi IS NOT NULL;
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.EmiEesnimi = e1.EmiEesnimi
  --  WHERE e2.EmiEesnimi IS NULL
  --    AND e1.EmiEesnimi IS NOT NULL;
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.EmiIsanimi = e1.EmiIsanimi
  --  WHERE e2.EmiIsanimi IS NULL
  --    AND e1.EmiIsanimi IS NOT NULL;
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.EmiSünd = e1.EmiSünd
  --  WHERE e2.EmiSünd IS NULL
  --    AND e1.EmiSünd IS NOT NULL;
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.EmiSurm = e1.EmiSurm
  --  WHERE e2.EmiSurm IS NULL
  --    AND e1.EmiSurm IS NOT NULL;
  -- UPDATE EMIR e1 LEFT JOIN EMIR e2 on e2.id = e1.ref
  --    SET e2.välisviide = e1.välisviide
  --  WHERE e2.välisviide = ''
  --    AND e1.välisviide != '';
END;;

DELIMITER ;
