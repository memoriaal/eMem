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
        , group_concat(DISTINCT upper(k.perenimi) SEPARATOR ';') as perenimi
        , group_concat(DISTINCT upper(k.eesnimi) SEPARATOR ';') as eesnimi
        , group_concat(DISTINCT upper(k.isanimi) SEPARATOR ';') as isanimi
        , group_concat(DISTINCT k.sünd SEPARATOR ';') as sünd
        , group_concat(DISTINCT k.surm SEPARATOR ';') as surm
        , group_concat(DISTINCT k.kommentaar SEPARATOR ';\n') as kommentaarid
        , group_concat(DISTINCT concat(k.isikukood, ': ', k.kirje) SEPARATOR ';\n') as kirjed
        from kirjed k
        where k.emi_id = _emi_id
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
    call EMI_consolidate_records(@emi_id);
END;;
DELIMITER ;
