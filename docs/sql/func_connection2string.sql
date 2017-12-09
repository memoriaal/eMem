DELIMITER ;;
CREATE OR REPLACE FUNCTION connection2string(
    _ik1 CHAR(10),
    _seos VARCHAR(50),
    _ik2 CHAR(10),
    _direction VARCHAR(6)
) RETURNS varchar(100) CHARSET utf8
BEGIN
    IF _seos = 'erinevad isikud' THEN
        RETURN CONCAT(_ik1, ' != ', _ik2);
    ELSEIF _seos = 'kahtlusseos' THEN
        RETURN CONCAT(_ik1, ' ?= ', _ik2);
    ELSEIF _seos = 'sama isik' THEN
        RETURN CONCAT(_ik1, ' == ', _ik2);
    ELSE
        SELECT count(1) INTO @cnt
        FROM seoseliigid
        WHERE seoseliik = _seos AND seoseliik_1X = _seos;
        IF @cnt = 1 THEN
            RETURN CONCAT(_ik1, ' <= ', _seos, ' => ', _ik2);
        ELSE
            RETURN CONCAT(_ik1, ' ', _direction, ' ', _seos, ' ', _direction, ' ', _ik2);
        END IF;
    END IF;
END;;
DELIMITER ;
