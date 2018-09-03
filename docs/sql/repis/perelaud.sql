
--
-- Perelaud
--
CREATE OR REPLACE TABLE repis.perelaud (
  valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  kirjed varchar(100) COLLATE utf8_estonian_ci DEFAULT NULL,
  seos enum('- vali -','abikaasa','ema','isa','kasuema','kasuisa','kasulaps','kasupoeg','kasutütar','kasuvanem','laps','poeg','tütar','vanem','- isik -') COLLATE utf8_estonian_ci NOT NULL DEFAULT '- vali -',
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (id),
  UNIQUE KEY (persoon,created_by),
  CONSTRAINT perelaud_ibfk_1 FOREIGN KEY (persoon) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- Pereseosed
--
CREATE TABLE `pereseosed` (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sugulus varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  sugulane char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  created_at datetime NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY (persoon,sugulus,sugulane),
  KEY (sugulus),
  CONSTRAINT pereseosed_ibfk_1 FOREIGN KEY (persoon) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE,
  CONSTRAINT pereseosed_ibfk_2 FOREIGN KEY (sugulane) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

--
-- Triggers
--
DELIMITER ;; -- perelaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.perelaud_BI BEFORE INSERT ON repis.perelaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF NEW.persoon IS NULL THEN
      SELECT concat_ws('\n'
        , 'Alusta persooni koodiga'
        , user()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    SET @peresuurus = 0;
    SELECT count(1) INTO @peresuurus
    FROM repis.perelaud
    WHERE created_by = user();

    SET NEW.seos = '- vali -';

    IF @peresuurus = 0 THEN
      SET NEW.seos = '- isik -';
      SET NEW.valmis = '';
    END IF;
    SET NEW.kirjed = repis.perelaud_person_text(NEW.persoon);
    SET NEW.created_by = user();

  END;;

DELIMITER ;


DELIMITER ;; -- perelaud_BU

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.perelaud_BU BEFORE UPDATE ON repis.perelaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF NEW.persoon != OLD.persoon THEN
      SELECT concat_ws('\n'
        , 'Ära enam persooni koodiga jampsi'
        , user()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    IF OLD.seos = '- isik -' THEN
      SET NEW.seos = OLD.seos;
    END IF;
    SET NEW.created_by = OLD.created_by;

    --
    -- Clean desktop
    --
    IF NEW.valmis = 'Untsus' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,             params, created_by)
      VALUES                           (NULL,        NULL,       'perelaud_flush', NULL,   user());

    --
    -- Save and clean desktop
    --
    ELSEIF NEW.valmis = 'Valmis' THEN

      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,             params, created_by)
      VALUES                           (NULL,        NULL,       'perelaud_flush', NULL,   user());
    END IF;

  END;;

DELIMITER ;


DELIMITER ;; -- perelaud_person_text()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.perelaud_person_text(
    _kirjekood CHAR(10)
  ) RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
  func_label:BEGIN

    DECLARE person_text VARCHAR(2000);

    SELECT concat_ws('. ',
      concat_ws(', ',
        if(perenimi = '', NULL, perenimi),
        if(eesnimi  = '', NULL, eesnimi),
        if(isanimi  = '', NULL, concat('isa ', isanimi)),
        if(emanimi  = '', NULL, concat('ema ', emanimi))
      ),
      if(sünd       = '', NULL, concat('Sünd ', sünd)),
      if(surm       = '', NULL, concat('Surm ', surm)),
      if(sugu = '', NULL, sugu)
    )
    INTO person_text
    FROM repis.kirjed
    WHERE kirjekood = _kirjekood;

    RETURN person_text;

  END;;

DELIMITER ;



--
-- Procedures
--

DELIMITER ;; -- perelaud_flush

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_perelaud_flush(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    DELETE FROM repis.perelaud
    WHERE created_by = _created_by;

  END;;

DELIMITER ;
