DELIMITER ;;
CREATE OR REPLACE PROCEDURE repis.backup_table(in tn VARCHAR(50))
BEGIN
	SET @dt = REPLACE(REPLACE(REPLACE(NOW(), '-', '_'), ' ', '_'), ':', '_');

	SET @c = CONCAT('CREATE TABLE backups.`', @dt, '_', tn, '` SELECT * FROM ', tn);
	PREPARE stmt from @c;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END;;
DELIMITER ;


DELIMITER ;;
CREATE OR REPLACE PROCEDURE repis.backup()
BEGIN
	CALL backup_table('kirjed');
	CALL backup_table('v_kirjelipikud');
	CALL backup_table('v_kirjesildid');
END;;
DELIMITER ;

CREATE OR REPLACE EVENT repis.backup
    ON SCHEDULE EVERY 1 day STARTS '2017-11-19 02:00:00'
    ON COMPLETION PRESERVE ENABLE
    DO CALL repis.backup();

ALTER EVENT repis.backup DISABLE;
ALTER EVENT repis.backup ENABLE;
SET GLOBAL event_scheduler=OFF;
SET GLOBAL event_scheduler=ON;

call repis.backup();
