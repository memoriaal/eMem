DELIMITER ;;
CREATE OR REPLACE TRIGGER seosed_AI AFTER INSERT ON seosed FOR EACH ROW BEGIN

    DECLARE msg VARCHAR(200);

    INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
    VALUES (NULL, NULL, 'process connection', NEW.id, 'seosed_AI');

    -- INSERT INTO z_queue SET task = 'process connection', params = NEW.id, ;

END;;
DELIMITER ;
