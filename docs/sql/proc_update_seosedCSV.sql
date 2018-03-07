DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE update_seosedCSV(IN _ik CHAR(10))
BEGIN
    SET @connstr = NULL;
    SELECT GROUP_CONCAT(conn SEPARATOR '\n') INTO @connstr
    FROM
    (
        SELECT connection2string(s2.isikukood2, s2.seos, s2.isikukood1, ' --> ') AS conn
        FROM seosed s2
        WHERE s2.isikukood2 = _ik
        UNION
        SELECT connection2string(s1.isikukood1, s1.seos, s1.isikukood2, ' <-- ') AS conn
        FROM seosed s1
        WHERE s1.isikukood1 = _ik
    ) c
    GROUP BY '';

    UPDATE kirjed SET seosedCSV = @connstr
    WHERE isikukood = _ik;
END;;
DELIMITER ;
