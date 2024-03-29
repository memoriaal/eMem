
DELIMITER ;; -- func_kirjelipikud()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_kirjelipikud(
      _kirjekood CHAR(10)
  ) RETURNS TEXT CHARSET utf8 COLLATE  utf8_estonian_ci
  func_label:BEGIN

    SET @omad_lipikud = NULL, @teiste_lipikud = NULL;

    SELECT GROUP_CONCAT(kl.lipik SEPARATOR '; ') INTO @omad_lipikud
    FROM repis.v_kirjelipikud kl
    RIGHT JOIN repis.kirjed k ON k.kirjekood = kl.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND kl.deleted_at = '0000-00-00 00:00:00'
    AND kl.kirjekood = k0.kirjekood
    GROUP BY kl.kirjekood;

    SELECT GROUP_CONCAT(concat_ws(':', k.kirjekood, kl.lipik) SEPARATOR '; ') INTO @teiste_lipikud
    FROM repis.v_kirjelipikud kl
    RIGHT JOIN repis.kirjed k ON k.kirjekood = kl.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND kl.deleted_at = '0000-00-00 00:00:00'
    AND kl.kirjekood != k0.kirjekood
    GROUP BY k0.persoon;

    RETURN concat_ws('\n', @omad_lipikud, @teiste_lipikud);

  END;;

DELIMITER ;


DELIMITER ;; -- proc_add_lipik()

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.proc_add_lipik(
    IN _kirjekood1 CHAR(10),
    IN _lipik VARCHAR(50))
  proc_label:BEGIN

    SET @omad_lipikud = NULL, @teiste_lipikud = NULL;

    SELECT GROUP_CONCAT(kl.lipik SEPARATOR '; ') INTO @omad_lipikud
    FROM repis.v_kirjelipikud kl
    RIGHT JOIN repis.kirjed k ON k.kirjekood = kl.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND kl.deleted_at = '0000-00-00 00:00:00'
    AND kl.kirjekood = k0.kirjekood
    GROUP BY kl.kirjekood;

    SELECT GROUP_CONCAT(concat_ws(':', k.kirjekood, kl.lipik) SEPARATOR '; ') INTO @teiste_lipikud
    FROM repis.v_kirjelipikud kl
    RIGHT JOIN repis.kirjed k ON k.kirjekood = kl.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND kl.deleted_at = '0000-00-00 00:00:00'
    AND kl.kirjekood != k0.kirjekood
    GROUP BY k0.persoon;

    RETURN concat_ws('\n', @omad_lipikud, @teiste_lipikud);

  END;;

DELIMITER ;


DELIMITER ;; -- func_kirjesildid()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_kirjesildid(
      _kirjekood CHAR(10)
  ) RETURNS TEXT CHARSET utf8 COLLATE  utf8_estonian_ci
  func_label:BEGIN

    SET @omad_sildid = NULL, @teiste_sildid = NULL;

    SELECT GROUP_CONCAT(ks.silt SEPARATOR '; ') INTO @omad_sildid
    FROM repis.v_kirjesildid ks
    RIGHT JOIN repis.kirjed k ON k.kirjekood = ks.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND ks.deleted_at = '0000-00-00 00:00:00'
    AND ks.kirjekood = k0.kirjekood
    GROUP BY ks.kirjekood;

    SELECT GROUP_CONCAT(concat_ws(':', k.kirjekood, ks.silt) SEPARATOR '; ') INTO @teiste_sildid
    FROM repis.v_kirjesildid ks
    RIGHT JOIN repis.kirjed k ON k.kirjekood = ks.kirjekood
    RIGHT JOIN repis.kirjed k0 ON k0.persoon = k.persoon
    WHERE k0.kirjekood = _kirjekood
    AND ks.deleted_at = '0000-00-00 00:00:00'
    AND ks.kirjekood != k0.kirjekood
    GROUP BY k0.persoon;

    RETURN concat_ws('\n', @omad_sildid, @teiste_sildid);

  END;;

DELIMITER ;


