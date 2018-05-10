-- CREATE OR REPLACE TABLE repis.desktop (
--   persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   kirjekood char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   kirje text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   jutt text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   allikas varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
--   valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
--   created_at timestamp NOT NULL DEFAULT current_timestamp(),
--   created_by varchar(50) NOT NULL DEFAULT '',
--   PRIMARY KEY (kirjekood,created_by)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


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

    ELSEIF NEW.kirjekood IN ('Nimekujud', 'NK') OR
           NEW.persoon IN ('Nimekujud', 'NK') THEN
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


DELIMITER ;; -- desktop_BU

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.desktop_BU BEFORE UPDATE ON repis.desktop FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg VARCHAR(2000);

    -- can change only owned records
      IF  OLD.created_by != user() AND user() != 'event_scheduler@localhost' THEN
        SELECT concat_ws('\n'
          , 'Mängi oma liivakastis!'
          , user()
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- no meddling
      SET NEW.created_by = OLD.created_by;
      SET NEW.allikas = OLD.allikas;

    -- cant change the identifier
      IF  NEW.kirjekood != OLD.kirjekood THEN
        SELECT concat_ws('\n'
          , 'Kirjekoode ei saa muuta.'
          , 'Mitte kuidagi ei saa.'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- cant remove person from record
      IF NEW.persoon != OLD.persoon AND NEW.persoon = '' THEN
        SELECT concat_ws('\n'
          , 'Kirjelt ei saa persooni ära võtta.'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- cant assign person to another person
      IF NEW.persoon != OLD.persoon AND OLD.kirjekood = OLD.persoon THEN
        SELECT concat_ws('\n'
          , 'Nimekuju kirjet ei saa isikust lahutada.'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- cant change anything but person for original records
      IF OLD.allikas NOT IN ('EMI', 'TS', 'Nimekujud')
        AND user() != 'queue@localhost'
        AND ( NEW.kirjekood != OLD.kirjekood OR
              NEW.perenimi != OLD.perenimi OR
              NEW.eesnimi != OLD.eesnimi OR
              NEW.isanimi != OLD.isanimi OR
              NEW.emanimi != OLD.emanimi OR
              NEW.sünd != OLD.sünd OR
              NEW.surm != OLD.surm OR
              NEW.jutt != OLD.jutt OR
              NEW.kirje != OLD.kirje OR
              NEW.allikas != OLD.allikas ) THEN
        SELECT concat_ws('\n'
          , 'Registri kirjetel saab muuta ainult persooni koodi!'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;


    --
    -- Recalculate current record
    --
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


    --
    -- Request recalculation for person that gave away record
    --
    IF NEW.persoon != OLD.persoon AND OLD.persoon != '' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (OLD.persoon, NULL,       'desktop_NK_refresh', '1',   user());
    END IF;


    --
    -- Request recalculation for affected person(s)
    --

    IF NEW.persoon != '' THEN
      SET @refresh_requested = 0;

      IF NEW.persoon != OLD.persoon AND @refresh_requested = 0 THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2',   user());
        SET @refresh_requested = 1;
      END IF;

      IF NEW.kirje != OLD.kirje AND NEW.allikas != 'Nimekujud' AND @refresh_requested = 0 THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2',   user());
        SET @refresh_requested = 1;
      END IF;

    END IF;




    --
    -- Clean desktop
    --
    IF NEW.valmis = 'Untsus' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (NULL,        NULL,       'desktop_flush', NULL,   user());

    --
    -- Save and clean desktop
    --
    ELSEIF NEW.valmis = 'Valmis' THEN

      -- Save new persons if any
      INSERT INTO repis.kirjed (
        persoon, kirjekood, kirje, perenimi, eesnimi,
        isanimi, emanimi, sünd, surm, allikas,
        created_at, created_by)
      SELECT d.persoon, d.kirjekood, d.kirje, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             now(), d.created_by
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      WHERE k.persoon IS NULL
      AND d.persoon = d.kirjekood
      AND d.created_by = SUBSTRING_INDEX(user(), '@', 1);

      -- Save new records to new persons if any
      INSERT INTO repis.kirjed (
        persoon, kirjekood, kirje, perenimi, eesnimi,
        isanimi, emanimi, sünd, surm, allikas,
        created_at, created_by)
      SELECT d.persoon, d.kirjekood, d.kirje, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             now(), d.created_by
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      WHERE k.persoon IS NULL
      AND d.persoon != d.kirjekood
      AND d.created_by = SUBSTRING_INDEX(user(), '@', 1);

      -- Update changed persons
      UPDATE repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
                                AND d.created_by = user()
      SET k.persoon = d.persoon,
          k.kirje = d.kirje,
          k.perenimi = d.perenimi, k.eesnimi = d.eesnimi,
          k.isanimi = d.isanimi, k.emanimi = d.emanimi,
          k.sünd = d.sünd, k.surm = d.surm, k.allikas = d.allikas,
          k.updated_at = now(), updated_by = SUBSTRING_INDEX(user(), '@', 1);

      -- Clean desktop
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (NULL,        NULL,       'desktop_flush', NULL,   user());
    END IF;

  END;;

DELIMITER ;


--
-- functions
--
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
    WHERE created_by = _created_by;

  END;;

DELIMITER ;


DELIMITER ;; -- desktop_NK_refresh

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_NK_refresh(
    IN _persoon CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    -- Declare variables to hold diagnostics area information
    DECLARE code CHAR(5) DEFAULT '00000';
    DECLARE msg TEXT;
    -- Declare exception handler for failed insert
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
      BEGIN
        GET DIAGNOSTICS CONDITION 1
          code = RETURNED_SQLSTATE, msg = MESSAGE_TEXT;
        INSERT INTO z_queue (task, params) values (code, msg);
      END;

    SET @allikas = '';
    SELECT allikas INTO @allikas FROM repis.desktop
    WHERE created_by = _created_by
      AND kirjekood = _persoon;

    IF @allikas != 'Nimekujud'
    THEN
        SELECT concat(
          'Nimekuju saab arvutada ainult NK kirjele!'
          , '\n', _persoon
          , '\n', @allikas
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

    UPDATE repis.desktop d LEFT JOIN
    (
      SELECT d0.persoon
      , SUBSTRING_INDEX(group_concat(
          if(d0.perenimi = ''   OR a.prioriteetPerenimi = 0,
            NULL, UPPER(d0.perenimi))
          ORDER BY a.prioriteetPerenimi DESC SEPARATOR ';'), ';', 1)
          AS perenimi
      , SUBSTRING_INDEX(group_concat(
          if(d0.eesnimi = ''    OR a.prioriteetEesnimi  = 0,
            NULL, REPLACE(UPPER(d0.eesnimi),'ALEKSANDR','ALEKSANDER'))
          ORDER BY a.prioriteetEesnimi  DESC SEPARATOR ';'), ';', 1)
          AS eesnimi
      , SUBSTRING_INDEX(group_concat(
          if(d0.isanimi = ''    OR a.prioriteetIsanimi  = 0,
            NULL, UPPER(d0.isanimi))
          ORDER BY a.prioriteetIsanimi  DESC SEPARATOR ';'), ';', 1)
          AS isanimi
      , SUBSTRING_INDEX(group_concat(
          if(d0.emanimi = ''    OR a.prioriteetEmanimi  = 0,
            NULL, UPPER(d0.emanimi))
          ORDER BY a.prioriteetEmanimi  DESC SEPARATOR ';'), ';', 1)
          AS emanimi
      , SUBSTRING_INDEX(group_concat(
          if(d0.sünd = ''       OR a.prioriteetSünd     = 0,
            NULL, d0.sünd)
          ORDER BY a.prioriteetSünd     DESC SEPARATOR ';'), ';', 1)
          AS sünd
      , SUBSTRING_INDEX(group_concat(
          if(d0.surm = ''       OR a.prioriteetSurm     = 0,
            NULL, d0.surm)
          ORDER BY a.prioriteetSurm     DESC SEPARATOR ';'), ';', 1)
          AS surm
      FROM repis.desktop d0
      LEFT JOIN allikad a ON a.kood = d0.allikas
      WHERE d0.persoon = _persoon
        AND d0.kirjekood != _persoon
      GROUP BY d0.persoon
    ) AS nimekuju ON nimekuju.persoon = d.persoon
    SET d.perenimi = ifnull(nimekuju.perenimi, '')
      , d.eesnimi = ifnull(nimekuju.eesnimi, '')
      , d.isanimi = ifnull(nimekuju.isanimi, '')
      , d.emanimi = ifnull(nimekuju.emanimi, '')
      , d.sünd = ifnull(nimekuju.sünd, '')
      , d.surm = ifnull(nimekuju.surm, '')
      , kirje =
        concat_ws('. '
          , concat_ws(', '
            , if(nimekuju.perenimi = '', NULL, nimekuju.perenimi)
            , if(nimekuju.eesnimi  = '', NULL, nimekuju.eesnimi)
            , if(nimekuju.isanimi  = '', NULL, nimekuju.isanimi)
            , if(nimekuju.emanimi  = '', NULL, nimekuju.emanimi)
          )
          , concat_ws(' - '
            , if(nimekuju.sünd = '', NULL, concat('Sünd ', nimekuju.sünd))
            , if(nimekuju.surm = '', NULL, concat('Surm ', nimekuju.surm))
          )
        )
    WHERE d.kirjekood = _persoon;

  END;;

DELIMITER ;
