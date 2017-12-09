DELIMITER ;;
CREATE OR REPLACE PROCEDURE update_seosedCSV(IN _ik CHAR(10))
BEGIN
    DECLARE firstline INTEGER DEFAULT 1;
    DECLARE connstr TEXT;
    DECLARE _connstr VARCHAR(100);

    DECLARE _ik1 CHAR(10);
    DECLARE _ik2 CHAR(10);
    DECLARE _seos VARCHAR(50);
    DECLARE _direction VARCHAR(6);

    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT connection2string(s2.isikukood2, s2.seos, s2.isikukood1, ' --> ') AS conn
        FROM seosed s2
        WHERE s2.isikukood2 = _ik
        UNION
        SELECT connection2string(s1.isikukood1, s1.seos, s1.isikukood2, ' <-- ') AS conn
        -- SELECT s1.isikukood1, s1.seos, s1.isikukood2, ' <-- ' AS direction
        FROM seosed s1
        WHERE s1.isikukood1 = _ik;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _connstr;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;
        IF firstline = 0 THEN
            SET connstr = concat(connstr, '\n');
        ELSE 
            SET firstline = 0;
        END IF;
        SET connstr = concat(connstr, _connstr);
    END LOOP;
    CLOSE cur1;
    SET finished = 0;
    UPDATE kirjed SET seosedCSV = connstr
    WHERE isikukood = _ik;
END;;
DELIMITER ;
