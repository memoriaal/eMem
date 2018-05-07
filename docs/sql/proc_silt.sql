DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_silt(IN _ik CHAR(10), IN _silt VARCHAR(50), IN _user VARCHAR(50))
BEGIN
    INSERT IGNORE INTO kirjesildid
    SET kirjekood = _ik, silt = _silt, user = _user;
    -- ON DUPLICATE KEY UPDATE kustutatud = mod(kustutatud+1,2), user = _user;

    CALL silt_refresh(_ik);
END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE silt_refresh(IN _ik CHAR(10))
BEGIN
    SET @labelstr = NULL;
    SELECT GROUP_CONCAT(concat(silt, ' - ', user, '@', now()) SEPARATOR '; \n') INTO @labelstr
    FROM kirjesildid
    WHERE kirjekood = _ik
    AND kustutatud = 0;

    UPDATE kirjed SET sildidCSV = @labelstr
    WHERE isikukood = _ik;
END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE silt_refresh_all()
BEGIN

    DECLARE _ik CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT kirjekood
        FROM kirjesildid
        WHERE kustutatud = 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _ik;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL silt_refresh(_ik);

    END LOOP;
    CLOSE cur1;
    SET finished = 0;
END;;
DELIMITER ;
