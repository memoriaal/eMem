DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_lipik(IN _ik CHAR(10), IN _lipik VARCHAR(50), IN _user VARCHAR(50))
BEGIN
    INSERT INTO kirjelipikud
    SET kirjekood = _ik, lipik = _lipik, user = _user
    ON DUPLICATE KEY UPDATE kustutatud = mod(kustutatud+1,2), user = _user;

    SET @lipikstr = NULL;
    SELECT GROUP_CONCAT(concat(lipik, ' - ', user, '@', now()) SEPARATOR '; \n') INTO @lipikstr
    FROM kirjelipikud
    WHERE kirjekood = _ik
    AND kustutatud = 0;

    UPDATE kirjed SET lipikudCSV = @lipikstr, user = _user
    WHERE isikukood = _ik;
END;;
DELIMITER ;
