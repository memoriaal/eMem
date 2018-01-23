DELIMITER ;;

CREATE OR REPLACE TRIGGER pereregister_BU BEFORE UPDATE ON pereregister FOR EACH ROW
BEGIN
  IF NEW.import = 1 AND OLD.import = 0 THEN
    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, user)
    VALUES (NEW.isikukood, NEW.seos, 'Import from pereregister', user());
  END IF;
END;;

DELIMITER ;
