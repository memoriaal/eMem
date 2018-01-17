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
        INSERT IGNORE INTO z_queue (emi_id, task, user)
        VALUES (NEW.id, 'Consolidate EMI records', 'EMIR_AU');
    END IF;

END;;


CREATE OR REPLACE TRIGGER EMIR_BI BEFORE INSERT ON EMIR FOR EACH ROW
BEGIN
    SET NEW.user = user();
END;;


CREATE OR REPLACE TRIGGER EMIR_BU BEFORE UPDATE ON EMIR FOR EACH ROW
BEGIN
    SET NEW.perenimi = IFNULL(NEW.perenimi, '');
    SET NEW.eesnimi = IFNULL(NEW.eesnimi, '');
    SET NEW.isanimi = IFNULL(NEW.isanimi, '');
    SET NEW.sünd = IFNULL(NEW.sünd, '');
    SET NEW.surm = IFNULL(NEW.surm, '');
    SET NEW.kommentaarid = IFNULL(NEW.kommentaarid, '');
END;;


CREATE OR REPLACE TRIGGER EMIR_BD BEFORE DELETE ON EMIR FOR EACH ROW
BEGIN

    UPDATE kirjed
    SET emi_id = NULL
    WHERE emi_id = OLD.id;

END;;

DELIMITER ;
