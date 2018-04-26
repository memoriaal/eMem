DROP TABLE IF EXISTS repis.v_kirjesildid;
DROP TABLE IF EXISTS repis.v_kirjelipikud;
DROP TABLE IF EXISTS c_sildid;
DROP TABLE IF EXISTS c_lipikud;

DROP TABLE IF EXISTS repis.seosed;

DROP TABLE IF EXISTS kirjed;
DROP TABLE IF EXISTS allikad;
DROP TABLE IF EXISTS sildid;
DROP TABLE IF EXISTS lipikud;

CREATE TABLE repis.allikad (
  `id` int(10) unsigned NOT NULL DEFAULT 0,
  `nonPerson` tinyint(1) DEFAULT NULL,
  `Allikas` varchar(255) DEFAULT NULL,
  `Nimetus` varchar(255) DEFAULT NULL,
  `Kood` varchar(255) DEFAULT NULL,
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


CREATE TABLE repis.kirjed (
  persoon char(10) COLLATE utf8_estonian_ci DEFAULT NULL,
  kirjekood char(10) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  emi_id int(11) unsigned DEFAULT NULL,
  Kirje text COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Perenimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Eesnimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Isanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Emanimi varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Sünd varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Surm varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Perekood varchar(20) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Sugu enum('M','N','') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Rahvus varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Allikas varchar(20) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Nimekiri varchar(50) COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Puudulik enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  EkslikKanne enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  Peatatud enum('','!') COLLATE utf8_estonian_ci NOT NULL DEFAULT '',
  kustuta char(1) COLLATE utf8_estonian_ci DEFAULT NULL,
  created timestamp NULL DEFAULT current_timestamp(),
  updated timestamp NULL DEFAULT NULL ON UPDATE current_timestamp(),
  user varchar(50) COLLATE utf8_estonian_ci DEFAULT NULL,
  PRIMARY KEY (kirjekood),
  KEY persoon (persoon),
  KEY emi_id (emi_id),
  CONSTRAINT kirjed_ibfk_1 FOREIGN KEY (persoon) REFERENCES repis.kirjed (kirjekood) ON UPDATE CASCADE,
  CONSTRAINT kirjed_ibfk_2 FOREIGN KEY (Allikas) REFERENCES repis.allikad (Kood) ON UPDATE CASCADE
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
      , Perekood
      , Sugu
      , Rahvus
      , Allikas
      , Nimekiri
      , Puudulik
      , EkslikKanne
      , Peatatud
      , kustuta
      , created
      , updated
      , user
)
SELECT  NULL
      , Isikukood
      , emi_id
      , Kirje
      , Perenimi
      , Eesnimi
      , Isanimi
      , Emanimi
      , Sünd
      , Surm
      , Sugu
      , Rahvus
      , Perekood
      , Allikas
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
WHERE k0.allikas = 'Nimekujud'
;


--
-- 21 sec
--
ALTER TABLE repis.kirjed DROP emi_id;


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
  PRIMARY KEY (kirjekood,silt),
  KEY silt (silt),
  CONSTRAINT v_kirjesildid_ibfk_1 FOREIGN KEY (silt) REFERENCES c_sildid (silt),
  CONSTRAINT v_kirjesildid_ibfk_2 FOREIGN KEY (kirjekood) REFERENCES kirjed (kirjekood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT ks.kirjekood AS kirjekood,
       ks.silt AS silt,
       ks.created AS created_at,
       ks.user AS created_by,
       if(ks.kustutatud = 1, now(), NULL) AS deleted_at
FROM kylli.kirjesildid ks;

CREATE TABLE repis.v_kirjelipikud (
  kirjekood char(10) NOT NULL DEFAULT '',
  lipik varchar(50) NOT NULL DEFAULT '',
  created_at timestamp NOT NULL DEFAULT current_timestamp(),
  created_by varchar(50) NOT NULL DEFAULT '',
  deleted_at timestamp NULL DEFAULT NULL,
  deleted_by varchar(50) NOT NULL DEFAULT '',
  PRIMARY KEY (kirjekood,lipik),
  KEY lipik (lipik),
  CONSTRAINT v_kirjelipikud_ibfk_1 FOREIGN KEY (lipik) REFERENCES c_lipikud (lipik),
  CONSTRAINT v_kirjelipikud_ibfk_2 FOREIGN KEY (kirjekood) REFERENCES kirjed (kirjekood)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_estonian_ci
SELECT k.kirjekood AS kirjekood,
       k.lipik AS lipik,
       k.created AS created_at,
       k.user AS created_by,
       if(k.kustutatud = 1, now(), NULL) AS deleted_at
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

ALTER TABLE `c_seoseliigid` ADD FOREIGN KEY (`seoseliik_1M`) REFERENCES `c_seoseliigid` (`seoseliik`) ON UPDATE CASCADE;
ALTER TABLE `c_seoseliigid` ADD FOREIGN KEY (`seoseliik_1N`) REFERENCES `c_seoseliigid` (`seoseliik`) ON UPDATE CASCADE;
ALTER TABLE `c_seoseliigid` ADD FOREIGN KEY (`seoseliik_1X`) REFERENCES `c_seoseliigid` (`seoseliik`) ON UPDATE CASCADE;



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
      isikukood1 AS kirjekood1,
      seos AS seos,
      vastasseos AS vastasseos,
      isikukood2 AS kirjekood2,
      timestamp AS created_at,
      user AS created_by
FROM kylli.seosed
