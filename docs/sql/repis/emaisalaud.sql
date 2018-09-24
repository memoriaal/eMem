
--
-- Emaisalaud
--
CREATE TABLE `emadisad` (
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `ema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `isa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuisa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (`persoon`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


CREATE TABLE `emaisalaud` (
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `ema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `isa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuisa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`persoon`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- Triggers
--
DELIMITER ;; -- emaisalaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.emaisalaud_BI BEFORE INSERT ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF NEW.persoon IS NULL THEN
      SELECT concat_ws('\n'
        , 'Alusta persooni koodiga'
        , USER()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    SET NEW.kirjed = repis.func_persoonikirjed(NEW.persoon);

    SELECT ema INTO @ema FROM repis.emadisad WHERE persoon = NEW.persoon;
    SELECT isa INTO @isa FROM repis.emadisad WHERE persoon = NEW.persoon;
    SELECT kasuema INTO @kasuema FROM repis.emadisad WHERE persoon = NEW.persoon;
    SELECT kasuisa INTO @kasuisa FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.ema = @ema;
    SET NEW.isa = @isa;
    SET NEW.kasuema = @kasuema;
    SET NEW.kasuisa = @kasuisa;

    IF NEW.ema IS NOT NULL THEN
      SET NEW.emakirjed = repis.func_persoonikirjed(NEW.ema);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.ema,     NULL,          'add2emaisa', 'ema',   'magic');
    END IF;
    IF NEW.isa IS NOT NULL THEN
      SET NEW.isakirjed = repis.func_persoonikirjed(NEW.isa);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.isa,     NULL,          'add2emaisa', 'isa',   'magic');
    END IF;
    IF NEW.kasuema IS NOT NULL THEN
      SET NEW.kasuemakirjed = repis.func_persoonikirjed(NEW.kasuema);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.kasuema,     NULL,      'add2emaisa', 'kasuema',   'magic');
    END IF;
    IF NEW.kasuisa IS NOT NULL THEN
      SET NEW.kasuisakirjed = repis.func_persoonikirjed(NEW.kasuisa);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.kasuisa,     NULL,      'add2emaisa', 'kasuisa',   'magic');
    END IF;

    IF NEW.created_by IS NULL THEN
      SET NEW.created_by = USER();
    END IF;

  END;;

DELIMITER ;


--
-- Procedures
--

DELIMITER ;; -- emaisa_add

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_add(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    INSERT INTO repis.emaisalaud (persoon, created_by)
    VALUES (_kirjekood1, _created_by);

  END;;

DELIMITER ;
