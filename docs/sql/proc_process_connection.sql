DELIMITER ;;

CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE set_sex_from_connection(IN _id INT(11) UNSIGNED)
BEGIN
    DECLARE msg VARCHAR(200);

    SELECT s.isikukood1, k1.sugu, s.isikukood2, k2.sugu,
           sl1.seoseliik, sl1.sugu, sl2.seoseliik, sl2.sugu,
           sl1.sugu_1, sl1.seoseliik_1M, sl1.seoseliik_1N, sl1.seoseliik_1X
        INTO @ik1, @ksugu1, @ik2, @ksugu2,
             @sl1, @ssugu1, @sl2, @ssugu2,
             @ssugu1_1, @sl1M, @sl1N, @sl1X
    FROM seosed s 
    LEFT JOIN kirjed k1 ON k1.isikukood = s.isikukood1
    LEFT JOIN kirjed k2 ON k2.isikukood = s.isikukood2
    LEFT JOIN seoseliigid sl1 ON sl1.seoseliik = s.seos
    LEFT JOIN seoseliigid sl2 ON sl2.seoseliik = s.vastasseos
    WHERE s.id = _id;

    IF @ksugu1 != '' AND @ssugu1 != '' AND @ksugu1 != @ssugu1 THEN
        SELECT concat(@ik1, ' on "', IFNULL(@ksugu1, ''), '"; ei sobi "', @sl1, '".') INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;
    IF @ksugu2 != '' AND @ssugu2 != '' AND @ksugu2 != @ssugu2 THEN
        SELECT concat(@ik2, ' on "', IFNULL(@ksugu2, ''), '"; ei sobi "', @sl2, '".') INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;
    IF @ksugu1 = '' AND @ssugu1 != '' THEN
        UPDATE kirjed SET sugu = @ssugu1 WHERE isikukood = @ik1;
    END IF;
    IF @ksugu2 = '' AND @ssugu2 != '' THEN
        UPDATE kirjed SET sugu = @ssugu2 WHERE isikukood = @ik2;
    END IF;
    IF @ksugu1 != '' AND @ssugu1_1 = '=' THEN
        UPDATE kirjed SET sugu = @ksugu1 WHERE isikukood = @ik2;
    END IF;
    IF @ksugu2 != '' AND @ssugu1_1 = '=' THEN
        UPDATE kirjed SET sugu = @ksugu2 WHERE isikukood = @ik1;
    END IF;
    IF @ksugu1 = 'M' AND @ssugu1_1 = 'X' THEN
        UPDATE kirjed SET sugu = 'N' WHERE isikukood = @ik2;
    END IF;
    IF @ksugu1 = 'N' AND @ssugu1_1 = 'X' THEN
        UPDATE kirjed SET sugu = 'M' WHERE isikukood = @ik2;
    END IF;
END;;

CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE process_connection(IN _id INT(11) UNSIGNED)
BEGIN
    DECLARE msg VARCHAR(200);

    CALL set_sex_from_connection(_id);

    SELECT s.isikukood1, k1.sugu, s.isikukood2, k2.sugu,
           sl1.seoseliik, sl1.sugu, sl2.seoseliik, sl2.sugu, 
           sl1.sugu_1, sl1.seoseliik_1M, sl1.seoseliik_1N, sl1.seoseliik_1X,
           sl2.sugu_1, sl2.seoseliik_1M, sl2.seoseliik_1N, sl2.seoseliik_1X
        INTO @ik1, @ksugu1, @ik2, @ksugu2,
             @sl1, @ssugu1, @sl2, @ssugu2, 
             @ssugu1_1, @sl1M, @sl1N, @sl1X,
             @ssugu2_1, @sl2M, @sl2N, @sl2X
    FROM seosed s 
    LEFT JOIN kirjed k1 ON k1.isikukood = s.isikukood1
    LEFT JOIN kirjed k2 ON k2.isikukood = s.isikukood2
    LEFT JOIN seoseliigid sl1 ON sl1.seoseliik = s.seos
    LEFT JOIN seoseliigid sl2 ON sl2.seoseliik = s.vastasseos
    WHERE s.id = _id;

    IF @ik1 IS NULL OR @ik2 IS NULL THEN
        SELECT concat('Katkine seos, ID: ', _id, '.') INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF @sl1 IS NULL AND @sl2 IS NULL THEN
        SELECT concat(@ik1, ' ja ', @ik2, ' on määramata seoses.') INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;
    
    IF @sl2 IS NULL THEN
        IF     @ssugu1_1 = 'M' OR @ksugu2 = 'M' THEN
            UPDATE seosed SET vastasseos = @sl1M WHERE id = _id;
        ELSEIF @ssugu1_1 = 'N' OR @ksugu2 = 'N' THEN
            UPDATE seosed SET vastasseos = @sl1N WHERE id = _id;
        ELSEIF @ssugu1_1 = '=' AND @ksugu1 = 'M' THEN
            UPDATE seosed SET vastasseos = @sl1M WHERE id = _id;
        ELSEIF @ssugu1_1 = '=' AND @ksugu1 = 'N' THEN
            UPDATE seosed SET vastasseos = @sl1N WHERE id = _id;
        ELSEIF @ssugu1_1 = 'X' AND @ksugu1 = 'M' THEN
            UPDATE seosed SET vastasseos = @sl1N WHERE id = _id;
        ELSEIF @ssugu1_1 = 'X' AND @ksugu1 = 'N' THEN
            UPDATE seosed SET vastasseos = @sl1M WHERE id = _id;
        ELSEIF @ssugu1_1 IS NULL THEN
            IF     @ksugu2 = 'M' THEN
                UPDATE seosed SET vastasseos = @sl1M WHERE id = _id;
            ELSEIF @ksugu2 = 'N' THEN
                UPDATE seosed SET vastasseos = @sl1N WHERE id = _id;
            ELSEIF @ksugu2 = '' THEN
                UPDATE seosed SET vastasseos = @sl1X WHERE id = _id;
            END IF;
        END IF;
    END IF;

    IF @sl1 IS NULL THEN
        IF     @ssugu2_1 = 'M' OR @ksugu1 = 'M' THEN
            UPDATE seosed SET seos = @sl2M WHERE id = _id;
        ELSEIF @ssugu2_1 = 'N' OR @ksugu1 = 'N' THEN
            UPDATE seosed SET seos = @sl2N WHERE id = _id;
        ELSEIF @ssugu2_1 = '=' AND @ksugu1 = 'M' THEN
            UPDATE seosed SET seos = @sl2M WHERE id = _id;
        ELSEIF @ssugu2_1 = '=' AND @ksugu1 = 'N' THEN
            UPDATE seosed SET seos = @sl2N WHERE id = _id;
        ELSEIF @ssugu2_1 = 'X' AND @ksugu1 = 'M' THEN
            UPDATE seosed SET seos = @sl2N WHERE id = _id;
        ELSEIF @ssugu2_1 = 'X' AND @ksugu1 = 'N' THEN
            UPDATE seosed SET seos = @sl2M WHERE id = _id;
        ELSEIF @ssugu2_1 IS NULL THEN
            IF     @ksugu1 = 'M' THEN
                UPDATE seosed SET seos = @sl2M WHERE id = _id;
            ELSEIF @ksugu1 = 'N' THEN
                UPDATE seosed SET seos = @sl2N WHERE id = _id;
            ELSEIF @ksugu1 = '' THEN
                UPDATE seosed SET seos = @sl2X WHERE id = _id;
            END IF;
        END IF;
    END IF;
    
    CALL set_sex_from_connection(_id);
    
END;;
DELIMITER ;

