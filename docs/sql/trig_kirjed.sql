DELIMITER ;;

CREATE OR REPLACE TRIGGER kirjed_BU BEFORE UPDATE ON kirjed FOR EACH ROW 

proc_label:BEGIN

    DECLARE msg VARCHAR(200);

    SET NEW.user = user();

    -- Isikukoodi muutmine pole lubatud
    IF NEW.isikukood != OLD.isikukood
    THEN
        IF NEW.user = 'michelek@localhost'
        THEN
            LEAVE proc_label;
        ELSE
            SELECT 'Isikukoodi muutmine ei tule kõne alla!' INTO msg;
            SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        END IF;
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
    IF NEW.kivi = '!' AND OLD.kivi = ''
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
             (   isikukood, emi_id, Kirje
               , Kivi, Mittekivi, SaatusTeadmata, Puudulik
               , Kommentaar, Attn, REL, MR
               , Perenimi, Eesnimi, Isanimi, Sünd, Surm
               , Märksõna, Rahvus, Perekood, Allikas, Sugu
               , Nimekiri, EkslikKanne, Huk
               , created, updated, user)
          VALUES
            (   NEW.isikukood, NEW.emi_id, NEW.Kirje
              , NEW.Kivi, NEW.Mittekivi, NEW.SaatusTeadmata, NEW.Puudulik
              , NEW.Kommentaar, NEW.Attn, NEW.REL, NEW.MR
              , NEW.Perenimi, NEW.Eesnimi, NEW.Isanimi, NEW.Sünd, NEW.Surm
              , NEW.Märksõna, NEW.Rahvus, NEW.Perekood, NEW.Allikas, NEW.Sugu
              , NEW.Nimekiri, NEW.EkslikKanne, NEW.Huk
              , NEW.created, NEW.updated, NEW.user);

        INSERT IGNORE INTO z_queue (isikukood1, isikukood2, task, params, user)
        VALUES (NEW.isikukood, NULL, 'Check EMI record', OLD.emi_id, 'kirjed_AU');
  END IF;
  
  IF OLD.emi_id <> NEW.emi_id
    THEN
      INSERT IGNORE INTO z_queue (emi_id, isikukood1, isikukood2, task, params, user)
      VALUES (OLD.emi_id, NULL, NULL, 'Create EMI reference', NEW.emi_id, 'kirjed_AU');
  END IF;
end;;


CREATE OR REPLACE TRIGGER kirjed_BI BEFORE INSERT ON kirjed FOR EACH ROW 
BEGIN

  SET NEW.user = user();
  
  IF UPPER(IFNULL(NEW.isikukood, '')) IN ('', 'TEST')
  THEN
      SELECT right(max(isikukood), 5)+1 INTO @ik FROM kirjed WHERE allikas = 'TEST';
      SET @ik = IFNULL(@ik, 0);
      SET @ik = LPAD(@ik, 5, 0);
      SET NEW.isikukood = concat('TEST-', @ik);
      SET NEW.allikas = 'TEST';
  ELSEIF UPPER(NEW.isikukood) = 'EMI'
  THEN
      SELECT right(max(isikukood), 6)+1 INTO @ik FROM kirjed WHERE allikas = 'EMI';
      SET @ik = IFNULL(@ik, 0);
      SET @ik = LPAD(@ik, 6, 0);
      SET NEW.isikukood = concat('EMI-', @ik);
      SET NEW.allikas = 'EMI';
  ELSEIF UPPER(NEW.isikukood) = 'TS'
  THEN
      SELECT right(max(isikukood), 7)+1 INTO @ik FROM kirjed WHERE allikas = 'TS';
      SET @ik = IFNULL(@ik, 0);
      SET @ik = LPAD(@ik, 7, 0);
      SET NEW.isikukood = concat('TS-', @ik);
      SET NEW.allikas = 'TS';
  END IF;

END;;


CREATE OR REPLACE TRIGGER kirjed_AI AFTER INSERT ON kirjed FOR EACH ROW 
BEGIN

    INSERT INTO kirjed_audit_log 
         (   isikukood, emi_id, Kirje
           , Kivi, Mittekivi, SaatusTeadmata, Puudulik
           , Kommentaar, Attn, REL, MR
           , Perenimi, Eesnimi, Isanimi, Sünd, Surm
           , Märksõna, Rahvus, Perekood, Allikas, Sugu
           , Nimekiri, EkslikKanne, Huk
           , created, updated, user)
      VALUES
        (   NEW.isikukood, NEW.emi_id, NEW.Kirje
          , NEW.Kivi, NEW.Mittekivi, NEW.SaatusTeadmata, NEW.Puudulik
          , NEW.Kommentaar, NEW.Attn, NEW.REL, NEW.MR
          , NEW.Perenimi, NEW.Eesnimi, NEW.Isanimi, NEW.Sünd, NEW.Surm
          , NEW.Märksõna, NEW.Rahvus, NEW.Perekood, NEW.Allikas, NEW.Sugu
          , NEW.Nimekiri, NEW.EkslikKanne, NEW.Huk
          , NEW.created, NEW.updated, NEW.user);

END;;

DELIMITER ;
