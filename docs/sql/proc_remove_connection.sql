DELIMITER ;;
CREATE OR REPLACE PROCEDURE remove_connection(IN ik1 CHAR(10), IN ik2 CHAR(10))
proc_label:BEGIN
    DECLARE _ik1 CHAR(10);
    DECLARE _ik2 CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE cur1 CURSOR FOR
    SELECT ik1 as n_ik1, isikukood2 AS n_ik2
      FROM seosed
     WHERE isikukood1 = ik2
       AND seos = 'sama isik'
     UNION ALL SELECT ik1, ik2;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _ik1, _ik2;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;
        IF _ik1 = _ik2 THEN
            ITERATE read_loop;
        END IF;

        DELETE FROM seosed
        WHERE isikukood1 = _ik1 AND isikukood2 = _ik2;
        DELETE FROM seosed
        WHERE isikukood1 = _ik2 AND isikukood2 = _ik1;
        
        INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
        VALUES (_ik1, null, 'update seosedCSV', '', user());
        INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
        VALUES (_ik2, null, 'update seosedCSV', '', user());
    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;
DELIMITER ;
