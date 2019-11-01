CREATE OR REPLACE TABLE repis.z_queue (
  id INT(11) unsigned NOT NULL AUTO_INCREMENT,
  kirjekood1 CHAR(10) NOT NULL DEFAULT '',
  kirjekood2 CHAR(10) NOT NULL DEFAULT '',
  task VARCHAR(50) NOT NULL DEFAULT '',
  params VARCHAR(200) NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  created_by VARCHAR(50) NOT NULL DEFAULT '',
  erred_at timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE current_timestamp(),
  msg VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY `kirjekood1` (`kirjekood1`,`kirjekood2`,`task`,`params`,`erred_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.process_queue()
  proc_label: BEGIN
    DECLARE _id INT(11) UNSIGNED;
    DECLARE _kirjekood1 CHAR(10);
    DECLARE _kirjekood2 CHAR(10);
    DECLARE _task VARCHAR(30);
    DECLARE _params VARCHAR(200);
    DECLARE _created_at TIMESTAMP;
    DECLARE _created_by VARCHAR(50);

    DECLARE finished INTEGER DEFAULT 0;

    -- Declare variables to hold diagnostics area information
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;

    DECLARE cur1 CURSOR FOR
      SELECT id, kirjekood1, kirjekood2, task, params, created_by
      FROM repis.z_queue WHERE erred_at = '0000-00-00 00:00:00'
      -- LIMIT 130
      ;

    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN
        GET DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO z_queue (task, params, erred_at) values (code, msg, now());
      END;

    -- LEAVE proc_label;

    SELECT count(1) INTO @pcnt FROM INFORMATION_SCHEMA.PROCESSLIST
    WHERE User = 'queue';
    IF @pcnt > 1 THEN
      LEAVE proc_label;
    END IF;

    OPEN cur1;
    read_loop: LOOP
      -- LEAVE read_loop;
      FETCH cur1 INTO _id, _kirjekood1, _kirjekood2, _task, _params, _created_by;
      IF finished = 1 THEN
          LEAVE read_loop;
      END IF;

      UPDATE repis.z_queue SET erred_at = now() WHERE id = _id;
      SELECT concat(_id, ': CALL repis.q_', _task, '(\'',_kirjekood1,'\', \'',_kirjekood2,'\', \'',_task,'\', \'',_params,'\', \'',_created_by,'\');');

      IF _task = 'desktop_flush' THEN
        CALL repis.q_desktop_flush(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_collect' THEN
        CALL repis.q_desktop_collect(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_NK_refresh' THEN
        UPDATE repis.z_queue SET msg = concat('CALL repis.q_desktop_NK_refresh(\'',_kirjekood1,'\', \'',_kirjekood2,'\', \'',_task,'\', \'',_params,'\', \'',_created_by,'\');') WHERE id = _id;
        CALL repis.q_desktop_NK_refresh(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_PR_import' THEN
        UPDATE repis.z_queue SET msg = concat('CALL repis.q_desktop_PR_import(\'',_kirjekood1,'\', \'',_kirjekood2,'\', \'',_task,'\', \'',_params,'\', \'',_created_by,'\');') WHERE id = _id;
        CALL repis.q_desktop_PR_import(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_RK_import' THEN
        UPDATE repis.z_queue SET msg = concat('CALL repis.q_desktop_RK_import(\'',_kirjekood1,'\', \'',_kirjekood2,'\', \'',_task,'\', \'',_params,'\', \'',_created_by,'\');') WHERE id = _id;
        CALL repis.q_desktop_RK_import(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_RR_import' THEN
        UPDATE repis.z_queue SET msg = concat('CALL repis.q_desktop_RR_import(\'',_kirjekood1,'\', \'',_kirjekood2,'\', \'',_task,'\', \'',_params,'\', \'',_created_by,'\');') WHERE id = _id;
        CALL repis.q_desktop_RR_import(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'desktop_join_persons' THEN
        CALL repis.q_desktop_join_persons(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'leidperelaud_collect' THEN
        CALL repis.q_leidperelaud_collect(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'leidperelaud_flush' THEN
        CALL repis.q_leidperelaud_flush(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'perelaud_flush' THEN
        CALL repis.q_perelaud_flush(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'emaisalaud_flush' THEN
        CALL repis.q_emaisalaud_flush(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'add2emaisa' THEN
        CALL repis.q_emaisa_add(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'raamatupere2emaisa' THEN
        CALL repis.q_emaisa_raamatupere(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      ELSEIF _task = 'emaisalaud_replace' THEN
        CALL repis.q_emaisa_replace(_kirjekood1, _kirjekood2, _task, _params, _created_by);
        -- DELETE FROM repis.z_queue WHERE id = _id;
      END IF;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

  END;;
DELIMITER ;


CREATE OR REPLACE DEFINER=queue@localhost EVENT repis.process_queue
    ON SCHEDULE EVERY 1 SECOND STARTS '2017-11-19 01:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL repis.process_queue();

ALTER EVENT repis.process_queue ENABLE;
ALTER EVENT repis.process_queue DISABLE;
SET GLOBAL event_scheduler=ON;
-- SET GLOBAL event_scheduler=OFF;

-- call repis.process_queue();
