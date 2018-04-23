
DELIMITER ;;

CREATE OR REPLACE TRIGGER kirjelipikud_AU AFTER UPDATE ON kirjelipikud FOR EACH ROW

BEGIN
  -- IF NEW.lipik IS NOT NULL
  -- THEN
  --   INSERT IGNORE INTO z_queue (isikukood1, task, params, user)
  --   VALUES (NEW.kirjekood, 'Update lipik', NEW.lipik, NEW.user);
  -- END IF;
END;;

DELIMITER ;
