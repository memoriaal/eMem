
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


DELIMITER ;;  -- unrepeat

  CREATE OR REPLACE FUNCTION repis.func_unrepeat(
      _word VARCHAR(100),
      _level ENUM('soft', 'hard')
  ) RETURNS VARCHAR(100) CHARSET utf8 COLLATE utf8_estonian_ci
  BEGIN

      DECLARE i INTEGER;
      DECLARE _out VARCHAR(100);
      SET i = 0;
      SET _out = '';

      SET _word = REPLACE(_word, 'TH', 'T');
      SET _word = REPLACE(_word, 'SH', 'Š');
      SET _word = REPLACE(_word, 'CH', 'Š');
      SET _word = REPLACE(_word, 'ZH', 'Z');
      SET _word = REPLACE(_word, 'TZ', 'Z');
      IF _level = 'hard' THEN
        SET _word = REPLACE(_word, 'S' , 'Š');
        SET _word = REPLACE(_word, 'Z' , 'Š');
        SET _word = REPLACE(_word, 'Ž' , 'Š');
        SET _word = REPLACE(_word, 'C' , 'Š');
        SET _word = REPLACE(_word, 'A', 'Ẵ');
        SET _word = REPLACE(_word, 'E', 'Ẵ');
        SET _word = REPLACE(_word, 'I', 'Ẵ');
        SET _word = REPLACE(_word, 'O', 'Ẵ');
        SET _word = REPLACE(_word, 'U', 'Ẵ');
        SET _word = REPLACE(_word, 'Õ', 'Ẵ');
        SET _word = REPLACE(_word, 'Ä', 'Ẵ');
        SET _word = REPLACE(_word, 'Ö', 'Ẵ');
        SET _word = REPLACE(_word, 'Ü', 'Ẵ');
      END IF;

      myloop: WHILE (i <= LENGTH(_word)) DO
          IF SUBSTRING(_word, i, 1) != SUBSTRING(_word, i+1, 1) THEN
            SET _out = concat(_out, SUBSTRING(_word, i, 1));
          END IF;
          SET i = i + 1;
      END WHILE;

      RETURN(_out);

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


DELIMITER ;; -- func_persoonikirjed()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.func_persoonikirjed(
      _persoon CHAR(10)
  ) RETURNS VARCHAR(4000) CHARSET utf8 COLLATE utf8_estonian_ci
  func_label:BEGIN

  DECLARE _ret_val VARCHAR(4000);

  SELECT group_concat(k0.kirjekood, ': ', k0.kirje SEPARATOR '\n') INTO _ret_val
  FROM repis.kirjed k0
  WHERE k0.persoon = _persoon
    AND k0.kirje != ''
    AND k0.persoon != k0.kirjekood
  GROUP BY k0.persoon;

  RETURN _ret_val;
  END;;

DELIMITER ;
