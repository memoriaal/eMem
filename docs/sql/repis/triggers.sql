--
-- Kirjed Triggers
--
DELIMITER ;;

  --
  -- kirjed_BI
  --
  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.kirjed_BI
  BEFORE INSERT ON repis.kirjed FOR EACH ROW
    proc_label:BEGIN

    DECLARE msg VARCHAR(2000);

    IF NEW.created_by != SUBSTRING_INDEX(user(), '@', 1)
       AND NEW.created_by != 'michelek@localhost' THEN
      SELECT concat_ws(user(), '\n'
        , 'Kirjeid saab lisada ainult töölaualt.'
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;
  END;;

  --
  -- kirjed_BU
  --
  -- CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.kirjed_BU
  -- BEFORE UPDATE ON repis.kirjed FOR EACH ROW
  --   proc_label:BEGIN
  --
  --   DECLARE msg VARCHAR(2000);
  --
  --   IF user() NOT IN ('kylli.localhost', 'michelek@localhost') THEN
  --
  --     IF NEW.kommentaar != OLD.kommentaar THEN
  --       SET NEW.persoon = OLD.persoon
  --         , NEW.kirjekood = OLD.kirjekood
  --         , NEW.perenimi = OLD.perenimi
  --         , NEW.eesnimi = OLD.eesnimi
  --         , NEW.isanimi = OLD.isanimi
  --         , NEW.emanimi = OLD.emanimi
  --         , NEW.sünd = OLD.sünd
  --         , NEW.surm = OLD.surm
  --         , NEW.updated_at = now()
  --         , NEW.updated_by = SUBSTRING_INDEX(user(), '@', 1);
  --     ELSE
  --       IF NEW.updated_by != SUBSTRING_INDEX(user(), '@', 1) THEN
  --         SELECT concat_ws('\n'
  --           , 'Kirjeid saab muuta ainult töölaual.'
  --         ) INTO msg;
  --         SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
  --       END IF;
  --     END IF;
  --   END IF;
  -- END;;


  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.kirjed_BU
  BEFORE UPDATE ON repis.kirjed FOR EACH ROW
    proc_label:BEGIN

    DECLARE msg VARCHAR(2000);

    IF current_user() NOT IN ('michelek@localhost', 'queue@localhost') THEN
      SELECT concat_ws(current_user(), '\n'
        , 'Kirjeid saab muuta ainult töölaual.'
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.allikas = 'EMI' THEN
      SET NEW.kirje = concat_ws('. ',
                                if(NEW.KirjePersoon = '', NULL, NEW.KirjePersoon),
                                if(NEW.kirjeJutt = '', NULL, NEW.kirjeJutt));
    END IF;

    IF NEW.allikas = 'TS' THEN
      SET NEW.kirje = concat_ws('. ',
                                if(NEW.KirjePersoon = '', NULL, NEW.KirjePersoon),
                                if(NEW.kirjeJutt = '', NULL, NEW.kirjeJutt));
    END IF;

  END;;

DELIMITER ;



--
-- Triggers
--
DELIMITER ;; -- repis.kirjed_AI
  CREATE OR REPLACE TRIGGER repis.kirjed_AI AFTER INSERT ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(NEW.persoon);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.kirjed_AU
  CREATE OR REPLACE TRIGGER repis.kirjed_AU AFTER UPDATE ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(OLD.persoon);
    CALL repis.aggr_kirjed(NEW.persoon);
    CALL repis.aggr_lipikud(OLD.persoon);
    CALL repis.aggr_lipikud(NEW.persoon);
    CALL repis.aggr_sildid(OLD.persoon);
    CALL repis.aggr_sildid(NEW.persoon);
    CALL repis.aggr_persoonid(OLD.persoon);
    CALL repis.aggr_persoonid(NEW.persoon);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.kirjed_AD
  CREATE OR REPLACE TRIGGER repis.kirjed_AD AFTER DELETE ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(OLD.persoon);
    CALL repis.aggr_lipikud(OLD.persoon);
    CALL repis.aggr_sildid(OLD.persoon);
  END;;
DELIMITER ;


DELIMITER ;; -- repis.v_kirjesildid_AI
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AI AFTER INSERT ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_sildid(NEW.kirjekood);
    CALL repis.aggr_persoonid(NEW.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjesildid_AU
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AU AFTER UPDATE ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_sildid(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjesildid_AD
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AD AFTER DELETE ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;


DELIMITER ;; -- repis.v_kirjelipikud_AI
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AI AFTER INSERT ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(NEW.kirjekood);
    CALL repis.aggr_persoonid(NEW.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjelipikud_AU
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AU AFTER UPDATE ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjelipikud_AD
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AD AFTER DELETE ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;



DROP TRIGGER repis.kirjed_AI;
DROP TRIGGER repis.kirjed_AU;
DROP TRIGGER repis.kirjed_AD;
DROP TRIGGER repis.v_kirjesildid_AI;
DROP TRIGGER repis.v_kirjesildid_AU;
DROP TRIGGER repis.v_kirjesildid_AD;
DROP TRIGGER repis.v_kirjelipikud_AI;
DROP TRIGGER repis.v_kirjelipikud_AU;
DROP TRIGGER repis.v_kirjelipikud_AD;
