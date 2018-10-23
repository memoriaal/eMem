
--
-- Emaisalaud
--
CREATE OR REPLACE TABLE `emadisad` (
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `ema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `isa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `abikaasa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuisa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  `updated_by` varchar(40) COLLATE utf8_estonian_ci NOT NULL DEFAULT '-',
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`persoon`),
  KEY `ema` (`ema`),
  KEY `isa` (`isa`),
  KEY `abikaasa` (`abikaasa`),
  KEY `kasuema` (`kasuema`),
  KEY `kasuisa` (`kasuisa`),
  CONSTRAINT `emadisad_ibfk_1` FOREIGN KEY (`persoon`) REFERENCES `kirjed` (`kirjekood`),
  -- CONSTRAINT `emadisad_ibfk_2` FOREIGN KEY (`ema`) REFERENCES `kirjed` (`kirjekood`),
  -- CONSTRAINT `emadisad_ibfk_3` FOREIGN KEY (`isa`) REFERENCES `kirjed` (`kirjekood`),
  CONSTRAINT `emadisad_ibfk_4` FOREIGN KEY (`abikaasa`) REFERENCES `kirjed` (`kirjekood`),
  CONSTRAINT `emadisad_ibfk_5` FOREIGN KEY (`kasuema`) REFERENCES `kirjed` (`kirjekood`),
  CONSTRAINT `emadisad_ibfk_6` FOREIGN KEY (`kasuisa`) REFERENCES `kirjed` (`kirjekood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE `emaisalaud` (
  `A` enum('','Valmis') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `ema` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `isa` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `abikaasa` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `kasuema` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `kasuisa` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `emakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `isakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `abikaasakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuisakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuemakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (`persoon`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- alglähtestame emad-isad
--
  DELETE FROM repis.emadisad WHERE updated_by = '-';

  INSERT IGNORE INTO repis.emadisad (`persoon`, `ema`, `isa`, `abikaasa`, `kasuema`, `kasuisa`, `updated_at`)
  -- SELECT kirjekood, repis.emadisad_next_id('E'), repis.emadisad_next_id('I'), NULL, NULL, NULL, NULL FROM repis.kirjed
  SELECT kirjekood, NULL, NULL, NULL, NULL, NULL, NULL FROM repis.kirjed
  WHERE persoon = kirjekood;

-- R6

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND k2.sugu = 'N'                  -- EMA
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.ema=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND k2.sugu = 'N'                  -- EMA
    AND rk.allikas LIKE 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuema=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND k2.sugu = 'M' -- ISA
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.isa=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND k2.sugu = 'M' -- ISA
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuisa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (ema), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.ema=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuema), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuema=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (isa), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.isa=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuisa), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuisa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (abikaasa), ')
    AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
    AND rk.allikas like 'R6-%'
    AND RIGHT(rk.kirjekood, 2) != '00'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.abikaasa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

-- R5

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND k2.sugu = 'N' -- EMA
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.ema=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND k2.sugu = 'N' -- EMA
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuema=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND k2.sugu = 'M' -- ISA
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.isa=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS laps, k2.persoon AS vanem
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND k2.sugu = 'M' -- ISA
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuisa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (ema), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.ema=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuema), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuema=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (isa), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.isa=k3.vanem
  WHERE ei.updated_by = '-'
  ;
  UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuisa), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.kasuisa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

UPDATE repis.emadisad ei
  RIGHT JOIN (
    SELECT rk.persoon AS vanem, k2.persoon AS laps
    FROM repis.kirjed rk
    LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
    WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (abikaasa), ')
    AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
    AND rk.allikas like 'R5'
    AND RIGHT(rk.kirjekood, 2) != '01'
  ) AS k3 ON ei.persoon = k3.laps
  SET ei.abikaasa=k3.vanem
  WHERE ei.updated_by = '-'
  ;

DELETE FROM repis.counter WHERE id IN ('I', 'E');


--
-- Triggers
--
DELIMITER ;; -- emaisalaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_BI BEFORE INSERT ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF IFNULL(NEW.persoon, '') = '' THEN
      SELECT concat_ws('\n'
        , 'Alusta persooni koodiga'
        , USER()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.created_by IS NULL THEN
      SET NEW.created_by = USER();
    END IF;

    SET NEW.kirjed = repis.func_persoonikirjed(NEW.persoon);

    SELECT ema INTO @ema FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.ema = IFNULL(@ema, '');
    IF NEW.ema != '' THEN
      SET NEW.emakirjed = repis.func_persoonikirjed(NEW.ema);
    END IF;

    SELECT isa INTO @isa FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.isa = IFNULL(@isa, '');
    IF NEW.isa != '' THEN
      SET NEW.isakirjed = repis.func_persoonikirjed(NEW.isa);
    END IF;

    SELECT abikaasa INTO @abikaasa FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.abikaasa = IFNULL(@abikaasa, '');
    IF NEW.abikaasa != '' THEN
      SET NEW.abikaasakirjed = repis.func_persoonikirjed(NEW.abikaasa);
    END IF;

    SELECT kasuema INTO @kasuema FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.kasuema = IFNULL(@kasuema, '');
    IF NEW.kasuema != '' THEN
      SET NEW.kasuemakirjed = repis.func_persoonikirjed(NEW.kasuema);
    END IF;

    SELECT kasuisa INTO @kasuisa FROM repis.emadisad WHERE persoon = NEW.persoon;
    SET NEW.kasuisa = IFNULL(@kasuisa, '');
    IF NEW.kasuisa != '' THEN
      SET NEW.kasuisakirjed = repis.func_persoonikirjed(NEW.kasuisa);
    END IF;

  END;;

DELIMITER ;

DELIMITER ;; -- emaisalaud_AI

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_AI AFTER INSERT ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,                 params, created_by)
    VALUES                           (NEW.persoon, NULL,       'raamatupere2emaisa', '',     NEW.created_by);

    if NEW.ema != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.ema,     NULL,          'add2emaisa', 'ema',   NEW.created_by);
    END IF;
    if NEW.isa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.isa,     NULL,          'add2emaisa', 'isa',   NEW.created_by);
    END IF;
    if NEW.abikaasa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,    task,         params,     created_by)
      VALUES                           (NEW.abikaasa, NULL,          'add2emaisa', 'abikaasa', NEW.created_by);
    END IF;
    IF NEW.kasuema != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.kasuema,     NULL,      'add2emaisa', 'kasuema',   NEW.created_by);
    END IF;
    IF NEW.kasuisa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,         params, created_by)
      VALUES                           (NEW.kasuisa,     NULL,      'add2emaisa', 'kasuisa',   NEW.created_by);
    END IF;

    INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2, task, params, created_by)
    SELECT ei.persoon AS kirjekood1, NULL AS kirjekood2, 'add2emaisa' AS task, '' AS params, NEW.created_by AS created_by
      FROM repis.emadisad ei
     WHERE NEW.persoon IN (ei.ema, ei.isa, ei.abikaasa, ei.kasuema, ei.kasuisa);

  END;;

DELIMITER ;

DELIMITER ;; -- emaisalaud_BU

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_BU BEFORE UPDATE ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF NEW.persoon != OLD.persoon THEN
      SELECT concat_ws('\n'
        , 'Foo! \n Ära muuda siin persooni koodi!'
        , USER()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.ema = OLD.persoon OR NEW.isa = OLD.persoon OR NEW.abikaasa = OLD.persoon OR
       NEW.kasuema = OLD.persoon OR NEW.kasuisa = OLD.persoon THEN
      SELECT concat_ws('\n'
        , 'Foo! \n Ei ole enda laps ju!'
        , USER()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.ema = 'E' THEN
      SET NEW.ema = repis.emadisad_next_id('E');
    END IF;
    IF NEW.isa = 'I' THEN
      SET NEW.isa = repis.emadisad_next_id('I');
    END IF;

    SET NEW.emakirjed = repis.func_persoonikirjed(NEW.ema);
    SET NEW.isakirjed = repis.func_persoonikirjed(NEW.isa);
    SET NEW.abikaasakirjed = repis.func_persoonikirjed(NEW.abikaasa);
    SET NEW.kasuemakirjed = repis.func_persoonikirjed(NEW.kasuema);
    SET NEW.kasuisakirjed = repis.func_persoonikirjed(NEW.kasuisa);

  END;;

DELIMITER ;

DELIMITER ;; -- emaisalaud_AU

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_AU AFTER UPDATE ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    IF NEW.ema != OLD.ema OR NEW.isa != OLD.isa OR NEW.abikaasa != OLD.abikaasa OR
       NEW.kasuema != OLD.kasuema OR NEW.kasuisa != OLD.kasuisa THEN
          INSERT INTO repis.emadisad (persoon, ema, isa, abikaasa, kasuema, kasuisa, updated_by)
            VALUES (NEW.persoon, NEW.ema, NEW.isa, NEW.abikaasa, NEW.kasuema, NEW.kasuisa, NEW.created_by)
          ON DUPLICATE KEY UPDATE
            ema = if(NEW.ema = '', NULL, NEW.ema),
            isa = if(NEW.isa = '', NULL, NEW.isa),
            abikaasa = if(NEW.abikaasa = '', NULL, NEW.abikaasa),
            kasuema = if(NEW.kasuema = '', NULL, NEW.kasuema),
            kasuisa = if(NEW.kasuisa = '', NULL, NEW.kasuisa),
            updated_by = NEW.created_by;
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                 params,   created_by)
      VALUES                           (OLD.ema,     NEW.ema,       'emaisalaud_replace', '',       NEW.created_by);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                 params,   created_by)
      VALUES                           (OLD.isa,     NEW.isa,       'emaisalaud_replace', '',       NEW.created_by);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                 params,   created_by)
      VALUES                           (OLD.abikaasa,NEW.abikaasa,  'emaisalaud_replace', '',       NEW.created_by);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                 params,   created_by)
      VALUES                           (OLD.kasuema, NEW.kasuema,   'emaisalaud_replace', '',       NEW.created_by);
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                 params,   created_by)
      VALUES                           (OLD.kasuisa, NEW.kasuisa,   'emaisalaud_replace', '',       NEW.created_by);

    END IF;

    IF NEW.A = 'Valmis' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2, task,               params, created_by)
      VALUES                           (NULL,       NULL,       'emaisalaud_flush', '',     'emaisalaud_BU');
    END IF;

  END;;

DELIMITER ;


--
-- Procedures
--

DELIMITER ;; -- q_emaisa_raamatupere

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_raamatupere(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    INSERT IGNORE INTO repis.emaisalaud (persoon, created_by)
    SELECT DISTINCT k1.persoon, _created_by
    FROM repis.kirjed k0
    LEFT JOIN repis.kirjed k1 ON k1.raamatupere = k0.raamatupere
    WHERE k0.raamatupere != ''
      AND k0.persoon = _kirjekood1;

  END;;

DELIMITER ;

DELIMITER ;; -- emaisa_add

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_add(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    INSERT IGNORE INTO repis.emaisalaud (persoon, created_by)
    VALUES (_kirjekood1, _created_by);

  END;;

DELIMITER ;

DELIMITER ;; -- emaisa_replace

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_replace(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    IF _kirjekood1 != _kirjekood2 THEN
      DELETE FROM repis.emaisalaud WHERE persoon = _kirjekood1;
      INSERT INTO repis.emaisalaud (persoon, created_by) VALUES (_kirjekood2, _created_by);
    END IF;

  END;;

DELIMITER ;

DELIMITER ;; -- emaisalaud_flush

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisalaud_flush(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    DELETE FROM repis.emaisalaud;

  END;;

DELIMITER ;

DELIMITER ;; -- emadisad_next_id()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.emadisad_next_id(
      _ei CHAR(1)
  ) RETURNS CHAR(8) CHARSET utf8
  func_label:BEGIN
    RETURN concat(_ei, LPAD(repis.func_next_id(_ei), 7, '0'));
  END;;

DELIMITER ;
