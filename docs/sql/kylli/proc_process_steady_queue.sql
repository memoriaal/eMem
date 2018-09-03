DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE process_steady_queue()
proc_label:BEGIN
    DECLARE _id INT(11) UNSIGNED;
    DECLARE _emi_id INT(11) UNSIGNED;
    DECLARE _ik1 CHAR(10);
    DECLARE _ik2 CHAR(10);
    DECLARE _task VARCHAR(30);
    DECLARE _params VARCHAR(200);
    DECLARE _created TIMESTAMP;
    DECLARE _user VARCHAR(50);

    DECLARE q_max INT(5) UNSIGNED;
    DECLARE q_add INT(5) UNSIGNED;

    DECLARE finished INTEGER DEFAULT 0;
    DECLARE msg VARCHAR(200);

    DECLARE cur1 CURSOR FOR
        SELECT id, emi_id, isikukood1, isikukood2, task, params, created, user
        FROM z_queue_steady
        ;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET finished = 1;
    SET q_max = 500;
    SET q_add = 5;

    SELECT count(1) INTO @qcnt FROM z_queue;

    OPEN cur1;
    read_loop: LOOP

        IF @qcnt >= q_max
        THEN
            LEAVE proc_label;
        END IF;

        IF q_add = 0
        THEN
            LEAVE proc_label;
        END IF;

        FETCH cur1 INTO _id, _emi_id, _ik1, _ik2, _task, _params, _created, _user;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        INSERT INTO z_queue(id, emi_id, isikukood1, isikukood2, task, params, created, user)
        SELECT NULL, _emi_id, _ik1, _ik2, _task, _params, _created, _user;

        DELETE FROM z_queue_steady WHERE id = _id;
        SET @qcnt = @qcnt + 1;
        SET q_add = q_add - 1;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;

CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE process_from_steady_queue(IN _lim INT(10) UNSIGNED)
proc_label:BEGIN

  SET @rdy = 101;

  UPDATE z_queue_b SET rdy = @rdy LIMIT _lim;

  INSERT INTO z_queue(id, emi_id, isikukood1, isikukood2, task, params, created, user)
  SELECT NULL, emi_id, isikukood1, isikukood2, task, params, created, user
  FROM z_queue_b
  LIMIT _lim;

  DELETE FROM z_queue_b WHERE rdy = @rdy;

END;;


DELIMITER ;

CREATE OR REPLACE EVENT `process_steady_queue`
    ON SCHEDULE EVERY 1 SECOND STARTS '2017-11-19 01:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL process_steady_queue();

SET GLOBAL event_scheduler=ON;
