DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `validate_checklist`(IN _ik1 CHAR(10), IN _ik2 CHAR(10), IN _user VARCHAR(50))
BEGIN
    DECLARE kivi1, mittekivi1, attn1, rel1, mr1 enum('', '!');
    DECLARE kivi2, mittekivi2, attn2, rel2, mr2 enum('', '!');
    DECLARE msg VARCHAR(200);

    SELECT emi_id, kivi, mittekivi, attn, rel, mr
      INTO @eid1, kivi1, mittekivi1, attn1, rel1, mr1
      FROM kirjed WHERE isikukood = _ik1;
    SELECT emi_id, kivi, mittekivi, attn, rel, mr
      INTO @eid2, kivi2, mittekivi2, attn2, rel2, mr2
      FROM kirjed WHERE isikukood = _ik2;

    IF attn1 = '' OR attn2 = '' THEN
        IF kivi1 = '!' AND mittekivi2 = '!' THEN
            SELECT CONCAT( 'Kirjed (', IFNULL(@eid1,''), ',', IFNULL(@eid2,''), '); \'', 
                IFNULL(_ik1,''), '\',\'', IFNULL(_ik2,''), '\' konfliktivad, sest ',
                IFNULL(_ik2,''), ' on MITTEKIVI, ',
                IFNULL(_ik1,''), ' on KIVI' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        ELSEIF kivi2 = '!' AND mittekivi1 = '!' THEN
            SELECT CONCAT( 'Kirjed (', IFNULL(@eid1,''), ',', IFNULL(@eid2,''), '); \'',
                IFNULL(_ik1,''), '\',\'', IFNULL(_ik2,''), '\' konfliktivad, sest ',
                IFNULL(_ik1,''), ' on MITTEKIVI, aga ',
                IFNULL(_ik2,''), ' on KIVI.' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;

        ELSEIF kivi1 = '!' AND mr2 = '!' THEN
            SELECT CONCAT( 'Kirjed (', IFNULL(@eid1,''), ',', IFNULL(@eid2,''), '); \'',
                IFNULL(_ik1,''), '\',\'', IFNULL(_ik2,''), '\' konfliktivad, sest ',
                IFNULL(_ik1,''), ' on KIVI, aga ',
                IFNULL(_ik2,''), ' on MR.' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        ELSEIF kivi2 = '!' AND mr1 = '!' THEN
            SELECT CONCAT( 'Kirjed (', IFNULL(@eid1,''), ',', IFNULL(@eid2,''), '); \'',
                IFNULL(_ik1,''), '\',\'', IFNULL(_ik2,''), '\' konfliktivad, sest ',
                IFNULL(_ik1,''), ' on MR, aga ',
                IFNULL(_ik2,''), ' on KIVI.' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;

        ELSEIF rel1 = '!' AND mr2 = '!' THEN
            SELECT CONCAT( 'Kirjed (', @eid1, ',', @eid2, '); \'', _ik1, '\',\'', _ik2, '\' konfliktivad, sest ',
                _ik1, ' on REL, aga ', _ik2, ' on MR.' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        ELSEIF rel2 = '!' AND mr1 = '!' THEN
            SELECT CONCAT( 'Kirjed (', @eid1, ',', @eid2, '); \'', _ik1, '\',\'', _ik2, '\' konfliktivad, sest ',
                _ik1, ' on MR, aga ', _ik2, ' on REL.' ) INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        END IF;
    END IF;
END;;
DELIMITER ;
