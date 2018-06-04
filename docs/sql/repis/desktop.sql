CREATE OR REPLACE TABLE repis.desktop (
  valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirjekood char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  jutt text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirje text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  välisviide varchar(2000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  allikas varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  EkslikKanne enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Kustuta enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,created_by)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


CREATE OR REPLACE VIEW `my_desktop`
AS SELECT
   `desktop`.`persoon` AS `persoon`,
   `desktop`.`kirjekood` AS `kirjekood`,
   `desktop`.`valmis` AS `valmis`,
   `desktop`.`jutt` AS `jutt`,
   `desktop`.`perenimi` AS `perenimi`,
   `desktop`.`eesnimi` AS `eesnimi`,
   `desktop`.`isanimi` AS `isanimi`,
   `desktop`.`emanimi` AS `emanimi`,
   `desktop`.`sünd` AS `sünd`,
   `desktop`.`surm` AS `surm`,
   `desktop`.`kirje` AS `kirje`,
   `desktop`.`välisviide` AS `välisviide`,
   `desktop`.`allikas` AS `allikas`,
   `desktop`.`EkslikKanne` AS `EkslikKanne`,
   `desktop`.`Kustuta` AS `Kustuta`,
   `desktop`.`created_at` AS `created_at`,
   `desktop`.`created_by` AS `created_by`
FROM `desktop` where `desktop`.`created_by` = user();


--
-- Triggers
--
DELIMITER ;; -- desktop_BI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.desktop_BI BEFORE INSERT ON repis.desktop FOR EACH ROW
  proc_label:BEGIN

    IF NEW.created_by = '' THEN
      SET NEW.created_by = user();
    END IF;

    SET @new_code = UPPER(IF(NEW.kirjekood = '', NEW.persoon, NEW.kirjekood));

    IF @new_code IN ('EMI', 'TS') THEN
      SET NEW.persoon = '',
          NEW.kirjekood = repis.desktop_next_id(@new_code),
          NEW.allikas = @new_code;

    ELSEIF @new_code = '0' THEN
      SET @ik = repis.desktop_next_id('Persoon');
      SET NEW.persoon = @ik,
          NEW.kirjekood = @ik,
          NEW.allikas = 'Persoon';

    ELSEIF NEW.allikas IS NULL AND user() != 'queue@localhost' THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2,    task,              params, created_by)
      VALUES                           (NEW.persoon, NEW.kirjekood, 'desktop_collect', NULL,   NEW.created_by);
      IF @new_code LIKE 'PR-%' THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2,   task,                        params, created_by)
        VALUES                           (@new_code,  NULL,         'desktop_PR_import', NULL,   NEW.created_by);
      ELSEIF @new_code LIKE 'RK-%' THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2,   task,                        params, created_by)
        VALUES                           (@new_code,  NULL,         'desktop_RK_import', NULL,   NEW.created_by);
      END IF;

    END IF;
  END;;

DELIMITER ;


