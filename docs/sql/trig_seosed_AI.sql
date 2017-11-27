DELIMITER ;;
CREATE OR REPLACE TRIGGER seosed_AI AFTER INSERT ON seosed FOR EACH ROW BEGIN

    DECLARE msg VARCHAR(200);

    INSERT INTO z_queue SET task = 'process connection', params = NEW.id;

END;;
DELIMITER ;
