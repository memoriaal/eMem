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

  IF NEW.kirjekood = 'EMI' THEN
    SET NEW.kirjekood = repis.desktop_next_id('EMI'), NEW.allikas = 'EMI';

  ELSEIF NEW.kirjekood = 'TS' THEN
    SET NEW.kirjekood = repis.desktop_next_id('TS'), NEW.allikas = 'TS';

  ELSEIF NEW.persoon IN ('Nimekujud', 'NK') THEN
    SET @ik = repis.desktop_next_id('Nimekujud');
    SET NEW.persoon = @ik,
        NEW.kirjekood = @ik,
        NEW.allikas = 'Nimekujud';

  ELSEIF NEW.allikas IS NULL AND user() != 'queue@localhost' THEN
    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,                  params, created_by)
    VALUES                           (NEW.persoon, NEW.kirjekood, 'desktop_collect', NULL,   NEW.created_by);

  END IF;
END;;

DELIMITER ;


DELIMITER ;; -- desktop_next_id()

CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.desktop_next_id(
    _allikas VARCHAR(50)
) RETURNS CHAR(10) CHARSET utf8
func_label:BEGIN

  SELECT lühend INTO @c FROM repis.allikad WHERE kood = _allikas;

  SET @max_k = NULL;
  SELECT max(kirjekood) INTO @max_k
  FROM repis.kirjed
  WHERE allikas = _allikas;

  SET @max_d = NULL;
  SELECT max(kirjekood) INTO @max_d
  FROM repis.desktop
  WHERE allikas = _allikas;

  SET @id = lpad(
    RIGHT(IF(@max_k >= IFNuLL(@max_d, @max_k), @max_k, @max_d), 9-length(@c)) + 1,
    10,
    concat_ws('-', @c, rpad('0', 9-length(@c), '0'))
  );

  RETURN @id;
END;;

DELIMITER ;


DELIMITER ;; -- desktop_BU

CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.desktop_BU BEFORE UPDATE ON repis.desktop FOR EACH ROW
proc_label:BEGIN

  DECLARE msg VARCHAR(2000);

  SET NEW.created_by = OLD.created_by;

  IF OLD.allikas in ('EMI', 'TS') THEN
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

  ELSEIF user() != 'queue@localhost' AND (
        NEW.kirjekood != OLD.kirjekood OR
        NEW.perenimi != OLD.perenimi OR
        NEW.eesnimi != OLD.eesnimi OR
        NEW.isanimi != OLD.isanimi OR
        NEW.emanimi != OLD.emanimi OR
        NEW.sünd != OLD.sünd OR
        NEW.surm != OLD.surm OR
        NEW.jutt != OLD.jutt OR
        NEW.kirje != OLD.kirje OR
        NEW.allikas != OLD.allikas)
    THEN
      SELECT concat_ws('\n'
        , 'Registri kirjetel saab muuta ainult persooni koodi!'
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;

  END IF;


  IF NEW.valmis = 1 and NEW.created_by = user() THEN
    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
    VALUES                           (NEW.persoon, NULL,       'desktop_flush', NULL,   user());
  ELSEIF NEW.valmis = 1 and NEW.created_by != user() THEN
    SET NEW.valmis = 0;
    SELECT concat_ws('; ', 'Valmis saab märkida ainult oma tehtud ridu!') INTO msg;
    SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
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

  DELETE FROM repis.desktop
  WHERE created_by = _created_by
    AND persoon = _kirjekood1;

END;;

DELIMITER ;



INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('NK-0091094', '', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');

INSERT INTO desktop (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, jutt, kirje, allikas, valmis, created_at, created_by) VALUES ('', 'NK-0091094', '', '', '', '', '', '', '', '', NULL, '0', current_timestamp(), '');
