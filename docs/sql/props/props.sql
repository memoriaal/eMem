SELECT now();
CREATE OR REPLACE TABLE aruanded.props (
  id int(10) unsigned NOT NULL AUTO_INCREMENT,
  entity varchar(64) DEFAULT NULL,
  type varchar(32) DEFAULT NULL,
  language varchar(2) DEFAULT NULL,
  datatype varchar(16) DEFAULT NULL,
  public int(1) UNSIGNED NOT NULL DEFAULT 1,
  public int(1) UNSIGNED NOT NULL DEFAULT 1,
  value_text text DEFAULT NULL,
  value_integer int(11) DEFAULT NULL,
  value_decimal decimal(15,4) DEFAULT NULL,
  value_reference varchar(64) DEFAULT NULL,
  value_date datetime DEFAULT NULL,
  created_at datetime DEFAULT NULL,
  created_by varchar(64) DEFAULT NULL,
  deleted_at datetime DEFAULT NULL,
  deleted_by varchar(64) DEFAULT NULL,
  PRIMARY KEY (id),
  KEY entity (entity),
  KEY type (type),
  KEY language (language),
  KEY datatype (datatype)
) ENGINE=InnoDB AUTO_INCREMENT=1000000 DEFAULT CHARSET=utf8;
SELECT now();
/* entity id
   3s */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_mid',
      'string',
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity type
   3s */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_type',
      'string',
      'r_persoon',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity name formula
   3s */
INSERT INTO aruanded.props (entity, type, datatype, search, language, value_text)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      'name' AS property_definition,
      'formula' AS property_type,
      1 AS search,
      NULL property_language,
      '@eesnimi@ @perenimi@' AS value_text
   FROM repis.kirjed
   WHERE allikas = 'Persoon';

/* entity created at/by
   3 sec */
INSERT INTO aruanded.props (entity, type, datatype, created_at, created_by)
   SELECT
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      '_created',
      'atby',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas = 'Persoon';
SELECT now();
/* properties
   40 sec */
INSERT INTO aruanded.props (entity, type, datatype, language, public
   , value_text, value_integer, value_decimal, value_reference, value_date
   , created_at, created_by, deleted_at, deleted_by)
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'eesnimi', 'string', NULL, 1,
       eesnimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND eesnimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'perenimi', 'string', NULL, 1,
       perenimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND perenimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'isanimi', 'string', NULL, 1,
       isanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND isanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'emanimi', 'string', NULL, 1,
       emanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND emanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'synd', 'string', NULL, 1,
       `sünd` AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND `sünd` != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)), 'surm', 'string', NULL, 1,
       surm AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas = 'Persoon'
      AND surm != ''
;
SELECT now();
-- Kirjed
--

/* entity id
   237k */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      concat('repis_k_', kirjekood),
      '_mid',
      'string',
      concat('repis_k_', kirjekood),
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas != 'Persoon'
   ;

/* entity type
   9s */
INSERT INTO aruanded.props (entity, type, datatype, value_text, created_at, created_by)
   SELECT
      concat('repis_k_', kirjekood),
      '_type',
      'string',
      'r_kirje',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas != 'Persoon'
   ;

/* entity name formula
   11s */
INSERT INTO aruanded.props (entity, type, datatype, search, language, value_text)
  SELECT
     concat('repis_k_', kirjekood),
     'name' AS property_definition,
     'formula' AS property_type,
     1 AS search,
     NULL AS property_language,
     '@kirjekood@' AS value_text
  FROM repis.kirjed
  WHERE allikas != 'Persoon'
  ;

/* entity created at/by
   9 sec */
INSERT INTO aruanded.props (entity, type, datatype, created_at, created_by)
   SELECT
      concat('repis_k_', kirjekood),
      '_created',
      'atby',
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas != 'Persoon'
   ;

/* parents
   10 sec */
INSERT INTO aruanded.props (entity, type, datatype, value_reference, created_at, created_by)
   SELECT
      concat('repis_k_', kirjekood),
      '_parent',
      'reference',
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', persoon)),
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas != 'Persoon'
   ;
