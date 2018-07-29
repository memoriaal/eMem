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
      if (persoon is null, concat('repis_np_', kirjekood), concat('repis_p_', kirjekood)),
      created_at,
      '4'
   FROM repis.kirjed
   WHERE allikas != 'Persoon'
   ;
