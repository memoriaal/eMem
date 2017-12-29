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

CREATE or REPLACE PROCEDURE `EMI_create_id_for`(IN _ik CHAR(10), OUT _emi_id INTEGER(11) UNSIGNED)
BEGIN
    INSERT INTO EMIR SET id = NULL;
    SELECT last_insert_id() INTO _emi_id;
    CALL EMI_update_id_for(_ik, _emi_id);
END;;

CREATE or REPLACE PROCEDURE `EMI_consolidate_records`(IN _emi_id INTEGER(11) UNSIGNED)
BEGIN
    UPDATE EMIR AS e 
    LEFT JOIN (
      select k.emi_id
      , group_concat( DISTINCT
          if(k.perenimi = '', NULL, UPPER(k.perenimi)) 
          ORDER BY a.prioriteet DESC SEPARATOR ';')   AS perenimi
      , group_concat( DISTINCT
          if(k.eesnimi = '', NULL, REPLACE(UPPER(k.eesnimi),'ALEKSANDR','ALEKSANDER')) 
          ORDER BY a.prioriteet DESC SEPARATOR ';')   AS eesnimi
      , group_concat( DISTINCT
          if(k.allikas = 'RK', NULL, if(k.isanimi = '', NULL, UPPER(k.isanimi))) 
          ORDER BY a.prioriteet DESC SEPARATOR ';')   AS isanimi
      , group_concat( DISTINCT
          if(k.sünd = '', NULL, LEFT(k.sünd,4)) 
          ORDER BY a.prioriteet DESC SEPARATOR ';')   AS sünd
      , group_concat( DISTINCT
          if(k.surm = '', NULL, LEFT(k.surm,4)) 
          ORDER BY a.prioriteet DESC SEPARATOR ';')   AS surm
      , group_concat( DISTINCT
          if(k.kommentaar = '', NULL, k.kommentaar) 
          ORDER BY a.prioriteet DESC SEPARATOR ';\n') AS kommentaarid
      , group_concat(
          concat(k.isikukood, ': ', k.kirje) 
          ORDER BY a.prioriteet DESC SEPARATOR ';\n') AS kirjed
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

CREATE or REPLACE PROCEDURE `EMI_check_record`(IN _ik CHAR(10))
BEGIN
    SELECT emi_id INTO @emi_id FROM kirjed WHERE isikukood = _ik;
    
    IF @emi_id IS NULL THEN
        call EMI_create_id_for(_ik, @emi_id);
    ELSE
        call EMI_update_id_for(_ik, @emi_id);
    END IF;
    INSERT IGNORE INTO z_queue (emi_id, task, `user`)
    VALUES (@emi_id, 'Consolidate EMI records', 'EMI_check_record');
    -- call EMI_consolidate_records(@emi_id);
END;;
DELIMITER ;
