DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_label(IN _ik CHAR(10), IN _label VARCHAR(50), IN _user VARCHAR(50))
BEGIN
    INSERT INTO kirjesildid
    SET kirjekood = _ik, silt = _label
    ON DUPLICATE KEY UPDATE kustutatud = mod(kustutatud+1,2);

    SET @labelstr = NULL;
    SELECT GROUP_CONCAT(concat(silt, ' - ', _user, '@', now()) SEPARATOR '; \n') INTO @labelstr
    FROM kirjesildid
    WHERE kirjekood = _ik
    AND kustutatud = 0
    GROUP BY _ik;

    UPDATE kirjed SET sildidCSV = @labelstr, user = _user
    WHERE isikukood = _ik;
END;;
DELIMITER ;

-- 
-- DELIMITER ;;
-- CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE remove_label(IN _ik CHAR(10), IN _label VARCHAR(50), IN _user VARCHAR(50))
-- BEGIN
--     DELETE FROM kirjesildid
--     WHERE kirjekood = _ik AND silt = _label;
-- 
--     SET @labelstr = NULL;
--     SELECT GROUP_CONCAT(silt SEPARATOR '; ') INTO @labelstr
--     FROM kirjesildid
--     WHERE kirjekood = _ik
--     GROUP BY _ik;
-- 
--     UPDATE kirjed SET sildidCSV = @labelstr, user = _user
--     WHERE isikukood = _ik;
-- END;;
-- DELIMITER ;
