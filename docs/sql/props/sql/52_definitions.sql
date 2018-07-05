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
