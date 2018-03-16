DELIMITER ;;

CREATE OR REPLACE TRIGGER rahvastikuregister_BU BEFORE UPDATE ON rahvastikuregister FOR EACH ROW
BEGIN
  IF NEW.seos is not null AND OLD.seos != new.seos THEN
    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, user)
    VALUES (NEW.kirjekood, NEW.seos, 'Import from RR', user());
  END IF;
END;;

DELIMITER ;
