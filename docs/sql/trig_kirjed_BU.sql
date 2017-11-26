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
        RETURN CONCAT(_ik1, ' <=> ', _ik2);
    ELSE
        RETURN CONCAT( _ik1, _direction, IFNULL(_seos, 'N/A'), _direction, _ik2);
    END IF;
END;;


CREATE OR REPLACE TRIGGER kirjed_BU BEFORE UPDATE ON kirjed FOR EACH ROW BEGIN

    DECLARE msg VARCHAR(200);

    -- Isikukoodi muutmine pole lubatud
    IF NEW.isikukood != OLD.isikukood
    THEN
        SELECT 'Isikukoodi muutmine ei tule kõne alla!' INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF !ISNULL(NEW.seos)
    THEN
        IF NEW.seoseliik = '' or NEW.seoseliik = 'sama isik'
        THEN
            SET NEW.seoseliik = '';
            CALL validate_checklist(NEW.isikukood, NEW.seos);
            CALL create_connections(NEW.isikukood, NEW.seoseliik, NEW.seos);

        ELSEIF NEW.seoseliik = '-'
        THEN
            SET NEW.seoseliik = '';
            CALL remove_connection(NEW.isikukood, NEW.seos);

        ELSEIF NEW.seoseliik = '!'
        THEN
            SET NEW.seoseliik = '';
            CALL create_connections(NEW.isikukood, NEW.seoseliik, NEW.seos);

        ELSE
            CALL create_connections(NEW.isikukood, NEW.seoseliik, NEW.seos);
        END IF;

        SET NEW.seos = NULL;
        SET NEW.seoseliik = NULL;
        SET NEW.seosedCSV = '';
    END IF;

    IF NEW.seosedCSV = ''
    THEN
        SELECT group_concat(foo.seos separator '\n')
        FROM (
            SELECT connection2string( s2.isikukood2, s2.seos, s2.isikukood1, ' --> ') AS seos
            FROM seosed s2
            WHERE s2.isikukood2 = OLD.isikukood
            UNION
            SELECT connection2string( s1.isikukood1, s1.seos, s1.isikukood2, ' <-- ') AS seos
            FROM seosed s1
            WHERE s1.isikukood1 = OLD.isikukood
        ) foo INTO @seosedCSV;
        SET NEW.seosedCSV = @seosedCSV;
        IF NEW.seosedCSV = ''
        THEN
            SET NEW.seosedCSV = NULL;
        END IF;
    END IF;

    -- Kivi ja Mittekivi välistavad teineteist
    IF NEW.kivi = '!' AND NEW.mittekivi = '!' AND NEW.attn = ''
    THEN
        SELECT CONCAT( NEW.isikukood,
            ': KIVI ja MITTEKIVI ei saa korraga olla!' ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    -- Kivi ja MR välistavad teineteist
    IF NEW.kivi = '!' AND NEW.MR = '!' AND NEW.attn = ''
    THEN
        SELECT CONCAT( NEW.isikukood,
            ': KIVI ja MR ei saa korraga olla!' ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    -- Kivi ja Mittekivi välistavad teineteist
    IF NEW.kivi != OLD.kivi AND NEW.kivi = '!'
    THEN
        SET NEW.mittekivi = '';
        SET NEW.rel = '!';
        SET NEW.mr = '';
    END IF;

    IF NEW.mittekivi = '!' AND OLD.mittekivi = ''
    THEN
        SET NEW.kivi = '';
    END IF;

    -- MR ja REL välistavad teineteist
    IF NEW.rel = '!' AND OLD.rel = ''
    THEN
        SET NEW.mr = '';
    END IF;

    IF NEW.mr = '!' AND OLD.mr = ''
    THEN
        SET NEW.rel = '';
        SET NEW.mittekivi = '!';
        SET NEW.kivi = '';
    END IF;

    IF NEW.kivi != OLD.kivi
    OR NEW.mittekivi != OLD.mittekivi
    OR NEW.mr != OLD.mr
    OR NEW.rel != OLD.rel
    THEN
        SELECT count(1) into @cnt FROM seosed WHERE isikukood1 = NEW.isikukood AND seos = 'sama isik';
        IF @cnt > 0 THEN
            INSERT INTO z_queue (isikukood1, isikukood2, task, params, user)
            VALUES (NEW.isikukood, null, 'propagate checklists', '', user());
        END IF;
    END IF;

    SET NEW.user = user();
END;;
DELIMITER ;