DELIMITER ;; -- desktop_BU

  CREATE OR REPLACE DEFINER=queue@localhost TRIGGER repis.desktop_BU BEFORE UPDATE ON repis.desktop FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg TEXT;

    -- can change only owned records
      IF  OLD.created_by != user()
        AND user() != 'queue@localhost'
        AND user() != 'event_scheduler@localhost'
        THEN
        SELECT concat_ws('\n'
          , 'Mängi oma liivakastis!'
          , user()
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;

    -- no meddling
      SET NEW.created_by = OLD.created_by;
      SET NEW.allikas = OLD.allikas;
      SET NEW.jutt = IF(OLD.jutt = ' - - - ', ' - - - ', NEW.jutt);

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

    -- cant change almost anything but person for original records
      IF OLD.allikas NOT IN ('EMI', 'TS', 'Persoon')
        AND user() != 'queue@localhost'
        AND user() != 'event_scheduler@localhost'
        AND ( NEW.kirjekood != OLD.kirjekood OR
              NEW.perenimi != OLD.perenimi OR
              NEW.eesnimi != OLD.eesnimi OR
              NEW.isanimi != OLD.isanimi OR
              NEW.emanimi != OLD.emanimi OR
              NEW.sünd != OLD.sünd OR
              NEW.surm != OLD.surm OR
              NEW.jutt != OLD.jutt OR
              NEW.välisviide != OLD.välisviide OR
              NEW.kirje != OLD.kirje OR
              NEW.allikas != OLD.allikas ) THEN
        SELECT concat_ws('\n'
          , 'Registri kirjetel saab muuta ainult persooni koodi!'
        ) INTO msg;
        SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
      END IF;


    --
    -- Prefill names'n'dates'n'kirje
    --
    IF OLD.allikas IN ('EMI', 'TS')
       AND OLD.persoon = '' AND NEW.persoon != '' THEN
      IF NEW.perenimi = '' AND NEW.eesnimi  = ''
         AND NEW.isanimi  = '' AND NEW.emanimi  = ''
         AND NEW.sünd     = '' AND NEW.surm     = '' THEN
            SET @perenimi = '', @eesnimi = ''
               , @isanimi = '', @emanimi = ''
               , @sünd = '', @surm = ''
               , @kirje = '', @allikas = '';
            SELECT k.perenimi, k.eesnimi
                 , k.isanimi, k.emanimi
                 , k.sünd, k.surm
                 , k.kirje, k.allikas
              INTO @perenimi, @eesnimi
                 , @isanimi, @emanimi
                 , @sünd, @surm
                 , @kirje, @allikas
              FROM kirjed k
             WHERE k.kirjekood = NEW.persoon;

            SET @nimekirje = concat(
              repis.desktop_person_text(
                @perenimi, @eesnimi, @isanimi, @emanimi, @sünd, @surm
              ) collate utf8_estonian_ci,
              '. '
            );

            SET @match = @kirje LIKE concat(@nimekirje, '%') COLLATE utf8_estonian_ci;

            SET NEW.perenimi = @perenimi, NEW.eesnimi = @eesnimi,
                NEW.isanimi = @isanimi, NEW.emanimi = @emanimi,
                NEW.sünd = @sünd, NEW.surm = @surm;
                -- NEW.jutt = IF(@allikas IN ('TS','EMI'),
                --   IF(@match,
                --     REPLACE(
                --       @kirje,
                --       @nimekirje,
                --       ''
                --     ),
                --     @kirje
                --   ),
                --   ' - - - '
                -- );
      END IF;
    END IF;


    --
    -- Recalculate current record
    --
    IF OLD.allikas IN ('EMI', 'TS', 'Persoon') THEN
      SET NEW.kirje =
        concat_ws('. ',
          repis.desktop_person_text(
              NEW.perenimi, NEW.eesnimi,
              NEW.isanimi, NEW.emanimi,
              NEW.sünd, NEW.surm
            ) collate utf8_estonian_ci,
          if(NEW.jutt IN('', ' - - - '), NULL, NEW.jutt)
          -- , if(NEW.välisviide = '', NULL, NEW.välisviide)
        )
      ;
    END IF;


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
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2.1',   user());
        SET @refresh_requested = 1;
      END IF;

      IF NEW.kirje != OLD.kirje AND NEW.allikas != 'Persoon' AND @refresh_requested = 0 THEN
        INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
        VALUES                           (NEW.persoon, NULL,       'desktop_NK_refresh', '2.2',   user());
        SET @refresh_requested = 1;
      END IF;

    END IF;

    --
    -- Request recalculation for person with changed status
    --
    IF NEW.EkslikKanne != OLD.EkslikKanne
       OR NEW.Kustuta != OLD.Kustuta THEN
      INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,            params, created_by)
      VALUES                           (OLD.persoon, NULL,       'desktop_NK_refresh', '3',   user());
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
        välisviide, EkslikKanne,
        created_at, created_by)
      SELECT d.persoon, d.kirjekood, d.kirje, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             d.välisviide, d.EkslikKanne,
             now(), SUBSTRING_INDEX(user(), '@', 1)
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      WHERE k.persoon IS NULL
      AND d.persoon = d.kirjekood
      AND d.created_by = user();

      -- Save new records to new persons if any
      INSERT INTO repis.kirjed (
        persoon, kirjekood, kirje, perenimi, eesnimi,
        isanimi, emanimi, sünd, surm, allikas,
        välisviide, EkslikKanne,
        created_at, created_by)
      SELECT d.persoon, d.kirjekood, d.kirje, d.perenimi, d.eesnimi,
             d.isanimi, d.emanimi, d.sünd, d.surm, d.allikas,
             d.välisviide, d.EkslikKanne,
             now(), SUBSTRING_INDEX(user(), '@', 1)
      FROM repis.desktop d
      LEFT JOIN repis.kirjed k ON k.kirjekood = d.kirjekood
      WHERE k.kirjekood IS NULL
      AND d.persoon != d.kirjekood
      AND d.created_by = user();

      -- Update changed persons
      UPDATE repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
      SET k.persoon = d.persoon,
          k.kirje = d.kirje,
          k.perenimi = d.perenimi, k.eesnimi = d.eesnimi,
          k.isanimi = d.isanimi, k.emanimi = d.emanimi,
          k.sünd = d.sünd, k.surm = d.surm, k.allikas = d.allikas,
          k.välisviide = d.välisviide, k.EkslikKanne = d.EkslikKanne,
          k.updated_at = now(), updated_by = SUBSTRING_INDEX(user(), '@', 1)
      WHERE d.created_by = user();

      -- Remove deleted records
      UPDATE repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
                                AND d.created_by = user()
                                AND d.Kustuta = '!'
      SET k.persoon = NULL;

      DELETE k FROM repis.kirjed k
      RIGHT JOIN repis.desktop d ON d.kirjekood = k.kirjekood
                                AND d.created_by = user()
                                AND d.Kustuta = '!';

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
      if(_allikas = 'Persoon',
        rpad('0', 10, '0'),
        concat_ws('-', @c, rpad('0', 9-length(@c), '0'))
      )
    );

    RETURN @id;
  END;;

