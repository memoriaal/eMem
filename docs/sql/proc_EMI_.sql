DELIMITER ;;
CREATE or replace PROCEDURE `EMI_update_id_for`(IN _ik CHAR(10), IN _emi_id INTEGER(11) UNSIGNED)
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

CREATE or replace PROCEDURE `EMI_create_id_for`(IN _ik CHAR(10), OUT _emi_id INTEGER(11) UNSIGNED)
BEGIN
    INSERT INTO EMIR SET id = NULL;
    SELECT last_insert_id() INTO _emi_id;
    CALL EMI_update_id_for(_ik, _emi_id);
END;;

CREATE or replace PROCEDURE `EMI_consolidate_records`(IN _emi_id INTEGER(11) UNSIGNED)
BEGIN
    UPDATE EMIR AS e 
    LEFT JOIN (
      select k.emi_id
      , group_concat(DISTINCT if(k.perenimi = '', null, upper(k.perenimi)) order by a.prioriteet desc SEPARATOR ';') as perenimi
      , group_concat(DISTINCT if(k.eesnimi = '', null, replace(upper(k.eesnimi),'ALEKSANDR','ALEKSANDER')) order by a.prioriteet desc SEPARATOR ';') as eesnimi
      , group_concat(DISTINCT if(
          k.allikas = 'RK', null, if(k.isanimi = '', null, upper(k.isanimi))
        ) order by a.prioriteet desc SEPARATOR ';') as isanimi
      , group_concat(DISTINCT if(k.sünd = '', null, left(k.sünd,4)) order by a.prioriteet desc SEPARATOR ';') as sünd
      , group_concat(DISTINCT if(k.surm = '', null, left(k.surm,4)) order by a.prioriteet desc SEPARATOR ';') as surm
      , group_concat(DISTINCT if(k.kommentaar = '', null, k.kommentaar) order by a.prioriteet desc SEPARATOR ';\n') as kommentaarid
      , group_concat( concat(k.isikukood, ': ', k.kirje) order by a.prioriteet desc SEPARATOR ';\n') as kirjed
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

CREATE or replace PROCEDURE `EMI_check_record`(IN _ik CHAR(10))
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