DELIMITER ;;  -- func_unrepeat()

  CREATE OR REPLACE FUNCTION repis.func_unrepeat(
      _word VARCHAR(100),
      _level ENUM('soft', 'hard')
  ) RETURNS VARCHAR(100) CHARSET utf8 COLLATE utf8_estonian_ci
  BEGIN

      DECLARE i INTEGER;
      DECLARE _out VARCHAR(100);
      SET i = 0;
      SET _out = '';

      IF _level = 'hard' THEN
        SET _word = UPPER(_word);
      END IF;

      SET _word = REPLACE(_word, ' ', '');
      SET _word = REPLACE(_word, '-', '');
      SET _word = REPLACE(_word, 'TH', 'T');
      SET _word = REPLACE(_word, 'SH', 'S');
      SET _word = REPLACE(_word, 'CH', 'S');
      SET _word = REPLACE(_word, 'ZH', 'Z');
      SET _word = REPLACE(_word, 'TZ', 'Z');
      -- IF _level = 'hard' THEN
        SET _word = REPLACE(_word, 'S' , 'S');
        SET _word = REPLACE(_word, 'Z' , 'S');
        SET _word = REPLACE(_word, 'Ž' , 'S');
        SET _word = REPLACE(_word, 'C' , 'S');
        SET _word = REPLACE(_word, 'A', 'A');
        SET _word = REPLACE(_word, 'E', 'A');
        SET _word = REPLACE(_word, 'I', 'A');
        SET _word = REPLACE(_word, 'O', 'A');
        SET _word = REPLACE(_word, 'U', 'A');
        SET _word = REPLACE(_word, 'Õ', 'A');
        SET _word = REPLACE(_word, 'Ä', 'A');
        SET _word = REPLACE(_word, 'Ö', 'A');
        SET _word = REPLACE(_word, 'Ü', 'A');
      -- END IF;

      myloop: WHILE (i <= LENGTH(_word)) DO
          IF SUBSTRING(_word, i, 1) != SUBSTRING(_word, i+1, 1) THEN
            SET _out = concat(_out, SUBSTRING(_word, i, 1));
          END IF;
          SET i = i + 1;
      END WHILE;

      RETURN(_out);

  END;;

DELIMITER ;


DELIMITER ;;  -- unrepeat_kirjed()

  CREATE OR REPLACE PROCEDURE repis.unrepeat_kirjed()
  BEGIN

    UPDATE repis.kirjed SET eesnimiC = repis.func_unrepeat(upper(eesnimi), 'hard');
    UPDATE repis.kirjed SET perenimiC = repis.func_unrepeat(upper(perenimi), 'hard');
    UPDATE repis.kirjed SET isanimiC = repis.func_unrepeat(upper(isanimi), 'hard');
    UPDATE repis.kirjed SET emanimiC = repis.func_unrepeat(upper(emanimi), 'hard');

  END;;

DELIMITER ;


DELIMITER ;; -- func_kirje2persoon()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_kirje2persoon(
      _kirjekood CHAR(10)
  ) RETURNS CHAR(10) CHARSET utf8 COLLATE utf8_estonian_ci
  func_label:BEGIN

    SET @persoon = NULL;

    SELECT persoon INTO @persoon
    FROM repis.kirjed
    WHERE kirjekood = _kirjekood;

    RETURN @persoon;

  END;;

DELIMITER ;


DELIMITER ;; -- func_person_text()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_person_text(
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
      if(surm       = '', NULL, concat('Surm ', surm))
      -- , if(sugu = '', NULL, sugu)
    )
    INTO person_text
    FROM repis.kirjed
    WHERE kirjekood = _kirjekood;

    RETURN person_text;

  END;;

DELIMITER ;


DELIMITER ;; -- func_persoonikirjed()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_persoonikirjed(
      _persoonid VARCHAR(1000)
  ) RETURNS VARCHAR(4000) CHARSET utf8 COLLATE utf8_estonian_ci
  func_label:BEGIN

    DECLARE _rval VARCHAR(4000) DEFAULT NULL;
    DECLARE _ret_val VARCHAR(4000) DEFAULT NULL;
    DECLARE _persoon CHAR(10) DEFAULT NULL;

    do_this: LOOP
      SET _persoon = SUBSTRING_INDEX(_persoonid, ',', 1);

      SELECT group_concat(k0.kirjekood, ': ', k0.kirje SEPARATOR '\n') INTO _rval
      FROM repis.kirjed k0
      WHERE k0.persoon = _persoon
        AND k0.kirje != ''
        AND k0.persoon != k0.kirjekood
      GROUP BY k0.persoon;

      SET _ret_val = concat_ws('\n==\n', _ret_val, _rval);

      SET _persoonid = SUBSTRING(_persoonid, 12);

      IF _persoonid = '' THEN
        LEAVE do_this;
      END IF;
    END LOOP do_this;

    RETURN replace(_ret_val, '\r', '');
  END;;

DELIMITER ;


DELIMITER ;; -- func_next_id()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_next_id(
      _name VARCHAR(20)
  ) RETURNS INT(10) UNSIGNED
  func_label:BEGIN

    DECLARE _ret_val INT(10) UNSIGNED;

    INSERT INTO repis.counter (id, value) VALUES (_name, 1)
    ON DUPLICATE KEY UPDATE value = value + 1;

    SELECT value INTO _ret_val FROM repis.counter WHERE id = _name;

    RETURN _ret_val;
  END;;

DELIMITER ;


DELIMITER ;;
CREATE OR REPLACE PROCEDURE `RK_import`(
    IN _persoon CHAR(10), IN _kirjekood CHAR(10))
