DELIMITER ;;
CREATE OR REPLACE TRIGGER seosed_AI AFTER INSERT ON seosed FOR EACH ROW BEGIN

    DECLARE msg VARCHAR(200);

    INSERT IGNORE INTO z_queue (task, params, user)
    VALUES ('Process connection', NEW.id, NEW.user);

END;;
DELIMITER ;
