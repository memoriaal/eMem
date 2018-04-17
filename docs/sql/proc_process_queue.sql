DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE process_queue()
proc_label:BEGIN
    DECLARE _id INT(11) UNSIGNED;
    DECLARE _emi_id INT(11) UNSIGNED;
    DECLARE _ik1 CHAR(10);
    DECLARE _ik2 CHAR(10);
    DECLARE _task VARCHAR(30);
    DECLARE _params VARCHAR(200);
    DECLARE _user VARCHAR(50);
    DECLARE _created TIMESTAMP;
    DECLARE finished INTEGER DEFAULT 0;
    DECLARE msg VARCHAR(200);

    DECLARE cur1 CURSOR FOR
        SELECT id, emi_id, isikukood1, isikukood2, task, params, created, user
        FROM z_queue WHERE rdy = 0
        LIMIT 130;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;

    SELECT count(1) INTO @pcnt FROM INFORMATION_SCHEMA.PROCESSLIST
    WHERE User = 'queue';
    IF @pcnt > 1
    THEN
        LEAVE proc_label;
    END IF;


    OPEN cur1;
    read_loop: LOOP
        -- LEAVE read_loop;
        FETCH cur1 INTO _id, _emi_id, _ik1, _ik2, _task, _params, _created, _user;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        UPDATE z_queue SET rdy = rdy + 1 WHERE id = _id;

        -- IF _params LIKE '%validate_checklist%'   THEN
        --     CALL validate_checklist(           _ik1, _ik2,                    _user);
        -- END IF;
        IF _task = 'Propagate checklist'         THEN
            CALL propagate_checklist(          _ik1, _ik2,                    _user);
        END IF;
        IF _task = 'Propagate checklists'        THEN
            CALL propagate_checklists(         _ik1,                          _user);
        END IF;
        IF _task = 'Synchronize checklist'       THEN
            CALL synchronize_checklist(        _ik1, _ik2,                    _user);
        END IF;
        IF _task = 'Process connection'          THEN
            CALL process_connection(                                 _params, _user);
        END IF;
        IF _task = 'Create connections'          THEN
            CALL create_connections(           _ik1, _ik2,           _params, _user);
        END IF;
        IF _task = 'Remove connection'           THEN
            CALL remove_connection(            _ik1, _ik2,                    _user);
        END IF;
        IF _task = 'Remove record'               THEN
            CALL remove_record(                _ik1,                          _user);
        END IF;
        IF _task = 'Refresh NK'                 THEN
            CALL NK_refresh(                                _emi_id,          _user);
        END IF;
        IF _task = 'Check EMI record'            THEN
            CALL EMI_check_record(             _ik1,                 _params, _user);
        END IF;
        IF _task = 'Create EMI reference'        THEN
            CALL EMI_create_ref_for(                        _emi_id, _params, _user);
        END IF;
        IF _task = 'Consolidate EMI records'     THEN
            CALL EMI_consolidate_records(                   _emi_id, _user);
        END IF;
        IF _task = 'Update seosedCSV'            THEN
            -- UPDATE z_queue SET rdy = 100 WHERE id = _id;
            CALL update_seosedCSV(             _ik1,                          _user);
        END IF;
        IF _task = 'Import from RK'              THEN
            CALL import_from_rk(               _ik1,                          _user);
        END IF;
        IF _task = 'Import from RR'              THEN
            CALL import_from_rr(               _ik1,                          _user);
        END IF;
        IF _task = 'Import from pereregister'    THEN
            CALL import_from_pereregister(     _ik1, _ik2,                    _user);
        END IF;
        -- IF _task = 'Import from hävituspataljon' THEN
        --     CALL import_from_hävituspataljon(  _ik1, _ik2,                    _user);
        -- END IF;
        IF _task = 'Rollback prior to'           THEN
            CALL rollback_prior_to(            _ik1,                 _params, _user);
        END IF;
        IF _task = 'Update label'                THEN
            CALL update_label(                 _ik1,                 _params, _user);
        END IF;
        -- IF _task = 'Remove label' THEN
        --     CALL remove_label(_ik1, _params, _user);
        -- END IF;

        DELETE FROM z_queue WHERE id = _id and rdy = 1;
        -- UPDATE z_queue SET rdy = rdy + 1 WHERE id = _id;
        --  WHERE ifnull(emi_id, 0) = ifnull(_emi_id, 0)
        --    AND ifnull(isikukood1, '') = ifnull(_ik1, '')
        --    AND ifnull(isikukood2, '') = ifnull(_ik2, '')
        --    AND task = _task
        --    AND params = _params;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;
DELIMITER ;

ALTER EVENT `process_queue` DISABLE;
SET GLOBAL event_scheduler=OFF;

CREATE OR REPLACE EVENT `process_queue`
    ON SCHEDULE EVERY 1 SECOND STARTS '2017-11-19 01:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL process_queue();

SET GLOBAL event_scheduler=ON;

-- call process_queue();
