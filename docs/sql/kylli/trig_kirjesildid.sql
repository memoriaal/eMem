
DELIMITER ;;

CREATE OR REPLACE TRIGGER kirjesildid_AU AFTER UPDATE ON kirjesildid FOR EACH ROW

BEGIN
  -- IF NEW.silt IS NOT NULL
  -- THEN
  --   INSERT IGNORE INTO z_queue (isikukood1, task, params, user)
  --   VALUES (NEW.kirjekood, 'Update silt', NEW.silt, NEW.user);
  -- END IF;
END;;

DELIMITER ;
