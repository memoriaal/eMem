DELIMITER ;;
CREATE OR REPLACE FUNCTION connection2string(
    _ik1 CHAR(10),
    _seos VARCHAR(50),
    _ik2 CHAR(10),
    _direction CHAR(6)
) RETURNS varchar(100) CHARSET utf8
BEGIN
    SELECT count(1) INTO @cnt
    FROM seoseliigid
    WHERE seoseliik = _seos AND seoseliik_1X = _seos;
    IF @cnt = 1 THEN
        RETURN CONCAT(IFNULL(_ik1, ''), ' <= ', _seos, ' => ', _ik2);
    ELSE
        RETURN CONCAT(IFNULL(_ik1, ''), _direction, IFNULL(_seos, 'N/A'), _direction, _ik2);
    END IF;
END;;

