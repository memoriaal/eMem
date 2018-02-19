
DELIMITER ;;

CREATE OR REPLACE TRIGGER kirjesildid_AU AFTER UPDATE ON kirjesildid FOR EACH ROW 

BEGIN
  IF NEW.kustutada = 1 
  THEN
    INSERT IGNORE INTO z_queue (isikukood1, task, params, user)
    VALUES (NEW.kirjekood, 'Remove label', NEW.silt, NEW.user);
  END IF;
END;;

DELIMITER ;


