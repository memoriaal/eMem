DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_lipik(IN _ik CHAR(10), IN _lipik VARCHAR(50), IN _user VARCHAR(50))
BEGIN
    INSERT INTO kirjelipikud
    SET kirjekood = _ik, lipik = _lipik, user = _user
    ON DUPLICATE KEY UPDATE kustutatud = mod(kustutatud+1,2), user = _user;

    CALL lipik_refresh(_ik);
END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE lipik_refresh(IN _ik CHAR(10))
BEGIN
    SET @lipikstr = NULL;
    SELECT GROUP_CONCAT(concat(lipik, ' - ', user, '@', now()) SEPARATOR '; \n') INTO @lipikstr
    FROM kirjelipikud
    WHERE kirjekood = _ik
    AND kustutatud = 0;

    UPDATE kirjed SET lipikudCSV = @lipikstr
    WHERE isikukood = _ik;
END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE lipik_refresh_all()
BEGIN

    DECLARE _ik CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT kirjekood
        FROM kirjelipikud
        WHERE kustutatud = 0;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _ik;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        CALL lipik_refresh(_ik);

    END LOOP;
    CLOSE cur1;
    SET finished = 0;
END;;
DELIMITER ;
