DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `propagate_checklist`(IN _ik1 CHAR(10), IN _ik2 CHAR(10), IN _user VARCHAR(50))
BEGIN
    DECLARE kivi1, mittekivi1, rel1, mr1 enum('', '!');
    DECLARE kivi2, mittekivi2, rel2, mr2 enum('', '!');

    -- CALL validate_checklist(_ik1, _ik2, _user);

    SELECT kivi, mittekivi, rel, mr
      INTO kivi1, mittekivi1, rel1, mr1
      FROM kirjed WHERE isikukood = _ik1;

    SELECT kivi, mittekivi, rel, mr
      INTO kivi2, mittekivi2, rel2, mr2
      FROM kirjed WHERE isikukood = _ik2;

    IF kivi1 != kivi2 OR mittekivi1 != mittekivi2 OR rel1 != rel2 OR mr1 != mr2
    THEN
        UPDATE kirjed
        SET kivi=kivi1, mittekivi = mittekivi1, rel = rel1, mr = mr1, user = _user
        WHERE isikukood = _ik2;
    END IF;

END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `propagate_checklists`(IN _ik1 CHAR(10), IN _user VARCHAR(50))
BEGIN
    DECLARE _ik2 CHAR(10);
    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT isikukood2 FROM seosed WHERE isikukood1 = _ik1 AND seos = 'sama isik';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _ik2;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;
        INSERT IGNORE INTO `z_queue` (`isikukood1`, `isikukood2`, `task`,                user)
        VALUES                       (_ik1,         _ik2,         'Propagate checklist', _user);

    END LOOP;
    CLOSE cur1;
    SET finished = 0;
END;;
DELIMITER ;
