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
