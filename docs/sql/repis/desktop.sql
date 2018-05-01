CREATE OR REPLACE TABLE repis.desktop (
  persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirjekood char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  jutt text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirje text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  allikas varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  valmis tinyint(1) unsigned NOT NULL DEFAULT 0,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- Triggers
--
DELIMITER ;; -- desktop_BI

CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.desktop_BI BEFORE INSERT ON repis.desktop FOR EACH ROW
proc_label:BEGIN

  IF NEW.created_by = '' THEN
    SET NEW.created_by = user();
  END IF;

  IF NEW.allikas = 'EMI' THEN
    SELECT lpad(max(right(kirjekood, 6))+1, 10, 'EMI-000000') INTO @ik
      FROM repis.kirjed where allikas = NEW.allikas;
    SET NEW.persoon = @ik, NEW.allikas = 'EMI';
  ELSEIF NEW.allikas = 'TS' THEN
    SELECT lpad(max(right(kirjekood, 7))+1, 10, 'TS-0000000') INTO @ik
      FROM repis.kirjed where allikas = NEW.allikas;
    SET NEW.persoon = @ik, NEW.allikas = 'TS';
  ELSEIF NEW.allikas IS NULL AND user() != 'queue@localhost' THEN
    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                  params, created_by)
    VALUES                           (NEW.persoon, NEW.kirjekood, 'desktop_collect', NULL,   NEW.created_by);
  END IF;
END;;

DELIMITER ;


DELIMITER ;; -- desktop_BU

CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.desktop_BU BEFORE UPDATE ON repis.desktop FOR EACH ROW
proc_label:BEGIN

  DECLARE msg VARCHAR(2000);

  IF OLD.allikas regexp '⌃EMI$|⌃TS$' THEN
    SET NEW.allikas = OLD.allikas;
    SET NEW.kirje =
      concat_ws('. ',
        concat_ws(', ',
          if(NEW.perenimi = '', NULL, NEW.perenimi),
          if(NEW.eesnimi = '', NULL, NEW.eesnimi),
          if(NEW.isanimi = '', NULL, NEW.isanimi),
          if(NEW.emanimi = '', NULL, concat('ema eesnimi ', NEW.emanimi))
        ),
        if(NEW.sünd = '', NULL, concat('Sünd ', NEW.sünd)),
        if(NEW.surm = '', NULL, concat('Surm ', NEW.surm)),
        if(NEW.jutt = '', NULL, NEW.jutt)
      )
    ;
  -- ELSEIF IFNULL(OLD.kirjekood, '') = '' THEN
  ELSEIF NEW.kirjekood != OLD.kirjekood OR
        NEW.perenimi != OLD.perenimi OR
        NEW.eesnimi != OLD.eesnimi OR
        NEW.isanimi != OLD.isanimi OR
        NEW.emanimi != OLD.emanimi OR
        NEW.sünd != OLD.sünd OR
        NEW.surm != OLD.surm OR
        NEW.jutt != OLD.jutt OR
        NEW.kirje != OLD.kirje OR
        NEW.allikas != OLD.allikas
    THEN
      SELECT concat_ws('; ''Registri kirjetel saab muuta ainult persooni koodi!',
        NEW.kirjekood, OLD.kirjekood ,
        NEW.perenimi, OLD.perenimi ,
        NEW.eesnimi, OLD.eesnimi ,
        NEW.isanimi, OLD.isanimi ,
        NEW.emanimi, OLD.emanimi ,
        NEW.sünd, OLD.sünd ,
        NEW.surm, OLD.surm ,
        NEW.jutt, OLD.jutt ,
        NEW.kirje, OLD.kirje ,
        NEW.allikas, OLD.allikas) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
  END IF;


  IF NEW.valmis = 1 THEN
    INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2, task,                params, created_by)
    VALUES                           (NULL,       NULL,       'desktop_flush', NULL,   user());

    LEAVE proc_label;
  END IF;

END;;

DELIMITER ;

--
-- Procedures
--
DELIMITER ;; -- desktop_collect

CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_collect(
  IN _persoon CHAR(10), IN _kirjekood2 CHAR(10),
  IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
proc_label:BEGIN

  IF _persoon != '' THEN
    SELECT persoon INTO @p_id FROM repis.kirjed WHERE kirjekood = _persoon;

    DELETE FROM repis.desktop WHERE persoon = _persoon AND allikas IS NULL AND created_by = _created_by;
    INSERT IGNORE INTO repis.desktop
    (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, created_by)
    SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, _created_by
    FROM repis.kirjed k
    WHERE k.persoon = @p_id;

  ELSEIF _kirjekood2 != '' THEN
    DELETE FROM repis.desktop WHERE kirjekood = _kirjekood2 AND allikas IS NULL AND created_by = _created_by;
    INSERT IGNORE INTO repis.desktop
    (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, created_by)
    SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, _created_by
    FROM repis.kirjed k
    WHERE k.kirjekood = _kirjekood2;
  END IF;
END;;

DELIMITER ;


DELIMITER ;; -- desktop_flush

CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_flush(
  IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
  IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
proc_label:BEGIN

  DELETE FROM repis.desktop;

END;;

DELIMITER ;



INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('NK-0091094', '', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');

INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('', 'NK-0091094', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');