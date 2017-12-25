DELIMITER ;;

CREATE OR REPLACE TRIGGER kirjed_BU BEFORE UPDATE ON kirjed FOR EACH ROW 

BEGIN

    DECLARE msg VARCHAR(200);

    -- Isikukoodi muutmine pole lubatud
    IF NEW.isikukood != OLD.isikukood
    THEN
        SELECT 'Isikukoodi muutmine ei tule kõne alla!' INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF !ISNULL(NEW.seos)
    THEN
        IF NEW.seoseliik IS NULL or NEW.seoseliik = 'sama isik'
        THEN
            SET NEW.seoseliik = '';
            CALL validate_checklist(NEW.isikukood, NEW.seos);
            INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
            VALUES (NEW.isikukood, NEW.seos, 'create connections', NEW.seoseliik, 'kirjed_BU');

        ELSEIF NEW.seoseliik = '-'
        THEN
            SET NEW.seoseliik = '';
            CALL remove_connection(NEW.isikukood, NEW.seos);

        ELSEIF NEW.seoseliik = '!'
        THEN
            SET NEW.seoseliik = '';
            INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
            VALUES (NEW.isikukood, NEW.seos, 'create connections', NEW.seoseliik, 'kirjed_BU');

        ELSE
            INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
            VALUES (NEW.isikukood, NEW.seos, 'create connections', NEW.seoseliik, 'kirjed_BU');
        END IF;

        SET NEW.seos = NULL;
        SET NEW.seoseliik = NULL;
    END IF;

    -- Kivi ja Mittekivi välistavad teineteist
    IF NEW.kivi = '!' AND NEW.mittekivi = '!' AND NEW.attn = ''
    THEN
        SELECT CONCAT( NEW.isikukood,
            ': KIVI ja MITTEKIVI ei saa korraga olla!' ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    -- Kivi ja MR välistavad teineteist
    IF NEW.kivi = '!' AND NEW.MR = '!' AND NEW.attn = ''
    THEN
        SELECT CONCAT( NEW.isikukood,
            ': KIVI ja MR ei saa korraga olla!' ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    -- Kivi ja Mittekivi välistavad teineteist
    IF NEW.kivi != OLD.kivi AND NEW.kivi = '!'
    THEN
        SET NEW.mittekivi = '';
        SET NEW.rel = '!';
        SET NEW.mr = '';
    END IF;

    IF NEW.mittekivi = '!' AND OLD.mittekivi = ''
    THEN
        SET NEW.kivi = '';
    END IF;

    -- MR ja REL välistavad teineteist
    IF NEW.rel = '!' AND OLD.rel = ''
    THEN
        SET NEW.mr = '';
    END IF;

    IF NEW.mr = '!' AND OLD.mr = ''
    THEN
        SET NEW.rel = '';
        SET NEW.mittekivi = '!';
        SET NEW.kivi = '';
    END IF;

    IF NEW.kivi != OLD.kivi
    OR NEW.mittekivi != OLD.mittekivi
    OR NEW.mr != OLD.mr
    OR NEW.rel != OLD.rel
    THEN
        SELECT count(1) into @cnt FROM seosed WHERE isikukood1 = NEW.isikukood AND seos = 'sama isik';
        IF @cnt > 0 THEN
            INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
            VALUES (NEW.isikukood, null, 'propagate checklists', '', 'kirjed_BU');
        END IF;
    END IF;

    SET NEW.user = user();
END;;


CREATE OR REPLACE TRIGGER kirjed_AU AFTER UPDATE ON kirjed FOR EACH ROW 

begin

  IF OLD.isikukood <> NEW.isikukood
     OR OLD.Attn <> NEW.Attn
     OR OLD.Kirje <> NEW.Kirje
     OR OLD.Huk <> NEW.Huk
     OR OLD.REL <> NEW.REL
     OR OLD.MR <> NEW.MR
     OR OLD.Kivi <> NEW.Kivi
     OR OLD.Mittekivi <> NEW.Mittekivi
     OR OLD.Perenimi <> NEW.Perenimi
     OR OLD.Eesnimi <> NEW.Eesnimi
     OR OLD.Isanimi <> NEW.Isanimi
     OR OLD.Sünd <> NEW.Sünd
     OR OLD.Surm <> NEW.Surm
     OR OLD.Märksõna <> NEW.Märksõna
     OR OLD.Kommentaar <> NEW.Kommentaar
     OR OLD.Rahvus <> NEW.Rahvus
     OR OLD.Perekood <> NEW.Perekood
     OR OLD.Allikas <> NEW.Allikas
     OR OLD.sugu <> NEW.sugu
     OR OLD.Nimekiri <> NEW.Nimekiri
     OR OLD.EkslikKanne <> NEW.EkslikKanne
     OR OLD.created <> NEW.created
     OR OLD.updated <> NEW.updated
     OR OLD.user <> NEW.user
      THEN
        INSERT INTO kirjed_audit_log 
           (isikukood, Attn, Kirje
           , Huk, REL, MR, Kivi, Mittekivi
           , Perenimi, Eesnimi, Isanimi, Sünd, Surm
           , Märksõna, Kommentaar
           , Rahvus, Perekood, Allikas, sugu, Nimekiri, EkslikKanne
           , created, updated, user)
        VALUES
          (NEW.isikukood, NEW.Attn, NEW.Kirje
          , NEW.Huk, NEW.REL, NEW.MR, NEW.Kivi, NEW.Mittekivi
          , NEW.Perenimi, NEW.Eesnimi, NEW.Isanimi, NEW.Sünd, NEW.Surm
          , NEW.Märksõna, NEW.Kommentaar
          , NEW.Rahvus, NEW.Perekood, NEW.Allikas, NEW.sugu, NEW.Nimekiri, NEW.EkslikKanne
          , NEW.created, NEW.updated, NEW.user);

        INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
        VALUES (NEW.isikukood, NULL, 'Check EMI record', '', 'kirjed_AU');
  END IF;
end;;


CREATE OR REPLACE TRIGGER kirjed_BI BEFORE INSERT ON kirjed FOR EACH ROW 
BEGIN

  SET NEW.user = user();

END;;


CREATE OR REPLACE TRIGGER kirjed_AI AFTER INSERT ON kirjed FOR EACH ROW 
BEGIN

INSERT INTO kirjed_audit_log 
     (isikukood, Attn, Kirje
     , Huk, REL, MR, Kivi, Mittekivi
     , Perenimi, Eesnimi, Isanimi, Sünd, Surm
     , Märksõna, Kommentaar
     , Rahvus, Perekood, Allikas, sugu, Nimekiri, EkslikKanne
     , created, updated, user)
  VALUES
    (NEW.isikukood, NEW.Attn, NEW.Kirje
    , NEW.Huk, NEW.REL, NEW.MR, NEW.Kivi, NEW.Mittekivi
    , NEW.Perenimi, NEW.Eesnimi, NEW.Isanimi, NEW.Sünd, NEW.Surm
    , NEW.Märksõna, NEW.Kommentaar
    , NEW.Rahvus, NEW.Perekood, NEW.Allikas, NEW.sugu, NEW.Nimekiri, NEW.EkslikKanne
    , NEW.created, NEW.updated, NEW.user);

END;;

DELIMITER ;
