CREATE OR REPLACE TABLE repis.a_kirjed (
  Persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  Kirjed mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (Persoon),
  CONSTRAINT a_kirjed_ibfk_1 FOREIGN KEY (Persoon) REFERENCES repis.kirjed (persoon) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE repis.a_lipikud (
  Persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  Lipikud mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (Persoon),
  CONSTRAINT a_lipikud_ibfk_1 FOREIGN KEY (Persoon) REFERENCES repis.kirjed (persoon) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE OR REPLACE TABLE repis.a_sildid (
  Persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  Sildid mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (Persoon),
  CONSTRAINT a_sildid_ibfk_1 FOREIGN KEY (Persoon) REFERENCES repis.kirjed (persoon) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;




DELIMITER ;; -- repis.aggr_kirjed
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE repis.aggr_kirjed(IN _kirjekood CHAR(10))
proc_label:BEGIN

    SET @persoon = NULL, @kirjed = NULL;

    SELECT k.persoon, group_concat(concat(vk.kirjekood, ': ', vk.kirje) SEPARATOR '\n') AS Kirjed
    INTO @persoon, @kirjed
    FROM repis.kirjed k
    LEFT JOIN repis.kirjed vk ON vk.persoon = k.persoon and vk.kirjekood != vk.persoon
    WHERE k.kirjekood = _kirjekood;

    IF @kirjed IS NULL THEN
      DELETE FROM repis.a_kirjed WHERE Persoon = @persoon;
    ELSE
      INSERT INTO repis.a_kirjed (persoon, kirjed)
      VALUES (@persoon, @kirjed)
      ON DUPLICATE KEY UPDATE persoon = @persoon, kirjed = @kirjed;
    END IF;

END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `init_kirjed`()
proc_label:BEGIN

    DECLARE _kirjekood CHAR(10);
    DECLARE _finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT kirjekood FROM repis.kirjed
        WHERE persoon = kirjekood;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

    OPEN cur1;
    read_loop: LOOP

        IF _finished = 1 THEN
            LEAVE read_loop;
        END IF;

        FETCH cur1 INTO _kirjekood;
        CALL repis.aggr_kirjed(_kirjekood);

    END LOOP;
    CLOSE cur1;
    SET _finished = 0;

END;;
DELIMITER ;

call repis.init_kirjed();
DROP PROCEDURE repis.init_kirjed;

--
-- a_lipikud
--

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE repis.aggr_lipikud(IN _kirjekood CHAR(10))
proc_label:BEGIN

    SET @persoon = NULL, @lipikud = NULL;

    SELECT k.persoon, group_concat(DISTINCT vl.lipik SEPARATOR '; \n') AS Lipikud
    INTO @persoon, @lipikud
    FROM repis.v_kirjelipikud vl
    RIGHT JOIN repis.kirjed k ON vl.kirjekood IN (k.kirjekood, k.persoon)
    WHERE k.kirjekood = _kirjekood;

    IF @lipikud IS NULL THEN
      DELETE FROM repis.a_lipikud WHERE Persoon = @persoon;
    ELSE
      INSERT INTO repis.a_lipikud (persoon, lipikud)
      VALUES (@persoon, @lipikud)
      ON DUPLICATE KEY UPDATE persoon = @persoon, lipikud = @lipikud;
    END IF;

    -- CALL repis.aggr_persoonid(@persoon);

END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `init_a_lipikud`()
proc_label:BEGIN

    DECLARE _kirjekood CHAR(10);
    DECLARE _finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT kirjekood FROM repis.v_kirjelipikud WHERE deleted_at = '0000-00-00 00:00:00';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

    OPEN cur1;
    read_loop: LOOP

        IF _finished = 1 THEN
            LEAVE read_loop;
        END IF;

        FETCH cur1 INTO _kirjekood;
        CALL repis.aggr_lipikud(_kirjekood);

    END LOOP;
    CLOSE cur1;
    SET _finished = 0;

END;;
DELIMITER ;

call repis.init_a_lipikud();
DROP PROCEDURE repis.init_a_lipikud;

--
-- a_sildid
--

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE repis.aggr_sildid(IN _kirjekood CHAR(10))
proc_label:BEGIN

    SET @persoon = NULL, @sildid = NULL;

    SELECT k.persoon, group_concat(DISTINCT vl.silt SEPARATOR '; \n') AS Sildid
    INTO @persoon, @sildid
    FROM repis.v_kirjesildid vl
    RIGHT JOIN repis.kirjed k ON vl.kirjekood IN (k.kirjekood, k.persoon)
    WHERE k.kirjekood = _kirjekood;


    IF @sildid IS NULL THEN
      DELETE FROM repis.a_sildid WHERE Persoon = @persoon;
    ELSE
      INSERT INTO repis.a_sildid (persoon, sildid)
      VALUES (@persoon, @sildid)
      ON DUPLICATE KEY UPDATE persoon = @persoon, sildid = @sildid;
    END IF;

    -- CALL repis.aggr_persoonid(@persoon);

END;;
DELIMITER ;

DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE `init_a_sildid`()
proc_label:BEGIN

    DECLARE _kirjekood CHAR(10);
    DECLARE _finished INTEGER DEFAULT 0;

    DECLARE cur1 CURSOR FOR
        SELECT kirjekood FROM repis.v_kirjesildid WHERE deleted_at = '0000-00-00 00:00:00';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET _finished = 1;

    OPEN cur1;
    read_loop: LOOP

        IF _finished = 1 THEN
            LEAVE read_loop;
        END IF;

        FETCH cur1 INTO _kirjekood;
        CALL repis.aggr_sildid(_kirjekood);

    END LOOP;
    CLOSE cur1;
    SET _finished = 0;

END;;
DELIMITER ;

call repis.init_a_sildid();
DROP PROCEDURE repis.init_a_sildid;



--
-- Init repis.a_persoonid
--
CREATE OR REPLACE TABLE repis.a_persoonid (
  persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Kirjed mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  Lipikud mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  Sildid mediumtext COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY persoon (persoon),
  CONSTRAINT a_persoonid_ibfk_1 FOREIGN KEY (persoon) REFERENCES repis.kirjed (persoon) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
AS
  SELECT kn.persoon, kn.perenimi, kn.eesnimi, kn.isanimi, kn.emanimi, kn.sünd, kn.surm
       , k.kirjed as Kirjed
       , l.lipikud as Lipikud
       , s.sildid as Sildid
  FROM kirjed kn
  LEFT JOIN a_kirjed k ON k.persoon = kn.persoon
  LEFT JOIN a_lipikud l ON l.persoon = kn.persoon
  LEFT JOIN a_sildid s ON s.persoon = kn.persoon
  WHERE kn.allikas = 'Persoon'
  AND kn.persoon IS NOT NULL;


DELIMITER ;;
CREATE OR REPLACE DEFINER=`queue`@`localhost` PROCEDURE repis.aggr_persoonid(IN _persoon CHAR(10))
proc_label:BEGIN

    SELECT kn.persoon, kn.perenimi, kn.eesnimi, kn.isanimi, kn.emanimi, kn.sünd, kn.surm
         , k.kirjed AS Kirjed
         , l.lipikud AS Lipikud
         , s.sildid AS Sildid
    INTO @persoon, @perenimi, @eesnimi, @isanimi, @emanimi, @sünd, @surm
         , @kirjed, @lipikud, @sildid
    FROM kirjed kn
    LEFT JOIN a_kirjed k ON k.persoon = kn.persoon
    LEFT JOIN a_lipikud l ON l.persoon = kn.persoon
    LEFT JOIN a_sildid s ON s.persoon = kn.persoon
    WHERE kn.kirjekood = _persoon;

    INSERT INTO repis.a_persoonid
    VALUES (@persoon, @perenimi, @eesnimi
         , @isanimi, @emanimi, @sünd, @surm
         , @kirjed, @lipikud, @sildid)
    ON DUPLICATE KEY
    UPDATE persoon = @persoon, perenimi = @perenimi, eesnimi = @eesnimi
         , isanimi = @isanimi, emanimi = @emanimi, sünd = @sünd, surm = @surm
         , kirjed = @kirjed, lipikud = @lipikud, sildid = @sildid;

END;;
DELIMITER ;


--
-- Triggers
--
DELIMITER ;; -- repis.kirjed_AI
  CREATE OR REPLACE TRIGGER repis.kirjed_AI AFTER INSERT ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(NEW.persoon);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.kirjed_AU
  CREATE OR REPLACE TRIGGER repis.kirjed_AU AFTER UPDATE ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(OLD.persoon);
    CALL repis.aggr_kirjed(NEW.persoon);
    CALL repis.aggr_lipikud(OLD.persoon);
    CALL repis.aggr_lipikud(NEW.persoon);
    CALL repis.aggr_sildid(OLD.persoon);
    CALL repis.aggr_sildid(NEW.persoon);
    CALL repis.aggr_persoonid(OLD.persoon);
    CALL repis.aggr_persoonid(NEW.persoon);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.kirjed_AD
  CREATE OR REPLACE TRIGGER repis.kirjed_AD AFTER DELETE ON repis.kirjed FOR EACH ROW
  BEGIN
    CALL repis.aggr_kirjed(OLD.persoon);
    CALL repis.aggr_lipikud(OLD.persoon);
    CALL repis.aggr_sildid(OLD.persoon);
  END;;
DELIMITER ;


DELIMITER ;; -- repis.v_kirjesildid_AI
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AI AFTER INSERT ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_sildid(NEW.kirjekood);
    CALL repis.aggr_persoonid(NEW.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjesildid_AU
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AU AFTER UPDATE ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_sildid(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjesildid_AD
  CREATE OR REPLACE TRIGGER repis.v_kirjesildid_AD AFTER DELETE ON v_kirjesildid FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;


DELIMITER ;; -- repis.v_kirjelipikud_AI
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AI AFTER INSERT ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(NEW.kirjekood);
    CALL repis.aggr_persoonid(NEW.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjelipikud_AU
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AU AFTER UPDATE ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;
DELIMITER ;; -- repis.v_kirjelipikud_AD
  CREATE OR REPLACE TRIGGER repis.v_kirjelipikud_AD AFTER DELETE ON v_kirjelipikud FOR EACH ROW
  BEGIN
    CALL repis.aggr_lipikud(OLD.kirjekood);
    CALL repis.aggr_persoonid(OLD.kirjekood);
  END;;
DELIMITER ;



DROP TRIGGER repis.kirjed_AI;
DROP TRIGGER repis.kirjed_AU;
DROP TRIGGER repis.kirjed_AD;
DROP TRIGGER repis.v_kirjesildid_AI;
DROP TRIGGER repis.v_kirjesildid_AU;
DROP TRIGGER repis.v_kirjesildid_AD;
DROP TRIGGER repis.v_kirjelipikud_AI;
DROP TRIGGER repis.v_kirjelipikud_AU;
DROP TRIGGER repis.v_kirjelipikud_AD;
