
--
-- Emaisalaud
--

-- CREATE OR REPLACE TABLE `emadisad` (
--   `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   `ema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
--   `isa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
--   `abikaasa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
--   `kasuema` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
--   `kasuisa` char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
--   `updated_by` varchar(40) COLLATE utf8_estonian_ci NOT NULL DEFAULT '-',
--   `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
--   PRIMARY KEY (`persoon`),
--   KEY `ema` (`ema`),
--   KEY `isa` (`isa`),
--   KEY `abikaasa` (`abikaasa`),
--   KEY `kasuema` (`kasuema`),
--   KEY `kasuisa` (`kasuisa`),
--   CONSTRAINT `emadisad_ibfk_1` FOREIGN KEY (`persoon`) REFERENCES `kirjed` (`kirjekood`),
--   -- CONSTRAINT `emadisad_ibfk_2` FOREIGN KEY (`ema`) REFERENCES `kirjed` (`kirjekood`),
--   -- CONSTRAINT `emadisad_ibfk_3` FOREIGN KEY (`isa`) REFERENCES `kirjed` (`kirjekood`),
--   CONSTRAINT `emadisad_ibfk_4` FOREIGN KEY (`abikaasa`) REFERENCES `kirjed` (`kirjekood`),
--   CONSTRAINT `emadisad_ibfk_5` FOREIGN KEY (`kasuema`) REFERENCES `kirjed` (`kirjekood`),
--   CONSTRAINT `emadisad_ibfk_6` FOREIGN KEY (`kasuisa`) REFERENCES `kirjed` (`kirjekood`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE `emaisalaud` (
  `A` enum('','Valmis') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `kirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `ema` varchar(1000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `isa` varchar(1000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `abikaasa` varchar(1000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `kasuema` varchar(1000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `kasuisa` varchar(1000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  `emakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `isakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `abikaasakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuisakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  `kasuemakirjed` varchar(2000) COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (`persoon`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


-- --
-- -- alglähtestame emad-isad
-- --
--   DELETE FROM repis.emadisad WHERE updated_by = '-';
--
--   INSERT IGNORE INTO repis.emadisad (`persoon`, `ema`, `isa`, `abikaasa`, `kasuema`, `kasuisa`, `updated_at`)
--   -- SELECT kirjekood, repis.emadisad_next_id('E'), repis.emadisad_next_id('I'), NULL, NULL, NULL, NULL FROM repis.kirjed
--   SELECT kirjekood, NULL, NULL, NULL, NULL, NULL, NULL FROM repis.kirjed
--   WHERE persoon = kirjekood;
--
-- -- R6
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND k2.sugu = 'N'                  -- EMA
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.ema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND k2.sugu = 'N'                  -- EMA
--     AND rk.allikas LIKE 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND k2.sugu = 'M' -- ISA
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.isa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND k2.sugu = 'M' -- ISA
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuisa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (ema), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.ema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuema), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (isa), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.isa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuisa), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuisa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (abikaasa), ')
--     AND RIGHT(k2.kirjekood, 2) = '00'  -- põhiküüditatu
--     AND rk.allikas like 'R6-%'
--     AND RIGHT(rk.kirjekood, 2) != '00'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.abikaasa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- -- R5
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND k2.sugu = 'N' -- EMA
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.ema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND k2.sugu = 'N' -- EMA
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (poeg|tütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND k2.sugu = 'M' -- ISA
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.isa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS laps, k2.persoon AS vanem
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasupoeg|kasutütar), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND k2.sugu = 'M' -- ISA
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuisa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (ema), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.ema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuema), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuema=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (isa), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.isa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--   UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (kasuisa), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.kasuisa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;
--
-- UPDATE repis.emadisad ei
--   RIGHT JOIN (
--     SELECT rk.persoon AS vanem, k2.persoon AS laps
--     FROM repis.kirjed rk
--     LEFT JOIN repis.kirjed k2 ON rk.raamatupere = k2.raamatupere AND rk.allikas = k2.allikas
--     WHERE rk.kirje REGEXP concat('^\\S* \\S* \\S* (abikaasa), ')
--     AND RIGHT(k2.kirjekood, 2) = '01'  -- põhiküüditatu
--     AND rk.allikas like 'R5'
--     AND RIGHT(rk.kirjekood, 2) != '01'
--   ) AS k3 ON ei.persoon = k3.laps
--   SET ei.abikaasa=k3.vanem
--   WHERE ei.updated_by = '-'
--   ;

DELETE FROM repis.counter WHERE id IN ('I', 'E');


--
-- Triggers
--
DELIMITER ;; -- emaisalaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_BI BEFORE INSERT ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;
    SET @ema = NULL;
    SET @isa = NULL;
    SET @kasuema = NULL;
    SET @kasuisa = NULL;
    SET @abikaasa = NULL;

    IF IFNULL(NEW.persoon, '') = '' THEN
      SELECT concat_ws('\n'
        , 'Alusta persooni koodiga'
        , USER()
        , NEW.created_by
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF NEW.created_by IS NULL THEN
      SET NEW.created_by = USER();
    END IF;

    SET NEW.kirjed = repis.func_persoonikirjed(NEW.persoon);

    SET @s_id = NULL;
    SET @s_kirjed = NULL;

    SELECT group_concat(sugulane SEPARATOR ','),
           group_concat('== ', sugulane, ' ==\n', repis.func_persoonikirjed(sugulane) SEPARATOR '\n')
    INTO @s_id, @s_kirjed
    FROM repis.sugulased
    WHERE persoon = NEW.persoon AND seos = 'ema';
    SET NEW.ema = IFNULL(@s_id, ''), NEW.emakirjed = @s_kirjed;

    SELECT group_concat(sugulane SEPARATOR ','),
           group_concat('== ', sugulane, ' ==\n', repis.func_persoonikirjed(sugulane) SEPARATOR '\n')
    INTO @s_id, @s_kirjed
    FROM repis.sugulased
    WHERE persoon = NEW.persoon AND seos = 'isa';
    SET NEW.isa = IFNULL(@s_id, ''), NEW.isakirjed = @s_kirjed;

    SELECT group_concat(sugulane SEPARATOR ','),
           group_concat('== ', sugulane, ' ==\n', repis.func_persoonikirjed(sugulane) SEPARATOR '\n')
    INTO @s_id, @s_kirjed
    FROM repis.sugulased
    WHERE persoon = NEW.persoon AND seos = 'kasuema';
    SET NEW.kasuema = IFNULL(@s_id, ''), NEW.kasuemakirjed = @s_kirjed;

    SELECT group_concat(sugulane SEPARATOR ','),
           group_concat('== ', sugulane, ' ==\n', repis.func_persoonikirjed(sugulane) SEPARATOR '\n')
    INTO @s_id, @s_kirjed
    FROM repis.sugulased
    WHERE persoon = NEW.persoon AND seos = 'kasuisa';
    SET NEW.kasuisa = IFNULL(@s_id, ''), NEW.kasuisakirjed = @s_kirjed;

    SELECT group_concat(sugulane SEPARATOR ','),
           group_concat('== ', sugulane, ' ==\n', repis.func_persoonikirjed(sugulane) SEPARATOR '\n')
    INTO @s_id, @s_kirjed
    FROM repis.sugulased
    WHERE persoon = NEW.persoon AND seos = 'abikaasa';
    SET NEW.abikaasa = IFNULL(@s_id, ''), NEW.abikaasakirjed = @s_kirjed;

  END;;

DELIMITER ;

DELIMITER ;; -- emaisalaud_AI

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.emaisalaud_AI AFTER INSERT ON repis.emaisalaud FOR EACH ROW
  proc_label:BEGIN

    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,                 params, created_by)
    VALUES                           (NEW.persoon, NULL,       'raamatupere2emaisa', '',     NEW.created_by);

    if NEW.ema != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,         params,      created_by)
      VALUES                           (NULL,        NULL,       'add2emaisa', NEW.ema,     NEW.created_by);
    END IF;
    if NEW.isa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,         params,      created_by)
      VALUES                           (NULL,        NULL,       'add2emaisa', NEW.isa,     NEW.created_by);
    END IF;
    if NEW.abikaasa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,task,         params,      created_by)
      VALUES                           (NULL,        NULL,       'add2emaisa', NEW.abikaasa,NEW.created_by);
    END IF;
    IF NEW.kasuema != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,         params,      created_by)
      VALUES                           (NULL,        NULL,       'add2emaisa', NEW.kasuema, NEW.created_by);
    END IF;
    IF NEW.kasuisa != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,         params,      created_by)
      VALUES                           (NULL,        NULL,       'add2emaisa', NEW.kasuisa, NEW.created_by);
    END IF;

    INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2, task, params, created_by)
    SELECT NULL AS kirjekood1, NULL AS kirjekood2, 'add2emaisa' AS task, persoon AS params, NEW.created_by AS created_by
      FROM repis.sugulased ei
     WHERE ei.sugulane = NEW.persoon;

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
        , 'Foo! \n Ei ole enda sugulane ju!'
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

    IF NEW.ema = '' THEN
      DELETE FROM repis.sugulased
      WHERE seos = 'ema'
        AND sugulane = OLD.ema AND persoon = OLD.persoon;
    END IF;
    IF NEW.isa = '' THEN
      DELETE FROM repis.sugulased
      WHERE seos = 'isa'
        AND sugulane = OLD.isa AND persoon = OLD.persoon;
    END IF;
    IF NEW.kasuema = '' THEN
      DELETE FROM repis.sugulased
      WHERE seos = 'kasuema'
        AND sugulane = OLD.kasuema AND persoon = OLD.persoon;
    END IF;
    IF NEW.kasuisa = '' THEN
      DELETE FROM repis.sugulased
      WHERE seos = 'kasuisa'
        AND sugulane = OLD.kasuisa AND persoon = OLD.persoon;
    END IF;
    IF NEW.abikaasa = '' THEN
      DELETE FROM repis.sugulased
      WHERE seos = 'abikaasa'
        AND (  sugulane IN (SELECT k0.kirjekood FROM repis.kirjed k0 WHERE OLD.abikaasa regexp k0.kirjekood) AND persoon  = OLD.persoon
            OR persoon  IN (SELECT k0.kirjekood FROM repis.kirjed k0 WHERE OLD.abikaasa regexp k0.kirjekood) AND sugulane = OLD.persoon
            );
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

    IF NEW.ema != OLD.ema THEN
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT NEW.persoon, 'ema', k0.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.ema REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,   task,                 params, created_by)
      SELECT k0.kirjekood, k0.kirjekood, 'emaisalaud_replace', '', NEW.created_by
      FROM repis.kirjed k0
      WHERE NEW.ema = k0.kirjekood;
    END IF;
    IF NEW.isa != OLD.isa THEN
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT NEW.persoon, 'isa', k0.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.isa REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,   task,                 params, created_by)
      SELECT k0.kirjekood, k0.kirjekood, 'emaisalaud_replace', '', NEW.created_by
      FROM repis.kirjed k0
      WHERE NEW.isa = k0.kirjekood;
    END IF;
    IF NEW.abikaasa != OLD.abikaasa THEN
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT NEW.persoon, 'abikaasa', k0.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.abikaasa REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT k0.persoon, 'abikaasa', NEW.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.abikaasa REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,   task,                 params, created_by)
      -- VALUES                           (NEW.abikaasa, NEW.abikaasa, 'emaisalaud_replace', '',     NEW.created_by);
      SELECT k0.kirjekood, k0.kirjekood, 'emaisalaud_replace', '', NEW.created_by
      FROM repis.kirjed k0
      WHERE NEW.abikaasa regexp k0.kirjekood OR OLD.abikaasa regexp k0.kirjekood;
    END IF;
    IF NEW.kasuisa != OLD.kasuisa THEN
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT NEW.persoon, 'kasuisa', k0.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.kasuisa REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,   task,                 params, created_by)
      SELECT k0.kirjekood, k0.kirjekood, 'emaisalaud_replace', '', NEW.created_by
      FROM repis.kirjed k0
      WHERE NEW.kasuisa regexp k0.kirjekood;
    END IF;
    IF NEW.kasuema != OLD.kasuema THEN
      INSERT IGNORE INTO repis.sugulased (persoon, seos, sugulane, created_by, created_at)
      SELECT DISTINCT NEW.persoon, 'kasuema', k0.persoon, NEW.created_by, now()
      FROM repis.kirjed k0
      WHERE NEW.kasuema REGEXP k0.persoon;
      --
      INSERT IGNORE INTO repis.z_queue (kirjekood1,   kirjekood2,   task,                 params, created_by)
      SELECT k0.kirjekood, k0.kirjekood, 'emaisalaud_replace', '', NEW.created_by
      FROM repis.kirjed k0
      WHERE NEW.kasuema regexp k0.kirjekood;
    END IF;

    IF NEW.A = 'Valmis' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2, task,               params, created_by)
      VALUES                           (NULL,       NULL,       'emaisalaud_flush', '',     NEW.created_by);
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

DELIMITER ;; -- q_emaisa_add

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_add(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    INSERT IGNORE INTO repis.emaisalaud (persoon, created_by)
    SELECT
      SUBSTRING_INDEX(SUBSTRING_INDEX(foo.sid, ',', numbers.n), ',', -1) AS "s_id", _created_by
    FROM
      (SELECT 1 n UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL
       SELECT 4   UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL
       SELECT 7   UNION ALL SELECT 8 UNION ALL SELECT 9) numbers
    INNER JOIN ( SELECT _params AS sid ) foo
        ON CHAR_LENGTH(foo.sid) - CHAR_LENGTH(REPLACE(foo.sid, ',', '')) >= numbers.n-1
    ORDER BY numbers.n
    ;
  END;;

DELIMITER ;

DELIMITER ;; -- emaisa_replace

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_emaisa_replace(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    -- IF _kirjekood1 != _kirjekood2 THEN
      DELETE FROM repis.emaisalaud WHERE persoon = _kirjekood1;
      INSERT INTO repis.emaisalaud (persoon, created_by) VALUES (_kirjekood2, _created_by);
    -- END IF;

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



-- kolime data emadisad tabelist sugulaste tabelisse
CREATE OR REPLACE TABLE repis.sugulased (
  `persoon` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `seos` enum('','ema','isa','abikaasa','kasuema','kasuisa') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `sugulane` char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `created_by` varchar(20) COLLATE utf8_estonian_ci NOT NULL DEFAULT '-',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`persoon`,`seos`,`sugulane`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

-- TRUNCATE TABLE repis.sugulased;

  INSERT INTO repis.sugulased
  SELECT persoon, 'ema', ema, updated_by, updated_at
  FROM repis.emadisad
  WHERE ema IS NOT NULL;

  INSERT INTO repis.sugulased
  SELECT persoon, 'isa', isa, updated_by, updated_at
  FROM repis.emadisad
  WHERE isa IS NOT NULL;

  INSERT INTO repis.sugulased
  SELECT persoon, 'kasuisa', kasuisa, updated_by, updated_at
  FROM repis.emadisad
  WHERE kasuisa IS NOT NULL;

  INSERT INTO repis.sugulased
  SELECT persoon, 'kasuema', kasuema, updated_by, updated_at
  FROM repis.emadisad
  WHERE kasuema IS NOT NULL;

  INSERT INTO repis.sugulased
  SELECT persoon, 'abikaasa', abikaasa, updated_by, updated_at
  FROM repis.emadisad
  WHERE abikaasa IS NOT NULL;

  INSERT IGNORE INTO repis.sugulased
  SELECT abikaasa, 'abikaasa', persoon, updated_by, updated_at
  FROM repis.emadisad
  WHERE abikaasa IS NOT NULL;
