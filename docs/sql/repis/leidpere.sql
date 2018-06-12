UPDATE repis.kirjed k
-- SELECT k2.rp, k.* FROM repis.kirjed k
LEFT JOIN (
  SELECT persoon,
         group_concat(DISTINCT IF(RaamatuPere = '', NULL, RaamatuPere) ORDER BY raamatupere) rp
  FROM repis.kirjed
  WHERE allikas != 'persoon'
  GROUP BY persoon
) k2 ON k2.persoon = k.kirjekood
SET k.raamatupere = k2.rp
WHERE k.allikas = 'persoon'
  AND k2.rp IS NOT NULL;


SET @m = 100000;
CREATE OR REPLACE TABLE repis.tmp
SELECT k.*, @m := @m+1 AS nr
FROM (
  SELECT DISTINCT raamatupere
  FROM repis.kirjed
  WHERE raamatupere != ''
  AND allikas = 'persoon'
) AS k;

ALTER TABLE repis.tmp ADD PRIMARY KEY (`raamatupere`);

UPDATE repis.tmp SET repis.tmp.nr = '102273' WHERE (raamatupere='R5-0240,R5-4715,R5-7595');
UPDATE repis.tmp SET repis.tmp.nr = '112741' WHERE (raamatupere='R5-5851,R62-0877,R62-1209');

--
-- do this twice
--
SELECT t2.*, t1.* FROM tmp t2
-- UPDATE tmp t2
RIGHT JOIN tmp t1 ON t1.raamatupere REGEXP t2.raamatupere
                 AND t1.raamatupere != t2.raamatupere
                 AND t2.nr != t1.nr
-- SET t2.nr = t1.nr
WHERE t2.raamatupere IS NOT NULL;


UPDATE repis.kirjed k
LEFT JOIN repis.tmp t ON t.raamatupere = k.raamatupere
SET k.leidpere = t.nr;

UPDATE repis.kirjed k
RIGHT JOIN repis.kirjed k1 ON k1.persoon = k.persoon
SET k.leidpere = k1.leidpere
WHERE k1.allikas = 'persoon'
AND k.allikas != 'persoon'
AND k1.leidpere IS NOT NULL;

--
-- Perelaud
--
CREATE OR REPLACE TABLE `perelaud` (
  persoon char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  valmis enum('','Valmis','Untsus') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  koondkirje text COLLATE utf8_estonian_ci NOT NULL,
  raamatupere varchar(200) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  leidpere int(10) unsigned DEFAULT NULL,
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  PRIMARY KEY (persoon,created_by),
  UNIQUE KEY id (id),
  CONSTRAINT perelaud_ibfk_1 FOREIGN KEY (persoon) REFERENCES kirjed (kirjekood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- Triggers
--
DELIMITER ;; -- perelaud_BI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.perelaud_BI BEFORE INSERT ON repis.perelaud FOR EACH ROW
  proc_label:BEGIN

    IF NEW.koondkirje = '' THEN
      IF NEW.created_by = '' THEN
        SET NEW.created_by = user();
      END IF;

      SELECT group_concat(k.kirjekood, ': ', k.kirje SEPARATOR '; \n')
           , k1.raamatupere
           , k1.leidpere
      INTO @koondkirje, @raamatupere, @leidpere
      FROM repis.kirjed AS k1
      RIGHT JOIN repis.kirjed k ON k.persoon = k1.persoon
      WHERE k1.kirjekood = NEW.persoon
      GROUP BY k.persoon;

      SET NEW.koondkirje = @koondkirje;
      SET NEW.raamatupere = @raamatupere;
      SET NEW.leidpere = @leidpere;

    END IF;

  END;;

DELIMITER ;


DELIMITER ;; -- perelaud_AI

  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.perelaud_AI AFTER INSERT ON repis.perelaud FOR EACH ROW
  proc_label:BEGIN

    INSERT IGNORE INTO repis.z_queue (kirjekood1,  kirjekood2, task,               params, created_by)
    VALUES                           (NEW.persoon, NULL,       'perelaud_collect', NULL,   NEW.created_by);

  END;;

DELIMITER ;


--
-- functions
--
DELIMITER ;; -- perelaud_next_id()

  CREATE OR REPLACE DEFINER=queue@localhost FUNCTION repis.perelaud_next_id(
      _allikas VARCHAR(50)
  ) RETURNS CHAR(10) CHARSET utf8
  func_label:BEGIN

    SELECT lühend INTO @c FROM repis.allikad WHERE kood = _allikas;

    SET @max_k = NULL;
    SELECT max(LeidPere) INTO @max_k
    FROM repis.kirjed;

    SET @max_d = NULL;
    SELECT max(LeidPere) INTO @max_d
    FROM repis.perelaud;

    RETURN if(@max_d < @max_k, @max_k, @max_d);
  END;;

DELIMITER ;


--
-- Procedures
--
DELIMITER ;; -- perelaud_collect

  CREATE OR REPLACE DEFINER=queue@localhost PROCEDURE repis.q_perelaud_collect(
    IN _persoon CHAR(10), IN _kirjekood2 CHAR(10),
    IN _task VARCHAR(50), IN _params VARCHAR(200), IN _created_by VARCHAR(50))
  proc_label:BEGIN

    IF _persoon = '' THEN
      LEAVE proc_label;
    END IF;

    INSERT IGNORE INTO repis.perelaud(persoon, created_by)
    SELECT DISTINCT k1.persoon, _created_by
      FROM repis.kirjed AS k
      LEFT JOIN repis.kirjed k1 ON k.leidpere = k1.leidpere
     WHERE k.persoon = _persoon
       AND k1.persoon != k.persoon
       AND k.leidpere IS NOT NULL;

  END;;

DELIMITER ;