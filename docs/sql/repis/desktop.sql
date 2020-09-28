DROP TABLE IF EXISTS repis.desk_sildid;
DROP TABLE IF EXISTS repis.desk_lipikud;
DROP VIEW IF EXISTS repis.my_desktop;
DROP TABLE IF EXISTS repis.desktop;

CREATE OR REPLACE TABLE repis.desktop (
  persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirjekood char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  jutt text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  matmisaeg varchar(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünnikoht varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  elukoht varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  matmiskoht varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  `surma põhjus` varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  lipik varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  lipikud text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  silt varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  sildid text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kirje text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  legend text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  EkslikKanne enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Peatatud enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  EiArvesta enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Kustuta enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  välisviide varchar(2000) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  allikas varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,created_by),
  UNIQUE KEY id (id),
  KEY lipik (lipik),
  KEY silt (silt),
  CONSTRAINT desktop_ibfk_1 FOREIGN KEY (lipik) REFERENCES repis.c_lipikud (lipik) ON UPDATE CASCADE,
  CONSTRAINT desktop_ibfk_2 FOREIGN KEY (silt) REFERENCES repis.c_sildid (silt) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE repis.desk_lipikud (
  desktop_id int(10) unsigned NOT NULL,
  lipik varchar(50) COLLATE utf8_estonian_ci NOT NULL,
  -- created_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (desktop_id, lipik),
  KEY lipik (lipik),
  CONSTRAINT desk_lipikud_ibfk_1 FOREIGN KEY (desktop_id) REFERENCES repis.desktop (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT desk_lipikud_ibfk_2 FOREIGN KEY (lipik) REFERENCES repis.c_lipikud (lipik) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE repis.desk_sildid (
  desktop_id int(10) unsigned NOT NULL,
  silt varchar(50) COLLATE utf8_estonian_ci NOT NULL,
  -- created_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (desktop_id, silt),
  KEY silt (silt),
  CONSTRAINT desk_sildid_ibfk_1 FOREIGN KEY (desktop_id) REFERENCES repis.desktop (id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT desk_sildid_ibfk_2 FOREIGN KEY (silt) REFERENCES repis.c_sildid (silt) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;



CREATE OR REPLACE VIEW repis.my_desktop
AS SELECT
   desktop.persoon AS persoon,
   desktop.kirjekood AS kirjekood,
   desktop.valmis AS valmis,
   desktop.jutt AS jutt,
   desktop.perenimi AS perenimi,
   desktop.eesnimi AS eesnimi,
   desktop.isanimi AS isanimi,
   desktop.emanimi AS emanimi,
   desktop.sünd AS sünd,
   desktop.surm AS surm,
   desktop.matmisaeg AS matmisaeg,
   desktop.sünnikoht AS sünnikoht,
   desktop.elukoht AS elukoht,
   desktop.matmiskoht AS matmiskoht,
   desktop.`surma põhjus` AS `surma põhjus`,
   desktop.Peatatud AS Peatatud,
   desktop.EiArvesta AS EiArvesta,
   desktop.lipik AS lipik,
   desktop.lipikud AS lipikud,
   desktop.silt AS silt,
   desktop.sildid AS sildid,
   desktop.kirje AS kirje,
   desktop.legend AS legend,
   desktop.välisviide AS välisviide,
   desktop.allikas AS allikas,
   desktop.EkslikKanne AS EkslikKanne,
   desktop.Kustuta AS Kustuta,
   desktop.created_at AS created_at,
   desktop.created_by AS created_by
FROM repis.desktop where desktop.created_by = user();

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

    IF @new_code IN ('EMI', 'TS', 'R4-1', 'KR') THEN
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
        SET NEW.persoon = '';
        SET NEW.kirjekood = @new_code;
        SET NEW.allikas = 'PR';
        INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2,   task,                        params, created_by)
        VALUES                           (NULL,       @new_code,    'desktop_PR_import', NULL,   NEW.created_by);
      ELSEIF @new_code LIKE 'RK-%' THEN
        SET NEW.persoon = '';
        SET NEW.kirjekood = @new_code;
        SET NEW.allikas = 'RK';
        INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2,   task,                        params, created_by)
        VALUES                           (NULL,       @new_code,    'desktop_RK_import', NULL,   NEW.created_by);
      ELSEIF @new_code LIKE 'RR-%' THEN
        SET NEW.persoon = '';
        SET NEW.kirjekood = @new_code;
        SET NEW.allikas = 'RR';
        INSERT IGNORE INTO repis.z_queue (kirjekood1, kirjekood2,   task,                        params, created_by)
        VALUES                           (NULL,       @new_code,    'desktop_RR_import', NULL,   NEW.created_by);
      END IF;

    END IF;
  END;;

DELIMITER ;




--
-- functions
--

DELIMITER ;; -- desktop_next_id()
  CREATE DEFINER=queue@localhost FUNCTION desktop_next_id(
        _allikas VARCHAR(50)
    ) RETURNS char(10) CHARSET utf8
  func_label:BEGIN

    SELECT lühend INTO @c FROM repis.allikad WHERE kood = _allikas;

    -- CALL log_msg('@c', @c);
    SET @max_k = NULL;
    SELECT ifnull(max(kirjekood), 0) INTO @max_k
    FROM repis.kirjed
    WHERE allikas = _allikas;
    -- CALL log_msg('@max_k', @max_k);

    SET @max_d = NULL;
    SELECT ifnull(max(kirjekood), 0) INTO @max_d
    FROM repis.desktop
    WHERE allikas = _allikas;
    -- CALL log_msg('@max_d', @max_d);

    SET @id = lpad(
      RIGHT(IF(@max_k >= @max_d, @max_k, @max_d), 9-length(@c)) + 1,
      10,
      if(_allikas = 'Persoon',
        rpad('0', 10, '0'),
        concat_ws('-', @c, rpad('0', 9-length(@c), '0'))
      )
    );
    -- CALL log_msg('@id', @id);

    RETURN @id;
  END;
DELIMITER ;


DELIMITER ;; -- desktop_person_text()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.desktop_person_text(
      _perenimi VARCHAR(50),
      _eesnimi VARCHAR(50),
      _isanimi VARCHAR(50),
      _emanimi VARCHAR(50),
      _sünd VARCHAR(50),
      _surm VARCHAR(50)
    ) RETURNS varchar(2000) CHARSET utf8 COLLATE utf8_estonian_ci
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

    INSERT INTO z_queue (task, params) values ('log', 'foo');


    IF _persoon != '' THEN
      SET @p_id = '' COLLATE utf8_estonian_ci;
      SELECT persoon INTO @p_id FROM repis.kirjed WHERE kirjekood = _persoon;

      DELETE FROM repis.desktop WHERE persoon = _persoon AND allikas IS NULL AND created_by = _created_by;
      INSERT IGNORE INTO repis.desktop
      (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm
        -- , lipikud
        -- , sildid
        , kirje, legend, allikas, välisviide, EkslikKanne, Peatatud, EiArvesta, created_by
        , jutt)
      SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm
        -- , repis.func_kirjelipikud(kirjekood)
        -- , repis.func_kirjesildid(kirjekood)
        , kirje, legend, allikas, välisviide, EkslikKanne, Peatatud, EiArvesta, _created_by
        , IF(allikas IN ('EMI', 'TS'),
            kirjeJutt,
            ' - - - '
          ) jutt
      FROM repis.kirjed k
      WHERE k.persoon = @p_id;

    ELSEIF _kirjekood2 != '' THEN

      SELECT repis.desktop_person_text(k.perenimi, k.eesnimi, k.isanimi, k.emanimi, k.sünd, k.surm)
        INTO @jutt
        FROM repis.kirjed k
       WHERE k.kirjekood = _kirjekood2;

      DELETE FROM repis.desktop WHERE kirjekood = _kirjekood2 AND allikas IS NULL AND created_by = _created_by;
      INSERT IGNORE INTO repis.desktop
      (persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm
        -- , lipikud
        -- , sildid
        , kirje, legend, allikas, välisviide, EkslikKanne, Peatatud, EiArvesta, created_by
        , jutt)
      SELECT persoon, kirjekood, perenimi, eesnimi, isanimi, emanimi, sünd, surm
        -- , repis.func_kirjelipikud(kirjekood)
        -- , repis.func_kirjesildid(kirjekood)
        , kirje, legend, allikas, välisviide, EkslikKanne, Peatatud, EiArvesta, _created_by
        , IF(allikas IN ('TS','EMI'),
            IF(kirje LIKE concat(@jutt, '. %') , -- COLLATE utf8_estonian_ci,
              REPLACE(
                kirje,
                concat(@jutt, '. ') , -- COLLATE utf8_estonian_ci,
                ''
              ),
              kirje
            ),
            ' - - - '
          )
      FROM repis.kirjed k
      WHERE k.kirjekood = _kirjekood2;
    END IF;

    INSERT IGNORE INTO repis.desk_lipikud (desktop_id, lipik)
    SELECT d.id, kl.lipik
    FROM repis.desktop d
    LEFT JOIN repis.v_kirjelipikud kl ON kl.kirjekood = d.kirjekood
    WHERE kl.kirjekood IS NOT NULL
      AND d.created_by = _created_by;

    INSERT IGNORE INTO repis.desk_sildid (desktop_id, silt)
    SELECT d.id, ks.silt
    FROM repis.desktop d
    LEFT JOIN repis.v_kirjesildid ks ON ks.kirjekood = d.kirjekood
    WHERE ks.kirjekood IS NOT NULL
      AND d.created_by = _created_by;

    UPDATE repis.desktop d
    LEFT JOIN (
      SELECT desktop_id
           , group_concat(DISTINCT lipik ORDER BY lipik SEPARATOR '; ') AS lipikud
        FROM repis.desk_lipikud GROUP BY desktop_id
      ) AS dl ON dl.desktop_id = d.id
    LEFT JOIN (
      SELECT desktop_id
           , group_concat(DISTINCT silt ORDER BY silt SEPARATOR '; ') AS sildid
        FROM repis.desk_sildid GROUP BY desktop_id
      ) AS ds ON ds.desktop_id = d.id
    SET d.lipikud = dl.lipikud
      , d.sildid  = ds.sildid
    WHERE d.created_by = _created_by;

    INSERT INTO z_queue (task, params) values ('log', 'foo2');

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
          if(pr.isik_perenimi='',NULL,pr.isik_perenimi),
          if(pr.isik_perenimi_endine1='',NULL,pr.isik_perenimi_endine1),
          if(pr.isik_perenimi_endine2='',NULL,pr.isik_perenimi_endine2),
          if(pr.isik_perenimi_endine3='',NULL,pr.isik_perenimi_endine3),
          if(pr.isik_perenimi_endine4='',NULL,pr.isik_perenimi_endine4)
        ),
        concat_ws(';',
          if(pr.isik_eesnimi='',NULL,pr.isik_eesnimi),
          if(pr.isik_eesnimi_endine1='',NULL,pr.isik_eesnimi_endine1),
          if(pr.isik_eesnimi_endine2='',NULL,pr.isik_eesnimi_endine2)
        ),
        if(pr.isa_eesnimi='',NULL,concat('isa eesnimi ',pr.isa_eesnimi)),
        if(pr.ema_eesnimi='',NULL,concat('ema eesnimi ',pr.ema_eesnimi)),
        if(pr.isik_sugu='',NULL,pr.isik_sugu)
      ),
      concat_ws(', ',
        if(pr.isik_synniaasta='',NULL,concat('Sünd: ', concat_ws('-',
          pr.isik_synniaasta,
          if(pr.isik_synnikuu='',NULL,LPAD(pr.isik_synnikuu, 2, '00')),
          if(pr.isik_synnipaev='',NULL,LPAD(pr.isik_synnipaev, 2, '00'))
        ))),
        if(pr.isik_synnikoht='',NULL,pr.isik_synnikoht),
        if(pr.isik_synniriik='',NULL,pr.isik_synniriik)
      ),
      if(pr.isik_surmaaasta='' AND pr.isik_surmakoht='' AND pr.isik_surmariik='', NULL,
        concat_ws(', ',
          if(pr.isik_surmaaasta='',NULL,concat('Surm: ', concat_ws('-',
            pr.isik_surmaaasta,
            if(pr.isik_surmakuu='',NULL,LPAD(pr.isik_surmakuu, 2, '00')),
            if(pr.isik_surmapaev='',NULL,LPAD(pr.isik_surmapaev, 2, '00'))
          ))),
          if(pr.isik_surmakoht='',NULL,pr.isik_surmakoht),
          if(pr.isik_surmariik='',NULL,pr.isik_surmariik)
        )
      ),
      concat('Raamat: ', pr.raamatu_omavalitsus, ' kd ', pr.koite_nr, ' lk ', pr.lk_nr),
      ''
    ) INTO @_kirje
    FROM import.pereregister pr
    WHERE pr.isikukood = _kirjekood2 COLLATE utf8_estonian_ci;

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
      d.created_by = _created_by
    WHERE pr.isikukood = _kirjekood2 COLLATE utf8_estonian_ci
      AND d.persoon = '';

  END;;
