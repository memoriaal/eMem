DELIMITER ;;
CREATE or REPLACE PROCEDURE `EMI_update_id_for`(IN _ik CHAR(10), IN _emi_id INTEGER(11) UNSIGNED)
BEGIN
    UPDATE kirjed k
    LEFT JOIN seosed s ON s.isikukood2 = k.isikukood
                       AND s.seos = 'sama isik'
    SET k.emi_id = _emi_id
    WHERE s.isikukood1 = _ik
    ;
    UPDATE kirjed k 
    SET k.emi_id = _emi_id
    WHERE k.isikukood = _ik
    ;
END;;



CREATE or REPLACE PROCEDURE `EMI_merge`(IN _emi_id1 INTEGER(11) UNSIGNED, IN _emi_id2 INTEGER(11) UNSIGNED)
BEGIN
    SELECT isikukood INTO @ik1 FROM kirjed WHERE emi_id = _emi_id1 LIMIT 1;
    SELECT isikukood INTO @ik2 FROM kirjed WHERE emi_id = _emi_id2 LIMIT 1;
    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
    VALUES (@ik1, @ik2, 'create connections', NEW.seoseliik, 'EMI merge');
END;;



CREATE or REPLACE PROCEDURE `EMI_create_id_for`(IN _ik CHAR(10), OUT _emi_id INTEGER(11) UNSIGNED)
BEGIN
    INSERT INTO EMIR SET id = NULL;
    SELECT last_insert_id() INTO _emi_id;
    CALL EMI_update_id_for(_ik, _emi_id);
END;;



CREATE or REPLACE PROCEDURE `EMI_create_ref_for`(
  IN _old_emi_id INTEGER(11) UNSIGNED, 
  IN _new_emi_id INTEGER(11) UNSIGNED)
BEGIN
    INSERT INTO EMIR SET id = _old_emi_id, ref = _new_emi_id
    ON DUPLICATE KEY UPDATE ref = _new_emi_id;
END;;



CREATE or REPLACE PROCEDURE `EMI_consolidate_records`(IN _emi_id INTEGER(11) UNSIGNED)
BEGIN
    UPDATE EMIR AS e 
    LEFT JOIN (
      select k.emi_id
      , group_concat( DISTINCT
          if(k.perenimi = ''   OR a.prioriteetPerenimi = 0, NULL, UPPER(k.perenimi)) 
          ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';')
          AS perenimi
      , group_concat( DISTINCT
          if(k.eesnimi = ''    OR a.prioriteetEesnimi = 0,  NULL, REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER')) 
          ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';')
          AS eesnimi
      , group_concat( DISTINCT
          if(k.isanimi = ''    OR a.prioriteetIsanimi = 0,  NULL, UPPER(k.isanimi))
          ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';')
          AS isanimi
      , group_concat( DISTINCT
          if(k.sünd = ''       OR a.prioriteetSünd = 0,     NULL, LEFT(k.sünd,4)) 
          ORDER BY a.prioriteetSünd     DESC SEPARATOR ';')
          AS sünd
      , group_concat( DISTINCT
          if(k.surm = ''       OR a.prioriteetSurm,         NULL, LEFT(k.surm,4)) 
          ORDER BY a.prioriteetSurm     DESC SEPARATOR ';')
          AS surm
      , group_concat( DISTINCT
          if(k.kommentaar = '' OR a.prioriteetKirje = 0,    NULL, k.kommentaar) 
          ORDER BY a.prioriteetKirje    DESC SEPARATOR ';\n')
          AS kommentaarid
      , group_concat(
          if(                     a.prioriteetKirje = 0,    NULL, concat(k.isikukood, ': ', k.kirje))
          ORDER BY a.prioriteetKirje    DESC SEPARATOR ';\n')
          AS kirjed
      from kirjed k
      left join v_prioriteedid a on a.kood = k.allikas
      where k.emi_id = _emi_id
      and k.EkslikKanne = ''
      group by k.emi_id
    ) krj ON krj.emi_id = e.id
    SET e.perenimi = krj.perenimi
      , e.eesnimi = krj.eesnimi
      , e.isanimi = krj.isanimi
      , e.sünd = krj.sünd
      , e.surm = krj.surm
      , e.kommentaarid = krj.kommentaarid
      , e.kirjed = krj.kirjed
    WHERE e.id = _emi_id;
END;;

CREATE or REPLACE PROCEDURE `EMI_check_record`(IN _ik CHAR(10), IN _old_emi_id VARCHAR(200))
BEGIN
    SELECT emi_id INTO @emi_id FROM kirjed WHERE isikukood = _ik;
    
    IF @emi_id IS NULL THEN
        call EMI_create_id_for(_ik, @emi_id);
        call EMI_create_ref_for(CAST(_old_emi_id AS UNSIGNED), @emi_id);
    ELSE
        call EMI_update_id_for(_ik, @emi_id);
    END IF;
    INSERT IGNORE INTO z_queue (emi_id, task, `user`)
    VALUES (@emi_id, 'Consolidate EMI records', 'EMI_check_record');
    -- call EMI_consolidate_records(@emi_id);
END;;
DELIMITER ;
