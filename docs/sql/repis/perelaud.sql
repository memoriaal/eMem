
--
-- Perelaud
--
CREATE OR REPLACE TABLE repis.perelaud (
  valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  persoon1 char(10) COLLATE utf8_estonian_ci DEFAULT '',
  kirje1 varchar(100) COLLATE utf8_estonian_ci DEFAULT NULL,
  seos1 enum('ema','isa','vanem','kasuema','kasuisa','kasuvanem'),
  seos2 enum('poeg','tütar','laps','kasupoeg','kasutütar','kasulaps'),
  kirje2 varchar(100) COLLATE utf8_estonian_ci DEFAULT NULL,
  persoon2 char(10) COLLATE utf8_estonian_ci DEFAULT '',
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  PRIMARY KEY (persoon1, persoon2, created_by),
  UNIQUE KEY id (id),
  CONSTRAINT perelaud_ibfk_1 FOREIGN KEY (persoon1) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE,
  CONSTRAINT perelaud_ibfk_2 FOREIGN KEY (persoon2) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- Triggers
--
DELIMITER ;; -- perelaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.perelaud_BI BEFORE INSERT ON repis.perelaud FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    IF NEW.persoon1 = '' AND NEW.persoon2 = '' THEN
      SELECT concat_ws('\n'
        , 'Alusta persooni määramisega'
        , user()
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    SET NEW.persoon1 = IFNULL(repis.func_kirje2persoon(NEW.persoon1), '');
    SET NEW.persoon2 = IFNULL(repis.func_kirje2persoon(NEW.persoon2), '');

    SET NEW.kirje1 = IFNULL(repis.perelaud_person_text(NEW.persoon1), '');
    SET NEW.kirje2 = IFNULL(repis.perelaud_person_text(NEW.persoon2), '');

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
