DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_silt(IN _ik CHAR(10), IN _silt VARCHAR(50), IN _user VARCHAR(50))
BEGIN
    INSERT INTO kirjesildid
    SET kirjekood = _ik, silt = _silt, user = _user
    ON DUPLICATE KEY UPDATE kustutatud = mod(kustutatud+1,2), user = _user;

    SET @labelstr = NULL;
    SELECT GROUP_CONCAT(concat(silt, ' - ', user, '@', now()) SEPARATOR '; \n') INTO @labelstr
    FROM kirjesildid
    WHERE kirjekood = _ik
    AND kustutatud = 0;

    UPDATE kirjed SET sildidCSV = @labelstr, user = _user
    WHERE isikukood = _ik;
END;;
DELIMITER ;