SELECT now();
/* properties */
INSERT INTO aruanded.props (entity, type, datatype, language, public
   , value_text, value_integer, value_decimal, value_reference, value_date
   , created_at, created_by, deleted_at, deleted_by)
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'kirjekood', 'string', NULL, 1,
       kirjekood AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND eesnimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'eesnimi', 'string', NULL, 1,
       eesnimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND eesnimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'perenimi', 'string', NULL, 1,
       perenimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND perenimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'isanimi', 'string', NULL, 1,
       isanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND isanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'emanimi', 'string', NULL, 1,
       emanimi AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND emanimi != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'synd', 'string', NULL, 1,
       `sünd` AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND `sünd` != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'surm', 'string', NULL, 1,
       surm AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND surm != ''
   UNION ALL
   SELECT
       if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)), 'kirje', 'string', NULL, 1,
       kirje AS value_text,
       NULL AS value_integer,
       NULL AS value_decimal,
       NULL AS value_reference,
       NULL AS value_date,
       created_at, '4', NULL, NULL
    FROM repis.kirjed
    WHERE allikas != 'Persoon'
      AND kirje != ''
;
SELECT now();
/* share all but definitions and owners
   340k rows 8 sec */
 INSERT INTO aruanded.props (entity, type, datatype, value_integer, created_at, created_by)
   SELECT
      entity,
      '_public',
      'boolean',
      1,
      created_at,
      created_by
   FROM aruanded.props
   WHERE TYPE = '_mid';
SELECT now();
-- seed some owners

 INSERT INTO aruanded.props
  (id, entity, type, language, datatype, public, search,
    value_reference, value_text,
    created_at, created_by)
  VALUES
	(3,  '3','_mid',      NULL, 'string',  NULL, NULL,
    NULL, '3',
    NOW(), '4'),
	(4,  '4','_mid',      NULL, 'string',  NULL, NULL,
    NULL, '4',
    NOW(), '4'),
	(30, '3','_type',     NULL, 'string',  NULL, NULL,
    NULL, 'person',
    NOW(), '4'),
	(40, '4','_type',     NULL, 'string',  NULL, NULL,
    NULL, 'person',
    NOW(), '4'),
	(31, '3','name',      NULL, 'formula', NULL, 1,
    NULL, '@forename@ @surname@',
    NOW(), '4'),
	(41, '4','name',      NULL, 'formula', NULL, 1,
    NULL, '@forename@ @surname@',
    NOW(), '4'),
	(42, '4','email',     NULL, 'string',  0,    1,
    NULL, 'mihkel.putrinsh@gmail.com',
    NOW(), '4'),
	(32, '3','email',     NULL, 'string',  0,    1,
    NULL, 'argo@roots.ee',
    NOW(), '4'),
	(33, '3','entu_user', NULL, 'string',  0,    0,
    NULL, 'argoroots@gmail.com',
    NOW(), '4'),
	(43, '4','entu_user', NULL, 'string',  0,    0,
    NULL, 'mihkel.putrinsh@gmail.com',
    NOW(), '4'),
	(44, '4','forename',  NULL, 'string',  1,    1,
    NULL, 'Mihkel-Mikelis',
    NOW(), '4'),
	(34, '3','forename',  NULL, 'string',  1,    1,
    NULL, 'Argo',
    NOW(), '4'),
	(35, '3','phone',     NULL, 'string',  0,    1,
    NULL, '+37256630526',
    NOW(), '4'),
	(45, '4','phone',     NULL, 'string',  0,    1,
    NULL, '+37256560978',
    NOW(), '4'),
	(36, '3','photo',     NULL, 'file',    0,    0,
    NULL, 'A:argo.jpg\nB:8469afac40099272eab091f412114656\nC:template_2/3/9\nD:\nE:97107',
    NOW(), '4'),
	(46, '4','photo',     NULL, 'file',    0,    0,
    NULL, 'A:mihkel.gif\nB:e549ff6d284df921a0af991d998f530b\nC:template_2/4/10\nD:\nE:12933',
    NOW(), '4'),
	(47, '4','surname',   NULL, 'string',  1,    1,
    NULL, 'Putrinš',
    NOW(), '4'),
	(37, '3','surname',   NULL, 'string',  1,    1,
    NULL, 'Roots',
    NOW(), '4'),
	(38, '3', '_owner',   NULL, 'reference', 0, 0,
    '3', NULL,
    NOW(), '4'),
	(39, '3', '_owner',   NULL, 'reference', 0, 0,
    '4', NULL,
    NOW(), '4'),
	(48, '4', '_owner',   NULL, 'reference', 0, 0,
    '3', NULL,
    NOW(), '4'),
	(49, '4', '_owner',   NULL, 'reference', 0, 0,
    '4', NULL,
    NOW(), '4');