DELIMITER ;


DELIMITER ;; -- desktop_person_text()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.desktop_person_text(
      _perenimi VARCHAR(50),
      _eesnimi VARCHAR(50),
      _isanimi VARCHAR(50),
      _emanimi VARCHAR(50),
      _sünd VARCHAR(50),
      _surm VARCHAR(50)
  ) RETURNS varchar(2000) CHARSET utf8 COLLATE  utf8_estonian_ci
  func_label:BEGIN

    RETURN concat_ws('. ',
      concat_ws(', ',
        if(_perenimi = '', NULL, _perenimi),
        if(_eesnimi  = '', NULL, _eesnimi),
        if(_isanimi  = '', NULL, concat('isa ', _isanimi)),
        if(_emanimi  = '', NULL, concat('ema ', _emanimi))
      ),
      if(_sünd       = '', NULL, concat('Sünd ', _sünd)),
      if(_surm       = '', NULL, concat('Surm ', _surm))
    );

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
      (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, välisviide, EkslikKanne, created_by
        , jutt)
      SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, välisviide, EkslikKanne, _created_by
        , IF(allikas IN ('TS','EMI'),
            IF(kirje LIKE concat(repis.desktop_person_text(perenimi, eesnimi, isanimi, emanimi, sünd, surm), '. %') collate utf8_estonian_ci,
              REPLACE(
                kirje,
                concat(repis.desktop_person_text(perenimi, eesnimi, isanimi, emanimi, sünd, surm), '. ') collate utf8_estonian_ci,
                ''
              ),
              kirje
            ),
            ' - - - '
          )
      FROM repis.kirjed k
      WHERE k.persoon = @p_id;

    ELSEIF _kirjekood2 != '' THEN
      DELETE FROM repis.desktop WHERE kirjekood = _kirjekood2 AND allikas IS NULL AND created_by = _created_by;
      INSERT IGNORE INTO repis.desktop
      (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, välisviide, EkslikKanne, created_by
        , jutt)
      SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm, kirje, allikas, välisviide, EkslikKanne, _created_by
        , IF(allikas IN ('TS','EMI'),
            IF(kirje LIKE concat(repis.desktop_person_text(perenimi, eesnimi, isanimi, emanimi, sünd, surm), '. %') collate utf8_estonian_ci,
              REPLACE(
                kirje,
                concat(repis.desktop_person_text(perenimi, eesnimi, isanimi, emanimi, sünd, surm), '. ') collate utf8_estonian_ci,
                ''
              ),
              kirje
            ),
            ' - - - '
          )
      FROM repis.kirjed k
      WHERE k.kirjekood = _kirjekood2;
    END IF;
  END;;

DELIMITER ;