proc_label:BEGIN

    SELECT CASE WHEN rk.Sünniaeg = '' THEN rk.SA ELSE rk.Sünniaeg END INTO @_sünd
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    SELECT repis.desktop_person_text(
      rk.PERENIMI, rk.EESNIMI, rk.ISANIMI, rk.EMANIMI,
      @_sünd, rk.Surm
    ) INTO @_kirje_persoon
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    UPDATE import.repr_kart rk
       SET rk.persoon = _persoon
     WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    INSERT INTO repis.kirjed (persoon, kirjekood, Kirje, Perenimi, Eesnimi, Isanimi, Emanimi,
            Sünd, Surm, Allikas, legend,
            KirjePersoon,
            EesnimiC, PerenimiC, IsanimiC)
    SELECT _persoon, _kirjekood, @_kirje_persoon,
            ifnull(rk.PERENIMI, ''),
            ifnull(rk.EESNIMI, ''),
            ifnull(rk.ISANIMI, ''),
            ifnull(rk.EMANIMI, ''),
            CASE WHEN length(rk.Sünniaeg) = 0 THEN rk.SA ELSE rk.Sünniaeg END, rk.Surm, 'RK', rk.otmetki,
            @_kirje_persoon,
            ifnull(repis.func_unrepeat(upper(rk.EESNIMI)), ''),
            ifnull(repis.func_unrepeat(upper(rk.PERENIMI)), ''),
            ifnull(repis.func_unrepeat(upper(rk.ISANIMI)), '')
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood;
  END;;

DELIMITER ;


DELIMITER ;;
CREATE OR REPLACE PROCEDURE `PT_import`(
    IN _persoon CHAR(10), IN _kirjekood CHAR(10))
proc_label:BEGIN

    SELECT CASE WHEN rk.Sünniaeg = '' THEN rk.SA ELSE rk.Sünniaeg END INTO @_sünd
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    SELECT repis.desktop_person_text(
      rk.PERENIMI, rk.EESNIMI, rk.ISANIMI, rk.EMANIMI,
      @_sünd, rk.Surm
    ) INTO @_kirje_persoon
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    UPDATE import.repr_kart rk
       SET rk.persoon = _persoon
     WHERE rk.isikukood = _kirjekood COLLATE utf8_estonian_ci;

    INSERT INTO repis.kirjed (persoon, kirjekood, Kirje, Perenimi, Eesnimi, Isanimi, Emanimi,
            Sünd, Surm, Allikas, legend,
            KirjePersoon,
            EesnimiC, PerenimiC, IsanimiC)
    SELECT _persoon, _kirjekood, @_kirje_persoon,
            ifnull(rk.PERENIMI, ''),
            ifnull(rk.EESNIMI, ''),
            ifnull(rk.ISANIMI, ''),
            ifnull(rk.EMANIMI, ''),
            CASE WHEN length(rk.Sünniaeg) = 0 THEN rk.SA ELSE rk.Sünniaeg END, rk.Surm, 'RK', rk.otmetki,
            @_kirje_persoon,
            ifnull(repis.func_unrepeat(upper(rk.EESNIMI)), ''),
            ifnull(repis.func_unrepeat(upper(rk.PERENIMI)), ''),
            ifnull(repis.func_unrepeat(upper(rk.ISANIMI)), '')
    FROM import.repr_kart rk
    WHERE rk.isikukood = _kirjekood;
  END;;

DELIMITER ;


DELIMITER ;;
CREATE OR replace FUNCTION repis.`func_kivitekst`(
    _persoon CHAR(10)
  ) RETURNS VARCHAR(2000) CHARSET utf8 COLLATE utf8_estonian_ci
func_label:BEGIN

    DECLARE person_text VARCHAR(2000);

    SELECT concat_ws(' ',
        IF(eesnimi  = '', NULL, trim(eesnimi)),
        IF(perenimi = '', NULL, trim(perenimi)),
        concat_ws('–',
            LEFT(sünd, 4),
            if(surm='', '†', LEFT(surm, 4))
        )
    )
    INTO person_text
    FROM repis.kirjed
    WHERE persoon = _persoon AND kirjekood = persoon;

    RETURN person_text;
  END;;
DELIMITER ;


delimiter ;;

CREATE OR replace FUNCTION `func_rr_aadress`(
	`_aadress` VARCHAR(500)
)
RETURNS VARCHAR(500) CHARSET utf8 COLLATE utf8_estonian_ci
LANGUAGE SQL
NOT DETERMINISTIC
CONTAINS SQL
SQL SECURITY DEFINER
COMMENT ''
func_label:BEGIN

   RETURN REGEXP_REPLACE(
				  REGEXP_REPLACE(_aadress, '\\|+', ', ')
				, ', $', '');

END;;
  
delimiter ;