SELECT now();
/* definitions */
INSERT INTO aruanded.props (entity, type, language, datatype, public, search, value_text, value_integer, value_decimal, value_reference, value_date, created_at, created_by, deleted_at, deleted_by)
VALUES
	('r_persoon', '_public', NULL, 'boolean', 1, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', '_type', NULL, 'string', 1, NULL, 'entity', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'add_action', NULL, 'string', 1, NULL, 'default,csv', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'displayinfo', NULL, 'string', 1, NULL, '@synd@ - @surm@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'displaytableheader', NULL, 'string', 1, NULL, 'Eesnimi|Perenimie|Isanimi|Emanimi|Sünd|Surm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'displaytable', NULL, 'string', 1, NULL, '@eesnimi@|@perenimie@|@isanimi@|@emanimi@|@synd@|@surm@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'key', NULL, 'string', 1, NULL, 'r_persoon', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'name', NULL, 'string', 1, NULL, 'Persoon', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'plural_name', NULL, 'string', 1, NULL, 'Persoonid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_persoon', 'sort', NULL, 'string', 1, NULL, '@time@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

	('r_kirje', '_public', NULL, 'boolean', 1, NULL, NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', '_type', NULL, 'string', 1, NULL, 'entity', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'add_action', NULL, 'string', 1, NULL, 'default,csv', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'displayinfo', NULL, 'string', 1, NULL, '@synd@ - @surm@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'displaytableheader', NULL, 'string', 1, NULL, 'Eesnimi|Perenimie|Isanimi|Emanimi|Sünd|Surm', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'displaytable', NULL, 'string', 1, NULL, '@eesnimi@|@perenimie@|@isanimi@|@emanimi@|@synd@|@surm@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'key', NULL, 'string', 1, NULL, 'r_kirje', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'name', NULL, 'string', 1, NULL, 'Kirje', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'plural_name', NULL, 'string', 1, NULL, 'Kirjed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('r_kirje', 'sort', NULL, 'string', 1, NULL, '@time@', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
SELECT now();
-- Menu items
INSERT INTO aruanded.props (`entity`, `type`, `language`, `datatype`, `public`, `search`
  , `value_text`, `value_integer`, `value_decimal`, `value_reference`, `value_date`, `created_at`, `created_by`, `deleted_at`, `deleted_by`)
VALUES
	('menu_r_persoon', '_public', NULL, 'boolean', 1, NULL
    , NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_persoon', '_type', NULL, 'string', 1, NULL
    , 'menu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_persoon', 'group', NULL, 'string', 1, NULL
    , 'Repis', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_persoon', 'name', NULL, 'string', 1, NULL
    , 'Persoonid', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_persoon', 'query', NULL, 'string', 1, NULL
    , '_type.string=r_persoon', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),

	('menu_r_kirje', '_public', NULL, 'boolean', 1, NULL
    , NULL, 1, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_kirje', '_type', NULL, 'string', 1, NULL
    , 'menu', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_kirje', 'group', NULL, 'string', 1, NULL
    , 'Repis', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_kirje', 'name', NULL, 'string', 1, NULL
    , 'Kirjed', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('menu_r_kirje', 'query', NULL, 'string', 1, NULL
    , '_type.string=r_kirje', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
SELECT now();
/* rights
  6s x 2 */
 INSERT INTO aruanded.props (entity, TYPE, datatype, value_reference, created_at, created_by)
   SELECT
      entity,
      '_owner',
      'reference',
      '3',
      now(),
      4
   FROM aruanded.props
   WHERE TYPE = '_mid';
 INSERT INTO aruanded.props (entity, TYPE, datatype, value_reference, created_at, created_by)
   SELECT
      entity,
      '_owner',
      'reference',
      '4',
      now(),
      4
   FROM aruanded.props
   WHERE TYPE = '_mid';
SELECT now();
