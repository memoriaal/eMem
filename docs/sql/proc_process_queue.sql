DELIMITER ;;
CREATE OR REPLACE PROCEDURE process_queue()
BEGIN
    DECLARE _id INT(11) UNSIGNED;
    DECLARE _ik1 CHAR(10);
    DECLARE _ik2 CHAR(10);
    DECLARE _task VARCHAR(20);
    DECLARE _params VARCHAR(200);
    DECLARE _created TIMESTAMP;
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE msg VARCHAR(200);

    DECLARE cur1 CURSOR FOR
        SELECT id, isikukood1, isikukood2, task, params, created
        FROM z_queue WHERE rdy = 0
        LIMIT 30;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    OPEN cur1;
    read_loop: LOOP
        FETCH cur1 INTO _id, _ik1, _ik2, _task, _params, _created;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        IF _params LIKE '%validate_checklist%' THEN
            CALL validate_checklist(_ik1, _ik2);
        END IF;
        IF _task = 'propagate checklist' THEN
            CALL propagate_checklist(_ik1, _ik2);
        END IF;
        IF _task = 'sunchronize checklist' THEN
            CALL synchronize_checklist(_ik1, _ik2);
        END IF;
        IF _task = 'propagate checklists' THEN
            CALL propagate_checklists(_ik1);
        END IF;
        IF _task = 'process connection' THEN
            CALL process_connection(_params);
        END IF;
        IF _task = 'create connections' THEN
            CALL create_connections(_ik1, _params, _ik2);
        END IF;
        IF _task = 'Check EMI record' THEN
            CALL EMI_check_record(_ik1);
        END IF;
        IF _task = 'update seosedCSV' THEN
            -- UPDATE kirjed SET seosedCSV = '' WHERE isikukood = _params;
            CALL update_seosedCSV(_ik1);
        END IF;

        -- SELECT concat('foo:', ifnull(_id, 'NA'), ' ', ifnull(_created, 'NA'), ' ', ifnull(_ik1, 'NA'), ' ', ifnull(_ik2, 'NA')) INTO msg;
        -- SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        UPDATE z_queue SET rdy = 1 WHERE id = _id;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;
DELIMITER ;

CREATE OR REPLACE EVENT `process_queue`
    ON SCHEDULE EVERY 1 SECOND STARTS '2017-11-19 01:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL process_queue();
