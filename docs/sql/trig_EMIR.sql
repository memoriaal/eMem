DELIMITER ;;

CREATE OR REPLACE TRIGGER EMIR_AU AFTER UPDATE ON EMIR FOR EACH ROW
BEGIN

    DECLARE msg VARCHAR(200);

    -- Isikukoodi muutmine pole lubatud
    IF NEW.id != OLD.id
    THEN
        SELECT 'EMI ID muutmine ei tule kõne alla!' INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.ts <> OLD.ts 
    THEN  
        INSERT IGNORE INTO z_queue (emi_id, task)
        VALUES (NEW.id, 'Consolidate EMI records');
    END IF;

END;;


CREATE OR REPLACE TRIGGER EMIR_BI BEFORE INSERT ON EMIR FOR EACH ROW
BEGIN
    SET NEW.user = user();
END;;


CREATE OR REPLACE TRIGGER EMIR_BD BEFORE DELETE ON EMIR FOR EACH ROW
BEGIN

    UPDATE kirjed
    SET emi_id = NULL
    WHERE emi_id = OLD.id;

END;;

DELIMITER ;
