DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `synchronize_checklist`(IN ik1 CHAR(10), IN ik2 CHAR(10), IN _user VARCHAR(50))
proc_label:BEGIN
    DECLARE kivi1, mittekivi1, rel1, mr1 enum('', '!');
    DECLARE kivi2, mittekivi2, rel2, mr2 enum('', '!');

    CALL validate_checklist(ik1, ik2, _user);

    SELECT kivi, mittekivi, rel, mr
      INTO kivi1, mittekivi1, rel1, mr1
      FROM kirjed WHERE isikukood = ik1;

    IF @kivi1 IS NULL
    THEN
        LEAVE proc_label;
    END IF;

    SELECT kivi, mittekivi, rel, mr
      INTO kivi2, mittekivi2, rel2, mr2
      FROM kirjed WHERE isikukood = ik2;

    IF @kivi2 IS NULL
    THEN
        LEAVE proc_label;
    END IF;

    IF kivi1 = '!' THEN
        SET @_kivi = kivi1;
    ELSE
        SET @_kivi = kivi2;
    END IF;

    IF mittekivi1 = '!' THEN
        SET @_mittekivi = mittekivi1;
    ELSE
        SET @_mittekivi = mittekivi2;
    END IF;

    IF rel1 = '!' THEN
        SET @_rel = rel1;
    ELSE
        SET @_rel = rel2;
    END IF;

    IF mr1 = '!' THEN
        SET @_mr = mr1;
    ELSE
        SET @_mr = mr2;
    END IF;

    UPDATE kirjed
    SET kivi = @_kivi, mittekivi = @_mittekivi, rel = @_rel, mr = @_mr, user = _user
    WHERE isikukood in (ik1, ik2);

END;;
DELIMITER ;
