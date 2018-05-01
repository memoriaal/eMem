CREATE OR REPLACE TABLE repis.z_queue (
  id INT(11) unsigned NOT NULL AUTO_INCREMENT,
  kirjekood1 CHAR(10) NOT NULL DEFAULT '',
  kirjekood2 CHAR(10) NOT NULL DEFAULT '',
  task VARCHAR(50) NOT NULL DEFAULT '',
  params VARCHAR(200) NOT NULL DEFAULT '',
  created_at TIMESTAMP NOT NULL DEFAULT current_timestamp(),
  created_by VARCHAR(50) NOT NULL DEFAULT '',
  erred_at timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  msg VARCHAR(100) DEFAULT NULL,
  PRIMARY KEY (id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


DELIMITER ;;
CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.process_queue()
proc_label:BEGIN
    DECLARE _id INT(11) UNSIGNED;
    DECLARE _kirjekood1 CHAR(10);
    DECLARE _kirjekood2 CHAR(10);
    DECLARE _task VARCHAR(30);
    DECLARE _params VARCHAR(200);
    DECLARE _created_at TIMESTAMP;
    DECLARE _created_by VARCHAR(50);

    DECLARE finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT id, kirjekood1, kirjekood2, task, params, created_by
        FROM repis.z_queue WHERE erred_at IS NULL
        -- LIMIT 130
        ;
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
        FETCH cur1 INTO _id, _kirjekood1, _kirjekood2, _task, _params, _created_by;
        IF finished = 1 THEN
            LEAVE read_loop;
        END IF;

        UPDATE repis.z_queue SET msg = 'errored' WHERE id = _id;

        IF _task = 'desktop_flush' THEN
            CALL repis.q_desktop_flush(_kirjekood1, _kirjekood2, _task, _params, _created_by);
            DELETE FROM repis.z_queue WHERE id = _id;
        END IF;
        IF _task = 'desktop_collect' THEN
            CALL repis.q_desktop_collect(_kirjekood1, _kirjekood2, _task, _params, _created_by);
            DELETE FROM repis.z_queue WHERE id = _id;
        END IF;

    END LOOP;
    CLOSE cur1;
    SET finished = 0;

END;;
DELIMITER ;


CREATE OR REPLACE EVENT repis.process_queue
    ON SCHEDULE EVERY 1 SECOND STARTS '2017-11-19 01:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL repis.process_queue();

ALTER EVENT repis.process_queue ENABLE;
ALTER EVENT repis.process_queue DISABLE;
SET GLOBAL event_scheduler=ON;
-- SET GLOBAL event_scheduler=OFF;

INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('NK-0091094', '', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');

INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('', 'NK-0091094', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');

-- call repis.process_queue();