DELIMITER ;; -- desktop_PR_import

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_PR_import(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';',
          if(isik_perenimi='',NULL,isik_perenimi),
          if(isik_perenimi_endine1='',NULL,isik_perenimi_endine1),
          if(isik_perenimi_endine2='',NULL,isik_perenimi_endine2),
          if(isik_perenimi_endine3='',NULL,isik_perenimi_endine3),
          if(isik_perenimi_endine4='',NULL,isik_perenimi_endine4)
        ),
        concat_ws(';',
          if(isik_eesnimi='',NULL,isik_eesnimi),
          if(isik_eesnimi_endine1='',NULL,isik_eesnimi_endine1),
          if(isik_eesnimi_endine2='',NULL,isik_eesnimi_endine2)
        ),
        if(isa_eesnimi='',NULL,isa_eesnimi),
        if(ema_eesnimi='',NULL,concat('ema eesnimi ',ema_eesnimi)),
        if(isik_sugu='',NULL,isik_sugu)
      ),
      concat_ws(', ',
        if(isik_synniaasta='',NULL,concat('Sünd: ', concat_ws('-',
          isik_synniaasta,
          if(isik_synnikuu='',NULL,LPAD(isik_synnikuu, 2, '00')),
          if(isik_synnipaev='',NULL,LPAD(isik_synnipaev, 2, '00'))
        ))),
        if(isik_synnikoht='',NULL,isik_synnikoht),
        if(isik_synniriik='',NULL,isik_synniriik)
      ),
      if(isik_surmaaasta='' AND isik_surmakoht='' AND isik_surmariik='', NULL,
        concat_ws(', ',
          if(isik_surmaaasta='',NULL,concat('Surm: ', concat_ws('-',
            isik_surmaaasta,
            if(isik_surmakuu='',NULL,LPAD(isik_surmakuu, 2, '00')),
            if(isik_surmapaev='',NULL,LPAD(isik_surmapaev, 2, '00'))
          ))),
          if(isik_surmakoht='',NULL,isik_surmakoht),
          if(isik_surmariik='',NULL,isik_surmariik)
        )
      ),
      concat('Raamat: ', raamatu_omavalitsus, ' kd ', koite_nr, ' lk ', lk_nr),
      ''
    ) INTO @_kirje
    FROM import.pereregister
    WHERE isikukood = _kirjekood1;

    UPDATE repis.desktop d
    LEFT JOIN import.pereregister pr on pr.isikukood = d.kirjekood
    SET
      d.kirje = @_kirje,
      d.perenimi = pr.isik_perenimi,
      d.eesnimi = pr.isik_eesnimi,
      d.isanimi = pr.isa_eesnimi,
      d.emanimi = pr.ema_eesnimi,
      d.sünd = ifnull(concat_ws('-',
        if(pr.isik_synniaasta = '', NULL, pr.isik_synniaasta),
        if(pr.isik_synnikuu = '', NULL, pr.isik_synnikuu),
        if(pr.isik_synnipaev = '', NULL, pr.isik_synnipaev)
      ), ''),
      d.surm = ifnull(concat_ws('-',
        if(pr.isik_surmaaasta = '', NULL, pr.isik_surmaaasta),
        if(pr.isik_surmakuu = '', NULL, pr.isik_surmakuu),
        if(pr.isik_surmapaev = '', NULL, pr.isik_surmapaev)
      ), ''),
      d.created_by = user()
    WHERE pr.isikukood = _kirjekood1
      AND d.persoon IS NULL;

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

    -- INSERT INTO z_queue (task, params, erred_at) values (_created_by, user(), now());

    SET @allikas = '';
    SELECT allikas INTO @allikas FROM repis.desktop
    WHERE created_by = _created_by
      AND kirjekood = _persoon;

    IF @allikas != 'Persoon'
    THEN
        SELECT concat(
          'Nimekuju saab arvutada ainult persoonikirjele!'
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
        AND d0.EkslikKanne != '!'
        AND d0.Kustuta != '!'
        AND d0.created_by = _created_by
      GROUP BY d0.persoon
    ) AS nimekuju ON nimekuju.persoon = d.persoon
    SET d.perenimi = ifnull(nimekuju.perenimi, '')
      , d.eesnimi = ifnull(nimekuju.eesnimi, '')
      , d.isanimi = ifnull(nimekuju.isanimi, '')
      , d.emanimi = ifnull(nimekuju.emanimi, '')
      , d.sünd = ifnull(if(nimekuju.sünd = '-', '', nimekuju.sünd), '')
      , d.surm = ifnull(if(nimekuju.surm = '-', '', nimekuju.surm), '')
      , d.kirje = repis.desktop_person_text(
          nimekuju.perenimi, nimekuju.eesnimi,
          nimekuju.isanimi, nimekuju.emanimi,
          nimekuju.sünd, nimekuju.surm
        ) collate utf8_estonian_ci
    WHERE d.kirjekood = _persoon
      AND d.created_by = _created_by;

  END;;

DELIMITER ;