DELIMITER ;


DELIMITER ;; -- desktop_RK_import

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_RK_import(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';', rk.PERENIMI),
        concat_ws(';', rk.EESNIMI)
      )
    ) INTO @_kirje
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood2 COLLATE utf8_estonian_ci;

    UPDATE repis.desktop d
    LEFT JOIN import.repr_kart rk on rk.isikukood = d.kirjekood
    SET
      d.kirje = @_kirje,
      d.perenimi = rk.PERENIMI,
      d.eesnimi = rk.EESNIMI,
      d.sünd = rk.SA,
      d.surm = rk.Surm,
      d.legend = rk.otmetki,
      d.created_by = _created_by
    WHERE rk.isikukood = _kirjekood2 COLLATE utf8_estonian_ci
      AND d.persoon = '';

  END;;
DELIMITER ;


DELIMITER ;; -- desktop_RR_import

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_RR_import(
    IN _kirjekood1 CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    SELECT concat_ws('. ',
      concat_ws(', ',
        concat_ws(';', rr.PERENIMI),
        concat_ws(';', rr.EESNIMI),
        if(rr.isanimi='',NULL,concat('isa eesnimi ',rr.isanimi))
      ),
      if(rr.sünd='',NULL,concat('Sünd: ',rr.sünd)),
      if(rr.surm='',NULL,concat('Surm: ',rr.surm))
    ) INTO @_kirje
    FROM import.rahvastikuregister rr
    WHERE rr.kirjekood = _kirjekood2 COLLATE utf8_estonian_ci;

    UPDATE repis.desktop d
    LEFT JOIN import.rahvastikuregister rr on rr.kirjekood = d.kirjekood
    SET
      d.kirje = @_kirje,
      d.perenimi = rr.perenimi,
      d.eesnimi = rr.eesnimi,
      d.sünd = rr.sünd,
      d.surm = rr.surm,
      d.legend = concat_ws('; '
        , if(rr.sünnikoht='',NULL,concat('Sünnikoht: ',rr.sünnikoht))
        , if(rr.surmakoht='',NULL,concat('Surmakoht: ',rr.surmakoht))
        , if(rr.allika_id='',NULL,concat('Isikukood: ',rr.allika_id))
      ),
      d.created_by = _created_by
    WHERE rr.kirjekood = _kirjekood2 COLLATE utf8_estonian_ci
      AND d.persoon = '';

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
        INSERT INTO z_queue (task, params) values (code, concat_ws('; ', 'desktop_NK_refresh', msg));
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
            NULL, UPPER(d0.eesnimi))
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
        AND d0.Peatatud != '!'
        AND d0.EiArvesta != '!'
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
        ) COLLATE utf8_estonian_ci
    WHERE d.kirjekood = _persoon
      AND d.created_by = _created_by;

  END;;

DELIMITER ;


DELIMITER ;; -- desktop_join_persons

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_desktop_join_persons(
    IN _old_person CHAR(10), IN _new_person CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    UPDATE repis.desktop SET person = _new_person WHERE person = _old_person;

  END;;

DELIMITER ;
