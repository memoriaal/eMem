DROP TABLE IF EXISTS repis.v_kirjesildid;
DROP TABLE IF EXISTS repis.v_kirjelipikud;
DROP TABLE IF EXISTS c_sildid;
DROP TABLE IF EXISTS c_lipikud;

DROP TABLE IF EXISTS repis.seosed;

DROP TABLE IF EXISTS kirjed;
DROP TABLE IF EXISTS allikad;

CREATE TABLE repis.allikad (
  `id` int(10) unsigned NOT NULL DEFAULT 0,
  `nonPerson` tinyint(1) DEFAULT NULL,
  `Allikas` varchar(255) DEFAULT NULL,
  `Nimetus` varchar(255) DEFAULT NULL,
  `Kood` varchar(255) DEFAULT NULL,
  `Lühend` char(10) DEFAULT NULL,
  `Avaldatud` varchar(255) DEFAULT NULL,
  `Nimekiri` varchar(255) DEFAULT NULL,
  `Kirjeid allikas` varchar(255) DEFAULT NULL,
  `Kirjeid imporditud` varchar(255) DEFAULT NULL,
  `Kirjeldus` varchar(255) DEFAULT NULL,
  `Andmeväljad` varchar(255) DEFAULT NULL,
  `Kommentaar` varchar(255) DEFAULT NULL,
  `prioriteetPerenimi` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetEesnimi` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetIsanimi` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetEmanimi` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetSünd` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetSurm` int(5) unsigned NOT NULL DEFAULT 10000,
  `prioriteetKirje` int(5) unsigned NOT NULL DEFAULT 10000,
  KEY `Kood` (`Kood`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT * FROM kylli.allikad;

INSERT INTO repis.allikad
  (`id`, `nonPerson`, `Allikas`, `Nimetus`, `Kood`, `Avaldatud`, `Nimekiri`,
    `Kirjeid allikas`, `Kirjeid imporditud`, `Kirjeldus`, `Andmeväljad`,
    `Kommentaar`, `prioriteetPerenimi`, `prioriteetEesnimi`,
    `prioriteetIsanimi`, `prioriteetEmanimi`, `prioriteetSünd`,
    `prioriteetSurm`, `prioriteetKirje`)
VALUES
  ('0', 1, 'testkirjed', 'test', 'TEST', NULL, NULL,
    NULL, NULL, 'testimiseks', NULL,
    'testimiseks', '0', '0', '0', '0', '0', '0', '0');

UPDATE allikad SET Kood = 'Persoon', lühend = '' WHERE Kood = 'Nimekujud' LIMIT 1;


CREATE TABLE repis.kirjed (
  persoon     char(10)                  DEFAULT NULL,
  kirjekood   char(10)         NOT NULL DEFAULT '',
  emi_id      int(11) unsigned          DEFAULT NULL,
  Kirje       text             NOT NULL DEFAULT '',
  Perenimi    varchar(50)      NOT NULL DEFAULT '',
  Eesnimi     varchar(50)      NOT NULL DEFAULT '',
  Isanimi     varchar(50)      NOT NULL DEFAULT '',
  Emanimi     varchar(50)      NOT NULL DEFAULT '',
  Sünd        varchar(50)      NOT NULL DEFAULT '',
  Surm        varchar(50)      NOT NULL DEFAULT '',
  Sildid      text             NOT NULL DEFAULT '',
  Lipikud     text             NOT NULL DEFAULT '',
  RaamatuPere varchar(20)      NOT NULL DEFAULT '',
  LeidPere    int(10) unsigned          DEFAULT NULL,
  Sugu        enum('M','N','') NOT NULL DEFAULT '',
  Rahvus      varchar(50)      NOT NULL DEFAULT '',
  Välisviide  varchar(2000)    NOT NULL DEFAULT '',
  Kommentaar  varchar(2000)    NOT NULL DEFAULT '',
  Allikas     varchar(20)      NOT NULL DEFAULT '',
  Nimekiri    varchar(50)      NOT NULL DEFAULT '',
  Puudulik    enum('','!')     NOT NULL DEFAULT '',
  EkslikKanne enum('','!')     NOT NULL DEFAULT '',
  Peatatud    enum('','!')     NOT NULL DEFAULT '',
  EiArvesta   enum('','!')     NOT NULL DEFAULT '',
  kustuta     char(1)                   DEFAULT NULL,
  created_at  timestamp            NULL DEFAULT current_timestamp(),
  created_by  varchar(50)               DEFAULT NULL,
  updated_at  timestamp            NULL DEFAULT NULL ON UPDATE current_timestamp(),
  updated_by  varchar(50)               DEFAULT NULL,
  UNIQUE  KEY (kirjekood),
          KEY persoon_persoon (persoon),
          KEY persoon_allikas (Allikas),
          KEY persoon_emi_id (emi_id),
  CONSTRAINT  kirjed_persoon_fk_kirjed_kirjekood
              FOREIGN KEY (persoon)
              REFERENCES repis.kirjed (kirjekood)
              ON UPDATE CASCADE,
  CONSTRAINT  kirjed_allika_fk_allikas_kood
              FOREIGN KEY (Allikas)
              REFERENCES repis.allikad (Kood)
              ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;


--
-- 35 sec
--
INSERT INTO repis.kirjed (
        persoon
      , kirjekood
      , emi_id
      , Kirje
      , Perenimi
      , Eesnimi
      , Isanimi
      , Emanimi
      , Sünd
      , Surm
      , RaamatuPere
      , Sugu
      , Rahvus
      , Välisviide
      , Allikas
      , Kommentaar
      , Nimekiri
      , Puudulik
      , EkslikKanne
      , Peatatud
      , kustuta
      , created_at
      , updated_at
      , created_by
)
SELECT  NULL
      , replace(Isikukood, 'NK-', '000') AS persoon
      , emi_id
      , Kirje
      , Perenimi
      , Eesnimi
      , Isanimi
      , Emanimi
      , Sünd
      , Surm
      , Perekood
      , Sugu
      , Rahvus
      , Välisviide
      , replace(Allikas, 'Nimekujud', 'Persoon') as allikas
      , Kommentaar
      , Nimekiri
      , Puudulik
      , EkslikKanne
      , Peatatud
      , kustuta
      , created
      , updated
      , user
from kylli.kirjed k
;


--
-- 33 sec
--
UPDATE repis.kirjed k1
RIGHT JOIN repis.kirjed k0 ON k0.emi_id = k1.emi_id
  SET k1.persoon = k0.kirjekood
WHERE k0.allikas = 'Persoon'
;


--
-- 21 sec
--
ALTER TABLE repis.kirjed DROP emi_id;


--
-- Kirjed Triggers
--
DELIMITER ;;

  --
  -- kirjed_BI
  --
  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.kirjed_BI BEFORE INSERT ON repis.kirjed FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg VARCHAR(2000);

    IF NEW.created_by != SUBSTRING_INDEX(user(), '@', 1) THEN
      SELECT concat_ws('\n'
        , 'Kirjeid saab lisada ainult töölaualt.'
      ) INTO msg;
      SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
    END IF;

  END;;

  --
  -- kirjed_BU
  --
  CREATE OR REPLACE DEFINER=queue@localhost  TRIGGER repis.kirjed_BU BEFORE UPDATE ON repis.kirjed FOR EACH ROW
  proc_label:BEGIN

    DECLARE msg VARCHAR(2000);

    IF user() NOT IN ('kylli.localhost', 'michelek@localhost') THEN

      IF NEW.kommentaar != OLD.kommentaar THEN
        SET NEW.persoon = OLD.persoon
          , NEW.kirjekood = OLD.kirjekood
          , NEW.perenimi = OLD.perenimi
          , NEW.eesnimi = OLD.eesnimi
          , NEW.isanimi = OLD.isanimi
          , NEW.emanimi = OLD.emanimi
          , NEW.sünd = OLD.sünd
          , NEW.surm = OLD.surm
          , NEW.updated_at = now()
          , NEW.updated_by = SUBSTRING_INDEX(user(), '@', 1);
      ELSE
        IF NEW.updated_by != SUBSTRING_INDEX(user(), '@', 1) THEN
          SELECT concat_ws('\n'
            , 'Kirjeid saab muuta ainult töölaual.'
          ) INTO msg;
          SIGNAL SQLSTATE '03100' SET MESSAGE_TEXT = msg;
        END IF;

      END IF;

    END IF;

  END;;

DELIMITER ;


--
-- sildid/lipikud klassifikaatorid
--
DROP TABLE IF EXISTS repis.v_kirjesildid;
DROP TABLE IF EXISTS repis.v_kirjelipikud;

DROP TABLE IF EXISTS c_sildid;
DROP TABLE IF EXISTS c_lipikud;

CREATE TABLE c_sildid (
  silt varchar(50) NOT NULL DEFAULT '',
  selgitus text  DEFAULT NULL,
  PRIMARY KEY (silt)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

CREATE TABLE c_lipikud (
  lipik varchar(50) NOT NULL DEFAULT '',
  selgitus text  DEFAULT NULL,
  PRIMARY KEY (lipik)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci;

INSERT INTO repis.c_sildid (silt, selgitus)
SELECT silt, selgitus FROM kylli.sildid;

INSERT INTO repis.c_lipikud (lipik, selgitus)
SELECT lipik, päring FROM kylli.lipikud;

--
-- sildid/lipikud väärtused
--

CREATE TABLE repis.v_kirjesildid (
  kirjekood char(10) NOT NULL DEFAULT '',
  silt varchar(50) NOT NULL DEFAULT '',
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) NOT NULL DEFAULT '',
  deleted_at timestamp NULL DEFAULT NULL,
  deleted_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,silt,deleted_at),
  KEY silt (silt),
  CONSTRAINT v_kirjesildid_ibfk_1 FOREIGN KEY (silt) REFERENCES c_sildid (silt),
  CONSTRAINT v_kirjesildid_ibfk_2 FOREIGN KEY (kirjekood) REFERENCES kirjed (kirjekood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT replace(ks.kirjekood, 'NK-', '000') AS kirjekood,
       ks.silt AS silt,
       ks.created AS created_at,
       ks.user AS created_by,
       if(ks.kustutatud = 1, now(), NULL) AS deleted_at,
       '' AS deleted_by
FROM kylli.kirjesildid ks;

CREATE TABLE repis.v_kirjelipikud (
  kirjekood char(10) NOT NULL DEFAULT '',
  lipik varchar(50) NOT NULL DEFAULT '',
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) NOT NULL DEFAULT '',
  deleted_at timestamp NULL DEFAULT NULL,
  deleted_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,lipik,deleted_at),
  KEY lipik (lipik),
  CONSTRAINT v_kirjelipikud_ibfk_1 FOREIGN KEY (lipik) REFERENCES c_lipikud (lipik),
  CONSTRAINT v_kirjelipikud_ibfk_2 FOREIGN KEY (kirjekood) REFERENCES kirjed (kirjekood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT replace(k.kirjekood, 'NK-', '000') AS kirjekood,
       k.lipik AS lipik,
       k.created AS created_at,
       k.user AS created_by,
       if(k.kustutatud = 1, now(), NULL) AS deleted_at,
       '' AS deleted_by
FROM kylli.kirjelipikud k;



--
-- seosed
--

DROP TABLE IF EXISTS repis.seosed;
DROP TABLE IF EXISTS repis.c_seoseliigid;

CREATE TABLE repis.c_seoseliigid (
  seoseliik varchar(50) NOT NULL DEFAULT '',
  sugu enum('','M','N') NOT NULL DEFAULT '',
  sugu_1 enum('','M','N','=','X') DEFAULT NULL,
  seoseliik_1M varchar(50) DEFAULT NULL,
  seoseliik_1N varchar(50) DEFAULT NULL,
  seoseliik_1X varchar(50) DEFAULT NULL,
  PRIMARY KEY (seoseliik),
  KEY seoseliik_1 (seoseliik_1M),
  KEY seoseliik_1N (seoseliik_1N),
  KEY seoseliik_1X (seoseliik_1X)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT * FROM kylli.seoseliigid;

ALTER TABLE c_seoseliigid ADD FOREIGN KEY (seoseliik_1M) REFERENCES c_seoseliigid (seoseliik) ON UPDATE CASCADE;
ALTER TABLE c_seoseliigid ADD FOREIGN KEY (seoseliik_1N) REFERENCES c_seoseliigid (seoseliik) ON UPDATE CASCADE;
ALTER TABLE c_seoseliigid ADD FOREIGN KEY (seoseliik_1X) REFERENCES c_seoseliigid (seoseliik) ON UPDATE CASCADE;



CREATE TABLE repis.seosed (
  id int(11) unsigned NOT NULL AUTO_INCREMENT,
  kirjekood1 char(10) NOT NULL DEFAULT '',
  seos varchar(50)  DEFAULT NULL,
  vastasseos varchar(50)  DEFAULT NULL,
  kirjekood2 char(10) NOT NULL DEFAULT '',
  created_at datetime NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY kirjekood1 (kirjekood1,seos,vastasseos,kirjekood2),
  KEY seos (seos),
  KEY vastasseos (vastasseos),
  KEY kirjekood2 (kirjekood2),
  KEY kirjekood1_2 (kirjekood1,kirjekood2,seos),
  CONSTRAINT seosed_ibfk_1 FOREIGN KEY (seos) REFERENCES c_seoseliigid (seoseliik) ON UPDATE CASCADE,
  CONSTRAINT seosed_ibfk_4 FOREIGN KEY (vastasseos) REFERENCES c_seoseliigid (seoseliik) ON UPDATE CASCADE,
  CONSTRAINT seosed_ibfk_5 FOREIGN KEY (kirjekood1) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE,
  CONSTRAINT seosed_ibfk_6 FOREIGN KEY (kirjekood2) REFERENCES kirjed (kirjekood) ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci

SELECT NULL AS id,
      replace(isikukood1, 'NK-', '000') AS kirjekood1,
      seos AS seos,
      vastasseos AS vastasseos,
      replace(isikukood2, 'NK-', '000') AS kirjekood2,
      timestamp AS created_at,
      user AS created_by
FROM kylli.seosed
WHERE seos != 'sama isik';
