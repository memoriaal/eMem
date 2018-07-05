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
